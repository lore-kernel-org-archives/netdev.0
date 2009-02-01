From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Sun, 1 Feb 2009 01:41:29 +0100
Message-ID: <200902010141.30594.rjw@sisk.pl>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200902010111.08433.rjw@sisk.pl> <alpine.LFD.2.00.0901311623520.3067@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Parag Warudkar <parag.lkml@gmail.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:54887 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751517AbZBAAl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Jan 2009 19:41:59 -0500
In-Reply-To: <alpine.LFD.2.00.0901311623520.3067@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 01 February 2009, Linus Torvalds wrote:
> 
> On Sun, 1 Feb 2009, Rafael J. Wysocki wrote:
> > > The problems happen on purely the suspend path. How the f*ck do you know 
> > > that the drivers behind the bridge don't do everything at 'suspend_late' 
> > > time, and expect to be working up until that time?
> > 
> > DMA from suspend_late?  Come on.
> 
> Rafael. Stop being a total idiot.
> 
> Read what I wrote.
> 
> I'm saying that the driver may not do anything at all at suspend() time, 
> and leaves everything until suspend_late. Then, at suspend_late(), it 
> finally really shuts down.
> 
> That's actually a very reasonable thing to do in some circumstances. It 
> simplifies everything, in particular all interrupt handling, since the 
> device is now fully live all the way while interrupts can happen.
> 
> For a USB host controller, for example, it really could make sense to do 
> that - just leave all the core host controller stuff running, and the only 
> thing the "suspend()" callback does is to send the commands to the actual 
> devices, it doesn't necessarily touch the host controller itself at all.
> 
> Then, at suspend_late time, you just clear the "running" bit in the 
> controller (and perhaps not even that - because you want to still push 
> things out for debugging). End result: you never actually had to shut 
> anything down at all, and you could (for example) still run a USB serial 
> port console all the way to shutdown.
> 
> And yes, I wanted to do basically exactly that when I was debugging some 
> issues a year or two ago.
> 
> See? The device and driver may be totally alive over a ->suspend() call. 
> And that means that the bridge CANNOT KNOW that it's ok to shut down DMA. 
> Because DMA may be the only way the device communicates (again: USB 
> actually works that way).
> 
> So dammit, just admit that you were wrong,

I said I was.

Thanks,
Rafael
