From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] ipvs: Remove unused variable ret from sync_thread_master()
Date: Tue, 12 Nov 2013 14:21:39 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7405@saturn3.aculab.com>
References: <1384264396-14550-1-git-send-email-geert@linux-m68k.org> <20131112141314.GQ5056@laptop.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Oleg Nesterov" <oleg@redhat.com>,
	"Ingo Molnar" <mingo@kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Peter Zijlstra" <peterz@infradead.org>,
	"Geert Uytterhoeven" <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20131112141314.GQ5056@laptop.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > @@ -1637,7 +1637,7 @@ static int sync_thread_master(void *data)
> >  			continue;
> >  		}
> >  		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
> > -			int ret = __wait_event_interruptible(*sk_sleep(sk),
> 
> So ideally there's be a comment here why we're using interruptible but
> then ignore interruptions.
> 
> Julian said (
> http://lkml.kernel.org/r/alpine.LFD.2.00.1310012245020.1782@ja.ssi.bg ):
> 
> " Yes, your patch looks ok to me. In the past
> we used ssleep() but IPVS users were confused why
> IPVS threads increase the load average. So, we
> switched to _interruptible calls and later the socket
> polling was added.  "

I've done this in the past so that the code sleeps interruptibly
unless there is a signal pending - which would cause it to return
early.

    /* Tell scheduler we are going to sleep... */
    if (signal_pending(current))
        /* We don't want waking immediately (again) */
        sleep_state = TASK_UNINTERRUPTIBLE;
    else
        sleep_state = TASK_INTERRUPTIBLE;
    set_current_state(sleep_state);

Shame there isn't a process flag to indicate that the process
will sleep uninterruptibly and that it doesn't matter.
So don't count to the load average and don't emit a warning
if it has been sleeping for a long time.

	David
