From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] ipvs: Remove unused variable ret from sync_thread_master()
Date: Tue, 12 Nov 2013 14:38:22 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7406@saturn3.aculab.com>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org> <20131112141314.GQ5056@laptop.programming.kicks-ass.net> <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com> <20131112143152.GS5056@laptop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Geert Uytterhoeven" <geert@linux-m68k.org>,
	"Oleg Nesterov" <oleg@redhat.com>,
	"Ingo Molnar" <mingo@kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Peter Zijlstra" <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60268 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751534Ab3KLOm2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 09:42:28 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17102-09 for <netdev@vger.kernel.org>;
 Tue, 12 Nov 2013 14:42:25 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20131112143152.GS5056@laptop.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I've done this in the past so that the code sleeps interruptibly
> > unless there is a signal pending - which would cause it to return
> > early.
> >
> >     /* Tell scheduler we are going to sleep... */
> >     if (signal_pending(current))
> >         /* We don't want waking immediately (again) */
> >         sleep_state = TASK_UNINTERRUPTIBLE;
> >     else
> >         sleep_state = TASK_INTERRUPTIBLE;
> >     set_current_state(sleep_state);
> 
> If this is for kernel threads, I think you can wipe the pending state;
> not entirely sure how signals interact with kthreads; Oleg will know.

I did take me a while to manage to use kthreads, and we probably still
have customers who insist on using pre 2.6.18 kernels!
(In which case the processes are children of a daemon that only
return to userspace in order to exit.)

We also need to send signals (to get the process out of blocking
socket calls), so I have to use force_sig() to get the signal noticed.

The other issue was tidyup - I had to find module_put_and_exit().

	David
