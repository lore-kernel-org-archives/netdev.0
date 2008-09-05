From: "Johann Baudy" <johaahn@gmail.com>
Subject: Fwd: Packet mmap: TX RING and zero copy
Date: Fri, 5 Sep 2008 11:17:07 +0200
Message-ID: <7e0dd21a0809050217v33ecb8fvcadd5e65118d6afe@mail.gmail.com>
References: <20080903.040626.198546183.davem@davemloft.net>
	 <7e0dd21a0809030800v5e39808bl2f22893bc8214c2a@mail.gmail.com>
	 <20080903151340.GA7566@2ka.mipt.ru>
	 <7e0dd21a0809030858h7fdc454dj33acc6be25a0aab@mail.gmail.com>
	 <20080903164346.GA6729@2ka.mipt.ru>
	 <7e0dd21a0809031330i1363c4aema9c57ef06a3d5279@mail.gmail.com>
	 <20080903220347.GA22395@2ka.mipt.ru>
	 <7e0dd21a0809040744q3ee65695uc33f6cc26a1fe4dd@mail.gmail.com>
	 <20080905071754.GA25998@2ka.mipt.ru>
	 <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:22833 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbYIEJRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 05:17:08 -0400
Received: by rv-out-0506.google.com with SMTP id k40so365434rvb.1
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2008 02:17:07 -0700 (PDT)
In-Reply-To: <7e0dd21a0809050216r65b8f08fm1ad0630790a13a54@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> vmsplice() can be slow, try to inject header via usual send() call, or
> better do not use it at all for testing.
>
vmsplice() is short in comparison to splice()  ~ 200us !
This was just to show you that even this vmpslice duration of 80us
that is needed for each packet is too long to send only 1 packet.
I really need a mechanism that allow sending of ~ 40 packets of 7200K
in one system call to keep some cpu ressources to do other things.
(Not spending time in kernel layers :))

>
> Amount of gettimofday() and friends is excessive, but it can be a trace
> tool itself.
I've only observed a small performance between with and without
gettimeofday().(< 1MB/s). I've used it to do a light FTRACE and to get
duration of vmsplice.

> kill_fasync() also took too much time (top CPU user
> is at bottom I suppose?), do you use SIGIO? Also vma traveling and page
> checking is not what will be done in network code and your project, so
> it also adds an overhead.

Between kill_fasync() sys_gettimeofday() , I thought that we returned
to user space.
No SIGIO. But FYI, I use PREEMPT_RT patch.

>Please try without vmsplice() at all, usual
> splice()/sendfile() _has_ to saturate the link, otherwise we have a
> serious problem.

I've already tried sendfile only with standard TCP/UDP socket. I've
not saturated the link.
Around same bitrate.

>
> Not to distract you from the project, but you still can do the same with
> existing methods and smaller amount of work. But I should be last saying
> that creating tricky hacks to implement the idea should be abandoned in
> favour of the standards (even slow) methods :)
>
I understand your point that common solution are always better than
multiple hacks.
But I think that I have the same motivation than packet mmap IO developers .
This feature was introduced to make the capture process of raw socket
efficient. I just want to reach the same goal for transmission using
same mechanism.
We use those features only if we need performance at the driver level.

Thanks,
Johann




--
Johann Baudy
johaahn@gmail.com



-- 
Johann Baudy
johaahn@gmail.com
