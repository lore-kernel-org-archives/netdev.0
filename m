From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v1 5/5] cgroup: net_cls: Rework update socket logic
Date: Fri, 26 Oct 2012 03:42:20 -0400 (EDT)
Message-ID: <20121026.034220.576309730816593287.davem@davemloft.net>
References: <1351174619-5096-1-git-send-email-wagi@monom.org>
	<1351174619-5096-6-git-send-email-wagi@monom.org>
	<20121025190734.GE15105@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wagi-kQCPcA+X3s7YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121025190734.GE15105-B26myB8xz7F8NnZeBjwnZQMhkBWG/bsMQH7oEaQurus@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 25 Oct 2012 15:07:34 -0400

> On Thu, Oct 25, 2012 at 04:16:59PM +0200, Daniel Wagner wrote:
>> From: Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>
>> 
>> The cgroup logic part of net_cls is very similar as the one in
>> net_prio. Let's stream line the net_cls logic with the net_prio one.
>> 
>> The net_prio update logic was changed by following commit (note there
>> were some changes necessary later on)
>> 
>> commit 406a3c638ce8b17d9704052c07955490f732c2b8
>> Author: John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
>> Date:   Fri Jul 20 10:39:25 2012 +0000
>> 
>>     net: netprio_cgroup: rework update socket logic
>> 
>>     Instead of updating the sk_cgrp_prioidx struct field on every send
>>     this only updates the field when a task is moved via cgroup
>>     infrastructure.
>> 
>>     This allows sockets that may be used by a kernel worker thread
>>     to be managed. For example in the iscsi case today a user can
>>     put iscsid in a netprio cgroup and control traffic will be sent
>>     with the correct sk_cgrp_prioidx value set but as soon as data
>>     is sent the kernel worker thread isssues a send and sk_cgrp_prioidx
>>     is updated with the kernel worker threads value which is the
>>     default case.
>> 
>>     It seems more correct to only update the field when the user
>>     explicitly sets it via control group infrastructure. This allows
>>     the users to manage sockets that may be used with other threads.
>> 
>> Since classid is now updated when the task is moved between the
>> cgroups, we don't have to call sock_update_classid() from various
>> places to ensure we always using the latest classid value.
>> 
>> [v2: Use iterate_fd() instead of open coding]
>> 
> Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

Applied.
