From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: Very strange issues with ethernet wake on lan
Date: Tue, 29 Sep 2009 22:28:18 +0200
Message-ID: <200909292228.18200.rjw@sisk.pl>
References: <1250394174.32268.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pm@lists.linux-foundation.org"
	<linux-pm@lists.linux-foundation.org>
To: Maxim Levitsky <maximlevitsky@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:44343 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753453AbZI2U0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 16:26:49 -0400
In-Reply-To: <1250394174.32268.13.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 16 August 2009, Maxim Levitsky wrote:
> Hi,
> 
> I have recently put back the davicom dm9009 ethernet card into my
> computer.
> 
> Some long time ago, I have written its suspend/resume routines.
> Now I see that few things have changed, like I need to enable wake in
> sysfs or better patch the code to do so, some nice helpers like
> pci_prepare_to_sleep have arrived, etc.
> 
> 
> I narrowed the strange issue down to following situation:
> 
> I reload dmfe.ko (and networkmanager is disabled)
> I don't ifup the device, thus pretty much no hardware initialization
> takes place (but this appears not to matter anyway)
> 
> I then suspend the system, and WOL doesn't work (I have patched the
> driver to enable WOL automaticly)
> 
> I then, suspend again. WOL works, and continues to work as long as I
> don't reload the driver. If I do, same situation repeats.
> 
> Also, after a boot, WOL works, so a reload cycle triggers that issue.
> 
> And most importantly, if I don't do a
> 
> pci_set_power_state(pci_dev, pci_choose_state (pci_dev, state));
> 
> in .suspend, then WOL always works.
> 
> and I have even tried to set state manually to PCI_D3hot or PCI_D3cold, 
> 
> I also tried to use pci_save_state
> 
> 
> I also have 2 copies of this card, and both have this issue.
> I also tried 2 pci slots.
> 
> Kernel is vanilla 2.6.31-rc5

Please check if this still happens with 2.6.32-rc1.

Best,
Rafael
