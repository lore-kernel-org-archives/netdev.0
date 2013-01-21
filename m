From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: Re: [BUG] Bug in netprio_cgroup and netcls_cgroup ?
Date: Mon, 21 Jan 2013 17:01:54 +0800
Message-ID: <50FD0402.6060400@huawei.com>
References: <50FCDB5C.4050608@huawei.com> <50FD0144.1000401@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Wagner <wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <50FD0144.1000401-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2013/1/21 16:50, Daniel Wagner wrote:
> Hi Li,
> 
> On 21.01.2013 07:08, Li Zefan wrote:
>> I'm not a network developer, so correct me if I'm wrong.
>>
>> Since commit 7955490f732c2b8
>> ("net: netprio_cgroup: rework update socket logic"), sock->sk->sk_cgrp_prioidx
>> is set when the socket is created, and won't be updated unless the task is
>> moved to another cgroup.
>>
>> Now the problem is, a socket can be _shared_ by multiple processes (fork, SCM_RIGHT).
>> If we place those processes in different cgroups, and each cgroup has
>> different configs, but all of the processes will send data via this socket
>> with the same network priority.
> 
> Wouldn't that be addressed by 48a87cc26c13b68f6cce4e9d769fcb17a6b3e4b8
> 
>    net: netprio: fd passed in SCM_RIGHTS datagram not set correctly
> 
>     A socket fd passed in a SCM_RIGHTS datagram was not getting
>     updated with the new tasks cgrp prioidx. This leaves IO on
>     the socket tagged with the old tasks priority.
> 
>     To fix this add a check in the scm recvmsg path to update the
>     sock cgrp prioidx with the new tasks value.
> 
> As I read this this should work for net_prio.
> 

But after process A passed the socket fd to B, both A and B can use the
same socket to send data, right? Then if A and B were placed in different
cgroups with differnt configs, A's config won't take effect anymore.

Am I missing something?
