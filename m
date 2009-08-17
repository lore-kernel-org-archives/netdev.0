From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Very strange issues with ethernet wake on lan
Date: Mon, 17 Aug 2009 20:30:54 +0200
Message-ID: <200908172030.54505.rjw@sisk.pl>
References: <1250394174.32268.13.camel@localhost.localdomain> <1250500588.4301.5.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pm@lists.linux-foundation.org"
	<linux-pm@lists.linux-foundation.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:49752 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757957AbZHQSaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2009 14:30:07 -0400
In-Reply-To: <1250500588.4301.5.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 17 August 2009, Maxim Levitsky wrote:
> On Sun, 2009-08-16 at 06:42 +0300, Maxim Levitsky wrote:
> > Hi,
> > 
> > I have recently put back the davicom dm9009 ethernet card into my
> > computer.
> > 
> > Some long time ago, I have written its suspend/resume routines.
> > Now I see that few things have changed, like I need to enable wake in
> > sysfs or better patch the code to do so, some nice helpers like
> > pci_prepare_to_sleep have arrived, etc.
> > 
> > 
> > I narrowed the strange issue down to following situation:
> > 
> > I reload dmfe.ko (and networkmanager is disabled)
> > I don't ifup the device, thus pretty much no hardware initialization
> > takes place (but this appears not to matter anyway)
> > 
> > I then suspend the system, and WOL doesn't work (I have patched the
> > driver to enable WOL automaticly)
> > 
> > I then, suspend again. WOL works, and continues to work as long as I
> > don't reload the driver. If I do, same situation repeats.
> > 
> > Also, after a boot, WOL works, so a reload cycle triggers that issue.
> > 
> > And most importantly, if I don't do a
> > 
> > pci_set_power_state(pci_dev, pci_choose_state (pci_dev, state));
> > 
> > in .suspend, then WOL always works.
> > 
> > and I have even tried to set state manually to PCI_D3hot or PCI_D3cold, 
> > 
> > I also tried to use pci_save_state
> > 
> > 
> > I also have 2 copies of this card, and both have this issue.
> > I also tried 2 pci slots.
> > 
> > Kernel is vanilla 2.6.31-rc5

I need a dmesg output containing at least one suspend-resume cycle
(preferably two cycles, the first one where WoL worked and another one
where it didn't).

Best,
Rafael
