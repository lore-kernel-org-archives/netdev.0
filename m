From: pacman@kosh.dhis.org
Subject: mv643xx broken on pegasos
Date: Wed, 14 Jan 2009 20:22:32 -0500 (GMT+5)
Message-ID: <20090115012232.3852.qmail@kosh.dhis.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-69-246-218-29.hsd1.in.comcast.net ([69.246.218.29]:47087 "HELO
	kosh.dhis.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751471AbZAOBbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 20:31:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on what I can find in the mailing list archives, I'm the last remaining
Pegasos owner. (Maybe I was always the only one.) I therefore reluctantly
offer myself as the guinea pig to get mv643xx_eth back to normal.

In 2.6.26 it worked. (Detected as eth1, since eth0 is the via-rhine)

In 2.6.27 it was completely broken. It detected the device and said the link
was up, but it was not usable. From tcpdump it appears that incoming packets
are processed correctly, but outgoing packets are delayed and/or mangled.
Occasionally a packet goes through. Workaround: the 2.6.26 version of
mv643xx_eth.c still compiles and works if dropped into 2.6.27/drivers/net.

In 2.6.28, it behaves like 2.6.27 with a bonus bug: the port has moved to
eth2, and eth1 is now a phantom port with MAC address 00:00:00:00:00:00. And
the old 2.6.26 code doesn't compile so the workaround is dead.

To start the investigation, I'm including log excerpts showing what happens
when the driver is first loaded in 3 different kernels. Note this interesting
feature: the first one shows a different MAC address than the others, with an
unregistered OUI instead of bplan's 00:0b:2f, plus the suspicious string
"DEAD"... and this is the driver that works!

2.6.26> MV-643xx 10/100/1000 Ethernet Driver
2.6.26> eth1: port 1 with MAC address 00:2b:2f:de:ad:01
2.6.26> eth1: Scatter Gather Enabled
2.6.26> eth1: TX TCP/IP Checksumming Supported
2.6.26> eth1: RX TCP/UDP Checksum Offload ON
2.6.26> eth1: RX NAPI Enabled
2.6.26> eth1: Using SRAM

2.6.27> MV-643xx 10/100/1000 ethernet driver version 1.3
2.6.27>  : no PHY detected at addr 0
2.6.27> net eth1: port 1 with MAC address 00:0b:2f:6b:27:e2
2.6.27> net eth1: scatter/gather enabled
2.6.27> net eth1: tx checksum offload
2.6.27> net eth1: napi enabled
2.6.27> net eth1: configured with sram

2.6.28> MV-643xx 10/100/1000 ethernet driver version 1.4
2.6.28> mv643xx_eth smi: probed
2.6.28> net eth1: port 0 with MAC address 00:00:00:00:00:00
2.6.28> net eth1: configured with sram
2.6.28> eth%d: 0:07 already attached
2.6.28> net eth2: port 1 with MAC address 00:0b:2f:6b:27:e2
2.6.28> net eth2: configured with sram

-- 
Alan Curry
