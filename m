From: Oren Laadan <orenl@cs.columbia.edu>
Subject: Re: [PATCH] [RFC] C/R: inet4 and inet6 unicast routes (v2)
Date: Fri, 30 Apr 2010 22:02:15 -0400
Message-ID: <4BDB8BA7.1040100@cs.columbia.edu>
References: <1272646855-17327-1-git-send-email-danms@us.ibm.com>	<4BDB3F07.2030900@free.fr> <87bpd0zl9l.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Lezcano <daniel.lezcano@free.fr>, containers@lists.osdl.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tarap.cc.columbia.edu ([128.59.29.7]:58598 "EHLO
	tarap.cc.columbia.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754950Ab0EACBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 22:01:04 -0400
In-Reply-To: <87bpd0zl9l.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Dan Smith wrote:
> DL> Is it possible to enter the namespace and dump / restore the
> DL> routes with NETLINK_ROUTE from userspace ? Or is it something not
> DL> possible ?
> 
> I'm sure it would be doable.  However, checkpointing the routes that
> way would:
> 
> (a) Be inconsistent with how we checkpoint all the other resources,
>     including the other network resources we handle from the kernel
>     with rtnl
> (b) Require merging of the data from the resources saved in userspace
>     with those saved in kernelspace

See below suggestion for userspace.

> (c) Eliminate the ability for an application to easily checkpoint
>     itself by making a single syscall

I can't think of a use-case of a networked application that takes
a checkpoint of itself (including live network).

Anyway, it's can still be useful to at least do the restore from
userspace (while checkpoint is done in kernel - like with pids).
We may reduce the complexity of restore (in kernel) greatly.

(BTW, instead of syscall one could have a library call that will
take care of the userspace "work").

> (d) Require this same sort of jumping back and forth between
>     namespaces by the userspace task doing the checkpoint/restart
> 

I wonder: if we could relatively simply recreate the network ns,
the interfaces in them, and then restore the routing information
all from userspace before calling sys_restart, it may be useful
in simplifying the kernel code, and allowing more flexibility for
userspace alterations.

I definitely should have asked the question much earlier when you
started the work on restoring network ns and interfaces ... (oh,
I reckon it's better late than never).

Just tossing out the idea, see what kind of thoughts it evokes.
Most likely I'll get a "that won't work because ...", but I'm
hoping for a "hmm.. maybe.. let me see.." :)

Oren.
