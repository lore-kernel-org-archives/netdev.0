From: Rick Jones <rick.jones2@hp.com>
Subject: is it a backwards compatability catch-22?
Date: Mon, 24 Apr 2006 16:47:34 -0700
Message-ID: <444D6396.4010004@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:14805 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S932128AbWDXXrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2006 19:47:35 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel12.hp.com (Postfix) with ESMTP id 60FCB3504C
	for <netdev@vger.kernel.org>; Mon, 24 Apr 2006 16:47:35 -0700 (PDT)
Received: from hp.com (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id QAA17063
	for <netdev@vger.kernel.org>; Mon, 24 Apr 2006 16:47:34 -0700 (PDT)
To: Linux Network Development list <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I might be out to lunch, certainly it happens often enough :)  I've 
spent the afternoon trying to stop my NIC names from being "random" on 
each boot.  To that end, I've been doing udev rules based on an example 
I found at http://www.debianhelp.co.uk/udev.htm  In this case I'm 
running a Debian 2.6.15-1 kernel.

It seems that the SYSTEM{address} looks for a case senstive match on the 
address (MAC) of the interface in rules like these:

lumber:~# cat /etc/udev/rules.d/010_netinterfaces.rules
KERNEL="eth*",SYSFS{address}=="00:30:6e:4c:27:3c", NAME="eth0"
KERNEL="eth*",SYSFS{address}=="00:30:6e:4c:27:3d", NAME="eth1"
KERNEL="eth*",SYSFS{address}=="00:12:79:9e:0e:d2", NAME="eth2"
KERNEL="eth*",SYSFS{address}=="00:12:79:9e:0e:d3", NAME="eth3"
KERNEL="eth*",SYSFS{address}=="00:0c:fc:00:08:71", NAME="eth4"

it seems to want lower-case hex because that is what comes out of SYSFS. (?)

Of course, ifconfig -a gives HW addresses in "uppercase" hex:

lumber:~# ifconfig -a | grep HW
eth0      Link encap:Ethernet  HWaddr 00:30:6E:4C:27:3C
eth1      Link encap:Ethernet  HWaddr 00:30:6E:4C:27:3D
eth2      Link encap:Ethernet  HWaddr 00:12:79:9E:0E:D2
eth3      Link encap:Ethernet  HWaddr 00:12:79:9E:0E:D3
eth4      Link encap:Ethernet  HWaddr 00:0C:FC:00:08:71

and some of the dmesg stuff - notably e100:

lumber:~# dmesg | grep eth
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
eth1: Tigon3 [partno(BCM95700A6) rev 0105 PHY(5701)] (PCI:66MHz:64-bit) 
10/100/1000BaseT Ethernet 00:30:6e:4c:27:3d
eth1: RXcsums[1] LinkChgREG[0] MIirq[0] ASF[0] Split[0] WireSpeed[1] 
TSOcap[0]
eth1: dma_rwctrl[76ff2d0f]
e1000: eth2: e1000_probe: Intel(R) PRO/1000 Network Connection
e100: eth3: e100_probe: addr 0x80020000, irq 57, MAC addr 00:30:6E:4C:27:3C
eth4: Neterion Xframe I 10GbE adapter (rev 4), Version Version 2.0.9.3, 
Intr type INTA
e100: eth0: e100_watchdog: link up, 100Mbps, half-duplex

While it isn't a "showstopper" it does become a bit inconvenient to have 
to "downshift" the MAC when taking it from ifconfig to use in the udev 
rules.  Any chance the two can agree on one or the other?  Or is each 
locked in a backwards compatability embrace?

rick jones

and of course, arp matches ifconfig:

lumber:~# arp -an
? (15.4.89.87) at 00:12:79:94:F8:24 [ether] on eth0
? (15.4.88.1) at 00:00:0C:07:AC:00 [ether] on eth0

not that arp in and of itself matters in this situation.
