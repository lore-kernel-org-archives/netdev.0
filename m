From: Tom Goetz <tom.goetz@virtualcomputer.com>
Subject: Re: For the netdev list
Date: Mon, 9 May 2011 08:36:53 -0400
Message-ID: <B688A195-1023-45A1-A99C-41F7BFB6380B@virtualcomputer.com>
References: <14130884-5927-4B8D-A52E-56C245D8225B@virtualcomputer.com> <20110507182632.GA20492@electric-eye.fr.zoreil.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from server514d.exghost.com ([72.32.253.69]:1533 "EHLO
	server514.appriver.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752800Ab1EIMgz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2011 08:36:55 -0400
In-Reply-To: <20110507182632.GA20492@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On May 7, 2011, at 2:26 PM, Francois Romieu wrote:

> Tom Goetz <tom.goetz@virtualcomputer.com> :
>> We recently obtained a new a Lenovo Edge 0578-CTO. The r8169 driver causes
>> instability in the system on this machine. The problem is that in
>> rtl8169_rx_interrupt (status & 0x00001FFF) returns values less than four
> 
> This is unexpected. :o(
> 
> [...]
>> For a work around we've added a patch to drop packets when we see this
>> condition. I have attached lspci -vvv for this device and a patch for the
>> work around we're using.
> 
> Thank you for debugging.
> 
> Can you grep for the XID of the device in the kernel's dmesg and specify
> a bit of context for the problem (MTU ? features enabled through ethtool ?
> kernel version ?) ?

This is 2.6.38 PVOPs Dom0 on Xen. The distro is Ubuntu 11.04. We have not had issues with this driver in the past. This is a new issue with the Lenovo Edge.

Here's a log fragment with the XID and output from ifconfig and ethtool:

[    3.197341] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    3.197387] xen: registering gsi 17 triggering 0 polarity 1
[    3.197394] xen_map_pirq_gsi: returning irq 17 for gsi 17
[    3.197397] xen: --> irq=17
[    3.197406] Already setup the GSI :17
[    3.197412] r8169 0000:09:00.0: PCI INT A -> GSI 17 (level, low) -> IRQ 17
[    3.197524] r8169 0000:09:00.0: setting latency timer to 64
[    3.197990] r8169 0000:09:00.0: eth0: RTL8168d/8111d at 0xffffc9001117c000, e8:9a:8f:0c:6c:62, XID 083000c0 IRQ 299

eth0      Link encap:Ethernet  HWaddr e8:9a:8f:0c:6c:62  
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:1138 errors:0 dropped:0 overruns:0 frame:0
          TX packets:284 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:183700 (183.7 KB)  TX bytes:107686 (107.6 KB)
          Interrupt:43 Base address:0xc000 

root@edge-11-04:~# ethtool eth0
Settings for eth0:
	Supported ports: [ TP MII ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Half 1000baseT/Full 
	Advertised pause frame use: No
	Advertised auto-negotiation: Yes
	Link partner advertised link modes:  10baseT/Half 10baseT/Full 
	                                     100baseT/Half 100baseT/Full 
	                                     1000baseT/Full 
	Link partner advertised pause frame use: No
	Link partner advertised auto-negotiation: Yes
	Speed: 1000Mb/s
	Duplex: Full
	Port: MII
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000033 (51)
			       drv probe ifdown ifup
	Link detected: yes

-Tom



