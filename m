From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: via-velocity: printk of dev->name before name has been allocated
Date: Sat, 21 Feb 2009 19:56:11 +0100
Message-ID: <49A04E4B.7080207@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay004.isp.belgacom.be ([195.238.6.170]:17426 "EHLO
	mailrelay004.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753439AbZBUS5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 13:57:53 -0500
Received: from [192.168.1.4] (athloroad.xperim.be [192.168.1.4])
	(authenticated bits=0)
	by via.xperim.be (8.14.1/8.14.1/Debian-8ubuntu1) with ESMTP id n1LIuCOT017559
	for <netdev@vger.kernel.org>; Sat, 21 Feb 2009 19:56:15 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have the following in dmesg:

[   21.212838] VIA Networking Velocity Family Gigabit Ethernet Adapter 
Driver Ver. 1.14
[   21.212847] Copyright (c) 2002, 2003 VIA Networking Technologies, Inc.
[   21.212852] Copyright (c) 2004 Red Hat Inc.
[   21.212885] ACPI: PCI Interrupt 0000:00:0e.0[A] -> GSI 18 (level, 
low) -> IRQ 17
[   21.212937] eth%d: set value of parameter Interrupt service works to 64
[   21.213684] eth0: VIA Networking Velocity Family Gigabit Ethernet Adapter
[   21.213691] eth0: Ethernet Address: 00:40:63:F4:AF:DE

The notification that the module parameter has been taken into account 
is output before the device name has been allocated. This is with the 
following kernel version:

Linux fe2 2.6.22-16-generic #1 SMP Mon Jan 26 00:07:52 GMT 2009 i686 
GNU/Linux

which is quite "old", but when I looked at current git net-2.6 I think 
that this problem is still there.

I think that the cause is that in velocity_found1(), 
velocity_get_pci_info() is called (which outputs the "set value of 
parameter" message) before register_netdev() is (which I think allocates 
the device name).

I'm afraid I'm incapable of fixing this cosmetic problem myself; perhaps 
one of you kind folk can.

Thanks, Jan

