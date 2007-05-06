From: Ryan Richter <ryan@tau.solarneutrino.net>
Subject: eth1 became eth2, but dmesg still says eth1
Date: Sun, 6 May 2007 01:38:24 -0400
Message-ID: <20070506053824.GC6222@tau.solarneutrino.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from solarneutrino.net ([66.199.224.43]:3116 "EHLO
	tau.solarneutrino.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693AbXEFGX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2007 02:23:56 -0400
Received: from ryan by tau.solarneutrino.net with local (Exim 4.63)
	(envelope-from <ryan@tau.solarneutrino.net>)
	id 1HkZRw-00028u-FD
	for netdev@vger.kernel.org; Sun, 06 May 2007 01:38:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Upon upgrading from 2.6.20.7 to 2.6.20.11, e1000 seems to be confused
about what the second ethernet interface is called.  Here's what dmesg
says:


Intel(R) PRO/1000 Network Driver - version 7.3.15-k2
Copyright (c) 1999-2006 Intel Corporation.
ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 18 (level, low) -> IRQ 18
PCI: Setting latency timer of device 0000:04:00.0 to 64
e1000: 0000:04:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x4) 00:15:17:1a:69:d0
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI Interrupt 0000:04:00.1[B] -> GSI 19 (level, low) -> IRQ 19
PCI: Setting latency timer of device 0000:04:00.1 to 64
e1000: 0000:04:00.1: e1000_probe: (PCI Express:2.5Gb/s:Width x4) 00:15:17:1a:69:d1
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
Ethernet Channel Bonding Driver: v3.1.1 (September 26, 2006)
bonding: MII link monitoring set to 100 ms


However the bond0 interface failed to come up, complaining that there
was no such interface as eth1.  I checked /proc/net/dev, and it listed
eth0 and _eth2_.  I changed the bonding configuration to use eth0 and
eth2 and it's working fine now.

Is this a known problem?  I skimmed the netdev archives but didn't see
anything.  Let me know if you need more info about my kernel config or
hardware.

Thanks,
-ryan
