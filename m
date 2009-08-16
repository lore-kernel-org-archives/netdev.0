From: Maxim Levitsky <maximlevitsky@gmail.com>
Subject: Very strange issues with ethernet wake on lan
Date: Sun, 16 Aug 2009 06:42:54 +0300
Message-ID: <1250394174.32268.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-pm@lists.linux-foundation.org"
	<linux-pm@lists.linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:46826 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752242AbZHPDm5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Aug 2009 23:42:57 -0400
Received: by fg-out-1718.google.com with SMTP id e12so248017fga.17
        for <netdev@vger.kernel.org>; Sat, 15 Aug 2009 20:42:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have recently put back the davicom dm9009 ethernet card into my
computer.

Some long time ago, I have written its suspend/resume routines.
Now I see that few things have changed, like I need to enable wake in
sysfs or better patch the code to do so, some nice helpers like
pci_prepare_to_sleep have arrived, etc.


I narrowed the strange issue down to following situation:

I reload dmfe.ko (and networkmanager is disabled)
I don't ifup the device, thus pretty much no hardware initialization
takes place (but this appears not to matter anyway)

I then suspend the system, and WOL doesn't work (I have patched the
driver to enable WOL automaticly)

I then, suspend again. WOL works, and continues to work as long as I
don't reload the driver. If I do, same situation repeats.

Also, after a boot, WOL works, so a reload cycle triggers that issue.

And most importantly, if I don't do a

pci_set_power_state(pci_dev, pci_choose_state (pci_dev, state));

in .suspend, then WOL always works.

and I have even tried to set state manually to PCI_D3hot or PCI_D3cold, 

I also tried to use pci_save_state


I also have 2 copies of this card, and both have this issue.
I also tried 2 pci slots.

Kernel is vanilla 2.6.31-rc5


Any ideas?

Best regards,
	Maxim Levitsky

