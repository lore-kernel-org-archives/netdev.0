From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH RFC] isdn/capi: fix up CAPI subsystem workaround locking a bit
Date: Tue, 6 Oct 2009 23:01:22 +0200
Message-ID: <200910062301.24572.mb@bu3sch.de>
References: <20091003120657.2228911186C@xenon.ts.pxnet.com> <200910052324.09992.mb@bu3sch.de> <4ACB83F7.9040500@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: i4ldeveloper@listserv.isdn4linux.de,
	Carsten Paeth <calle@calle.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>,
	Armin Schindler <armin@melware.de>,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:33282 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933206AbZJFVCN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2009 17:02:13 -0400
In-Reply-To: <4ACB83F7.9040500@imap.cc>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 06 October 2009 19:52:55 Tilman Schmidt wrote:
> > Yeah, this sledgehammer lock did fix the crash while leaving the old non-list-head
> > queue in place (it should still be there today).
> 
> That is not the case. In mainline, your second patch was applied on
> top of the first one, so there is now struct list_head ackqueue and
> spinlock_t ackqlock as well as static DEFINE_SPINLOCK(workaround_lock).

Ok, that's fine, too.
It's just that the ackqlock wasn't enough to fix it, as I said. It just shrinks the window.

> > I still have the device somewhere. If you want to have it, I can blow off the
> > dust and send it to you. If you don't want it, I'll throw it away soon.
> > I'd really like to send it to you to get rid of it. ;)
> 
> Feel free to do so. I'll send you my snailmail address by PM. I'm
> making no promises about when I might get around to actually testing
> it, though.

Thanks, I'll get it to the post office by the end of the week.

> >> Can anyone shed some light on 
> >> what that device is doing differently from other ISDN cards?
> > 
> > Well, it's a combined ISDN/DSL card, but I never used the ISDN part. So the crash
> > happened while transferring data over the DSL link.
> 
> DSL over CAPI? Strange.

Yeah, dunno. They did it that way... Pretty weird.

> > The vendor driver is closed source with an open wrapper (like nvidia). It's a pretty
> > crappy unmaintained piece of software, but it ran stable with some patches applied
> > to the driver and the workaround-lock patch to the capi stack.
> 
> O dear. I wonder what I'll find.

ftp://ftp.avm.de/cardware/fritzcrd.dsl/linux/suse.93/fcdsl-suse93-3.11-07.tar.gz

This is the driver that I used. It needs some modification to compile on a recent kernel.
Unfortunately I don't have the patch anymore. But it was rather trivial. It renamed some functions,
because they clashed with others and did some other things I don't remember.
Remember to get a bucket before looking at the code, because you will need it. ;)

-- 
Greetings, Michael.
