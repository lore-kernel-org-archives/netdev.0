From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [Bug 11442] btusb suspend/resume bug...
Date: Wed, 01 Oct 2008 00:03:49 +0200
Message-ID: <1222812229.1825.65.camel@violet.holtmann.net>
References: <20080916.155123.181085856.davem@davemloft.net>
	 <200809271541.15963.rjw@sisk.pl>
	 <1222754141.1825.55.camel@violet.holtmann.net>
	 <200809302344.42615.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:50810 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbYI3WDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 18:03:51 -0400
In-Reply-To: <200809302344.42615.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rafael,

> > > > >> Rafael, can you pull from my tree and test the changes:
> > > > >>
> > > > >> git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/ 
> > > > >> bluetooth-2.6.git
> > > > >>
> > > > >> It would be interesting if these fixes are enough.
> > > > >
> > > > > They appear to be enough.  I haven't had any suspend/resume failures  
> > > > > with them
> > > > > applied.
> > > > 
> > > > so it works _without_ applying patch-btusb-suspend.
> > > 
> > > Well, unfortunately I spoke too soon.
> > > 
> > > I'm still seeing post-hibernation crashes triggered by the bluetooth user land
> > > trying to use the device handled by btusb.  They happen every second
> > > hibernation, more or less, and apparently they are oopses in various code
> > > paths not directly related to bluetooth, like ext3 (memory corruption or
> > > what?).
> > 
> > I pushed two extra patches to my bluetooth-2.6 repository:
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/holtmann/bluetooth-2.6.git
> > 
> > One is fixing a double-free in the error path. This error path can be
> > triggered during suspend/resume if the USB core just disconnects the
> > device. Please check if that fixes it for you.
> > 
> > > With patch-btusb-suspend applied I don't see them (actually I have to use
> > > a slightly modified version of the patch which is appended).
> > > 
> > > Interestingly enough, suspend to RAM works without any visible problems.
> > 
> > As Oliver said, the USB core should do the right thing when no suspend
> > and resume callbacks are provided. I looked through the code so many
> > times now and I am running out of ideas what can happen.
> > 
> > Lets try it one last time without the suspend patch, but the double free
> > fix and see if that works. Otherwise I really give up.
> 
> This time I cannot reproduce the hibernation issue without the suspend patch,
> so it appears that your double-free fix works for me.

great. So I push these for 2.6.27 and then for 2.6.28, we can add full
suspend and auto-suspend and remote-wakeup support. Thanks for testing.

Regards

Marcel


