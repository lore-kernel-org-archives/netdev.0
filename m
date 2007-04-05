From: Ben Greear <greearb@candelatech.com>
Subject: pci-e e1000 not responding to ARPs sometimes?
Date: Thu, 05 Apr 2007 13:17:43 -0700
Message-ID: <46155967.1040904@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:58915 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767289AbXDEURo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 16:17:44 -0400
Received: from [192.168.100.224] (static-71-121-249-218.sttlwa.dsl-w.verizon.net [71.121.249.218])
	(authenticated bits=0)
	by ns2.lanforge.com (8.13.4/8.13.4) with ESMTP id l35KHhb9011676
	for <netdev@vger.kernel.org>; Thu, 5 Apr 2007 13:17:44 -0700
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


We're seeing some strange behavior on several systems with onboard
PCI-e pro/1000 NICs.  The behavior is generally that we cannot connect
into a system until we ping from that system out.  It often happens
with our tainted 2.6.18.2 kernel, but we also see similar problems on
the 2.6.20.? FC5 kernel.  It appears to me that the NIC gets into some
funky state where it will not receive traffic until a packet is sent
out of the interface.  After that, it works fine, at least for a while.

At this point, I am just curious if anyone else is seeing anything
similar, or if there are any known problems of this nature
with the 2.6.18 e1000 driver.

Here is lspci for one of the affected systems:


00:00.0 Host bridge: Intel Corporation Server Memory Contoller Hub (rev b1)
00:02.0 PCI bridge: Intel Corporation Server PCI Express x8 Port 2-3 (rev b1)
00:08.0 System peripheral: Intel Corporation Server DMA Controller (rev b1)
00:10.0 Host bridge: Intel Corporation Server Error Reporting Registers (rev b1)
00:10.1 Host bridge: Intel Corporation Server Error Reporting Registers (rev b1)
00:10.2 Host bridge: Intel Corporation Server Error Reporting Registers (rev b1)
00:11.0 Host bridge: Intel Corporation Reserved Registers (rev b1)
00:13.0 Host bridge: Intel Corporation Reserved Registers (rev b1)
00:15.0 Host bridge: Intel Corporation Server FBD Registers (rev b1)
00:16.0 Host bridge: Intel Corporation Server FBD Registers (rev b1)
00:1c.0 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express Root Port 1 (rev 09)
00:1d.0 USB Controller: Intel Corporation Enterprise Southbridge UHCI USB #1 (rev 09)
00:1d.1 USB Controller: Intel Corporation Enterprise Southbridge UHCI USB #2 (rev 09)
00:1d.2 USB Controller: Intel Corporation Enterprise Southbridge UHCI USB #3 (rev 09)
00:1d.3 USB Controller: Intel Corporation Enterprise Southbridge UHCI USB #4 (rev 09)
00:1d.7 USB Controller: Intel Corporation Enterprise Southbridge EHCI USB (rev 09)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev d9)
00:1f.0 ISA bridge: Intel Corporation Enterprise Southbridge LPC (rev 09)
00:1f.2 IDE interface: Intel Corporation Enterprise Southbridge SATA cc=IDE (rev 09)
00:1f.3 SMBus: Intel Corporation Enterprise Southbridge SMBus (rev 09)
01:00.0 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express Upstream Port (rev 01)
01:00.3 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express to PCI-X Bridge (rev 01)
02:00.0 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express Downstream Port E1 (rev 01)
02:02.0 PCI bridge: Intel Corporation Enterprise Southbridge PCI Express Downstream Port E3 (rev 01)
04:00.0 Ethernet controller: Intel Corporation Enterprise Southbridge DPT LAN Copper (rev 01)
04:00.1 Ethernet controller: Intel Corporation Enterprise Southbridge DPT LAN Copper (rev 01)
05:01.0 PCI bridge: IBM PCI-X to PCI-X Bridge (rev 03)
06:04.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
06:04.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
06:06.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
06:06.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet Controller (rev 03)
08:01.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

