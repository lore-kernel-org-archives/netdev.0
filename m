From: Helmut Grohne <helmut@subdivi.de>
Subject: sky2 mac hung again (or still?)
Date: Fri, 16 Jul 2010 09:44:21 +0200
Message-ID: <20100716074419.GA32323@alf.mars>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from subdivi.de ([77.37.6.11]:3869 "EHLO subdivi.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935847Ab0GPIRD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jul 2010 04:17:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear sky2 maintainers,

thanks for all your work on the continuously improving stability issues
of the sky2 driver. Unfortunately this battle is not yet over. To aid in
getting this fully working I'd like to give another data point.

Kernel: vanilla 2.6.33.2

lspci output:
05:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit Ethernet Controller (rev 19)
        Subsystem: ASUSTeK Computer Inc. Marvell 88E8053 Gigabit Ethernet controller PCIe (Asus)
        Flags: bus master, fast devsel, latency 0, IRQ 36
        Memory at d1000000 (64-bit, non-prefetchable) [size=16K]
        I/O ports at a000 [size=256]
        [virtual] Expansion ROM at 80800000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 2
        Capabilities: [50] Vital Product Data
        Capabilities: [5c] MSI: Enable- Count=1/2 Maskable- 64bit+
        Capabilities: [e0] Express Legacy Endpoint, MSI 00
        Capabilities: [100] Advanced Error Reporting
        Kernel driver in use: sky2

dmesg output after rmmod and modprobe (for a currently very hung card):
sky2 driver version 1.26
sky2 0000:05:00.0: PCI INT A -> GSI 36 (level, low) -> IRQ 36
sky2 0000:05:00.0: setting latency timer to 64
sky2 0000:05:00.0: PCI: Disallowing DAC for device
sky2 0000:05:00.0: Yukon-2 EC chip revision 2
sky2 0000:05:00.0: irq 53 for MSI/MSI-X
sky2 0000:05:00.0: No interrupt generated using MSI, switching to INTx mode.
sky2 eth0: addr 00:15:f2:36:00:e9

The problem (again/still) is as usual:
sky2 eth0: hung mac 124:91 fifo 194 (182:176)
sky2 eth0: receiver hang detected
sky2 eth0: disabling interface
sky2 eth0: enabling interface

(I can get you more of these hung mac messages with slightly different
numbers if need be.)

This kind of hang happens about once a day for me and it kills my pptp vpn
connection, cause the card takes too long to recover.

Today in contrast the card took the opportunity to crash a bit harder,
so I did not get it up again (maybe a reboot can help later). I was
lucky to have an unused rtl8139too in that machine...

It seems like a precondition for the card to hang is a bit network
traffic. I don't remember getting it crashed with a load of less than
10Mbit symmetric (receive/send) while using this kernel version. On the
other I have seen the card survive this workload for 8 hours a few
times. It does not seem to have any problems with a quick and high
receive load (downloading Debian packages from the next 1Gbit mirror,
usually around 200Mbit).

To me this sounds like a race condition.

Did I miss out any details?

Thanks in advance

Helmut
