From: Joseph Lutz <joseph.lutz@novatechweb.com>
Subject: Issue with Micrel PCI Network Driver.
Date: Fri, 8 Feb 2013 17:17:08 -0600
Message-ID: <51158774.8080405@novatechweb.com>
Reply-To: <joseph.lutz@novatechweb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe001.messaging.microsoft.com ([65.55.88.11]:18295 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757205Ab3BHXSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 18:18:06 -0500
Received: from mail220-tx2 (localhost [127.0.0.1])	by
 mail220-tx2-R.bigfish.com (Postfix) with ESMTP id A0FBEBC030D	for
 <netdev@vger.kernel.org>; Fri,  8 Feb 2013 23:18:04 +0000 (UTC)
Received: from TX2EHSMHS041.bigfish.com (unknown [10.9.14.236])	by
 mail220-tx2.bigfish.com (Postfix) with ESMTP id C275FB800B3	for
 <netdev@vger.kernel.org>; Fri,  8 Feb 2013 23:17:12 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am having an issue with one of the network interface drivers. The 
driver in question is 'drivers/net/ethernet/micrel/ksz884x.c', the 
driver for the Micrel-Kendin device 8841.
I am trying to get systemd to rename the three network interfaces in my 
embedded atom system. I have one of the interfaces being renamed (an 
Intel Corporation 82574L), but the two Micrel interfaces are not being 
renamed. I traced this down to the driver not populating the 
/sys/devices/pci* information. Instead it places the driver into 
/sys/devices/virtual/net/.

Here are the details of the setup I am having the problem on:

     # uname -a ; lspci ; lspci -t ; ls -l /sys/class/net/
     Linux orionlx 3.2.28-rt42-0.1-default+ #1 SMP PREEMPT RT Fri Feb 8 
12:01:13 CST 2013 i686 GNU/Linux
     00:00.0 Host bridge: Intel Corporation System Controller Hub (SCH 
Poulsbo) (rev 07)
     00:02.0 VGA compatible controller: Intel Corporation System 
Controller Hub (SCH Poulsbo) Graphics Controller (rev 07)
     00:1a.0 USB Controller: Intel Corporation System Controller Hub 
(SCH Poulsbo) USB Client Controller (rev 07)
     00:1b.0 Audio device: Intel Corporation System Controller Hub (SCH 
Poulsbo) HD Audio Controller (rev 07)
     00:1c.0 PCI bridge: Intel Corporation System Controller Hub (SCH 
Poulsbo) PCI Express Port 1 (rev 07)
     00:1c.1 PCI bridge: Intel Corporation System Controller Hub (SCH 
Poulsbo) PCI Express Port 2 (rev 07)
     00:1d.0 USB Controller: Intel Corporation System Controller Hub 
(SCH Poulsbo) USB UHCI #1 (rev 07)
     00:1d.1 USB Controller: Intel Corporation System Controller Hub 
(SCH Poulsbo) USB UHCI #2 (rev 07)
     00:1d.2 USB Controller: Intel Corporation System Controller Hub 
(SCH Poulsbo) USB UHCI #3 (rev 07)
     00:1d.7 USB Controller: Intel Corporation System Controller Hub 
(SCH Poulsbo) USB EHCI #1 (rev 07)
     00:1f.0 ISA bridge: Intel Corporation System Controller Hub (SCH 
Poulsbo) LPC Bridge (rev 07)
     00:1f.1 IDE interface: Intel Corporation System Controller Hub (SCH 
Poulsbo) IDE Controller (rev 07)
     01:00.0 PCI bridge: Pericom Semiconductor Device e111 (rev 02)
     02:01.0 PCI bridge: Pericom Semiconductor 
PI7C8152A/PI7C8152B/PI7C8152BI PCI-to-PCI Bridge (rev 01)
     03:00.0 Ethernet controller: Micrel-Kendin Device 8841 (rev 10)
     03:01.0 Ethernet controller: Micrel-Kendin Device 8841 (rev 10)
     04:00.0 Ethernet controller: Intel Corporation 82574L Gigabit 
Network Connection
     -[0000:00]-+-00.0
                +-02.0
                +-1a.0
                +-1b.0
+-1c.0-[0000:01-03]----00.0-[0000:02-03]----01.0-[0000:03]--+-00.0
|                                                           \-01.0
                +-1c.1-[0000:04]----00.0
                +-1d.0
                +-1d.1
                +-1d.2
                +-1d.7
                +-1f.0
                \-1f.1
     lrwxrwxrwx    1 root     root             0 Mar 27 02:04 enp4s0 -> 
../../devices/pci0000:00/0000:00:1c.1/0000:04:00.0/net/enp4s0
     lrwxrwxrwx    1 root     root             0 Mar 27 02:04 eth1 -> 
../../devices/virtual/net/eth1
     lrwxrwxrwx    1 root     root             0 Mar 27 02:04 eth2 -> 
../../devices/virtual/net/eth2
     lrwxrwxrwx    1 root     root             0 Mar 27 02:04 lo -> 
../../devices/virtual/net/lo

This kernel is version 3.2.28 with the real-time patches applied.

If there isn't anyone available to resolve this issue I would be willing 
to assist. I just do not have any experience writing Network Drivers or 
PCI drivers. I have only written simple device drivers.

-- 
..............................................
Joseph Lutz
Software Developer
NovaTech, LLC
13555 W. 107th Street
Lenexa, KS 66215
(913) 451-1880 (main)
(913) 742-4531 (direct)
Joseph.Lutz@novatechweb.com
