From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [Bugme-new] [Bug 10473] New: Infinite loop "b44: eth0: powering down PHY"
Date: Fri, 18 Apr 2008 21:19:15 +0200
Message-ID: <200804182119.16195.mb@bu3sch.de>
References: <bug-10473-10286@http.bugzilla.kernel.org/> <200804182018.52753.mb@bu3sch.de> <9bfa9ae0804181202o601e7e86p135547ce802db88d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	"Gary Zambrano" <zambrano@broadcom.com>
To: "Nelson A. de Oliveira" <naoliv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vs166246.vserver.de ([62.75.166.246]:59951 "EHLO
	vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760760AbYDRTTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2008 15:19:40 -0400
In-Reply-To: <9bfa9ae0804181202o601e7e86p135547ce802db88d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 18 April 2008 21:02:37 Nelson A. de Oliveira wrote:
> Hi!
> 
> On Fri, Apr 18, 2008 at 3:18 PM, Michael Buesch <mb@bu3sch.de> wrote:
> > On Friday 18 April 2008 20:09:36 Nelson A. de Oliveira wrote:
> >  > On Fri, Apr 18, 2008 at 2:59 PM, Michael Buesch <mb@bu3sch.de> wrote:
> >  > >  > b44_poll: istat = 0x00000400
> >  > >
> >  > >  Hm, a descriptor error. Smells like my DMA fix actually broke this, damit.
> >  > >  On which architecture are you running?
> >  >
> >  > i386 here.
> >
> >  Hm, I tested my patch on i386.
> >  So I'm not sure what's going on, actually. And the patch was pretty
> >  trivial and I really can't find a bug in it.
> >  So you say 2.6.24 was still working?
> 
> Strange... compiled 2.6.24.4, 2.6.24 and 2.6.23 here and they are all
> stopping with this:
> 
> b44: eth0: Link is up at 100 Mbps, full duplex.
> b44: eth0: Flow control is off for TX and off for RX.
>
> And it seems to keep waiting for something. The system isn't freezed
> (as CTRL+ALT+DEL kills the running processes and correctly reboots the
> machine).

Well. 2.6.24 didn't have this message. But it could still have the actual
bug, of course. So can you try applying my printk patch to a broken 2.6.24
kernel and see whether it triggers the message or not? Under normal
circumstances this codepath should never trigger.

> With Debian's 2.6.24.4 it is working.
> With vanilla 2.6.25 and my config it just enters an infinite loop of
> "b44: eth0: powering down PHY".

This message was added in 2.6.25. That doesn't mean the
bug was also added in 2.6.25, of course.

> Can different GCC versions cause this? Can a bad .config file cause
> things like that? (I am using this .config for a long time and it has
> always been working correctly, at least until now)

Well, possible, although unlikely.

Can you try bisecting the bug? Yeah, I know about the lwn article [1] that
says bisecting is baaaaaad (tm), but my opinion is different. :)
It's an excellent tool for efficiently finding patches that caused bugs.
But take care to really check whether device _works_ or not. Just looking
at the actual "powering down PHY" will _not_ be enough, as that was only
recently added, as I said.

[1] http://lwn.net/Articles/278137/

-- 
Greetings Michael.
