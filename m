From: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [BUG] Bug in netprio_cgroup and netcls_cgroup ?
Date: Mon, 21 Jan 2013 14:08:28 +0800
Message-ID: <50FCDB5C.4050608@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I'm not a network developer, so correct me if I'm wrong.

Since commit 406a3c638ce8b17d9704052c07955490f732c2b8
("net: netprio_cgroup: rework update socket logic"), sock->sk->sk_cgrp_prioidx
is set when the socket is created, and won't be updated unless the task is
moved to another cgroup.

Now the problem is, a socket can be _shared_ by multiple processes (fork, SCM_RIGHT).
If we place those processes in different cgroups, and each cgroup has
different configs, but all of the processes will send data via this socket
with the same network priority.

Similar with cls cgroup.
