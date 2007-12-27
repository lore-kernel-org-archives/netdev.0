From: Costa Tsaousis <costa@tsaousis.gr>
Subject: sunhme x86 SMP issues
Date: Thu, 27 Dec 2007 11:00:57 +0200
Message-ID: <477369C9.7030405@tsaousis.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ppp.tsaousis.gr ([195.97.5.206]:61884 "EHLO ppp.tsaousis.gr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751074AbXL0Jdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2007 04:33:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by ppp.tsaousis.gr (Postfix) with ESMTP id 0DFD130709D
	for <netdev@vger.kernel.org>; Thu, 27 Dec 2007 11:01:01 +0200 (EET)
Received: from ppp.tsaousis.gr ([127.0.0.1])
	by localhost (ppp.tsaousis.gr [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id L-vESEp7p2I6 for <netdev@vger.kernel.org>;
	Thu, 27 Dec 2007 11:00:58 +0200 (EET)
Received: from [10.10.10.194] (arete.tsaousis.gr [10.10.10.194])
	by ppp.tsaousis.gr (Postfix) with ESMTP id 8238130709C
	for <netdev@vger.kernel.org>; Thu, 27 Dec 2007 11:00:58 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Merry Christams,

I would like to report incompatibilities of the sunhme driver with x86 SMP.

My configuration:
Tyan S2466 motherboard with 2x Athlon MP 2400+
Kernel: 2.6.23-gentoo-r3

lscpi:
00:00.0 Host bridge: Advanced Micro Devices [AMD] AMD-760 MP [IGD4-2P] 
System Controller (rev 20)
00:01.0 PCI bridge: Advanced Micro Devices [AMD] AMD-760 MP [IGD4-2P] 
AGP Bridge
00:07.0 ISA bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] ISA (rev 05)
00:07.1 IDE interface: Advanced Micro Devices [AMD] AMD-768 [Opus] IDE 
(rev 04)
00:07.3 Bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] ACPI (rev 03)
00:08.0 Mass storage controller: Promise Technology, Inc. 20269 (rev 02)
00:09.0 Mass storage controller: Promise Technology, Inc. 20269 (rev 02)
00:10.0 PCI bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] PCI (rev 05)
01:05.0 VGA compatible controller: nVidia Corporation NV36.2 [GeForce FX 
5700] (rev a1)
02:00.0 USB Controller: Advanced Micro Devices [AMD] AMD-768 [Opus] USB 
(rev 07)
02:05.0 PCI bridge: Digital Equipment Corporation DECchip 21153 (rev 04)
02:06.0 Multimedia audio controller: Creative Labs SB Live! EMU10k1 (rev 08)
02:06.1 Input device controller: Creative Labs SB Live! Game Port (rev 08)
02:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 
Gigabit Ethernet (rev 10)
02:08.0 Ethernet controller: 3Com Corporation 3c905C-TX/TX-M [Tornado] 
(rev 78)
03:00.0 Bridge: Sun Microsystems Computer Corp. EBUS (rev 01)
03:00.1 Ethernet controller: Sun Microsystems Computer Corp. Happy Meal 
10/100 Ethernet [hme] (rev 01)
03:01.0 Bridge: Sun Microsystems Computer Corp. EBUS (rev 01)
03:01.1 Ethernet controller: Sun Microsystems Computer Corp. Happy Meal 
10/100 Ethernet [hme] (rev 01)
03:02.0 Bridge: Sun Microsystems Computer Corp. EBUS (rev 01)
03:02.1 Ethernet controller: Sun Microsystems Computer Corp. Happy Meal 
10/100 Ethernet [hme] (rev 01)
03:03.0 Bridge: Sun Microsystems Computer Corp. EBUS (rev 01)
03:03.1 Ethernet controller: Sun Microsystems Computer Corp. Happy Meal 
10/100 Ethernet [hme] (rev 01)

Sunhme (4 ports) and RTL-8169 (1 port) are configured as an Ethernet bridge.

The problem:
When transfering large files from one hme port to another, the machine 
temporarily freezes for a few seconds. Even the ssh sessions, the mouse, 
and the machine clock are completelly paused. After a few seconds the 
machine recovers without kernel errors or messages in most cases. These 
freezes appear continuously as far as the transfer is in place.

The problem relaxes a bit with 'noapic' but still happens.
The problem does not appear when the kernel is booted with maxcpus=0.
With maxcpus=1 the problem is that hme ports become almost unusable 
(like huge packet loss).

The problem does not appear when the machine is routing traffic from a 
non bridged Ethernet to an hme port.

I have tried several different kernel boot options and configurations, 
without founding any solution. Check this thread: 
http://forums.gentoo.org/viewtopic-t-635999-start-0-postdays-0-postorder-asc-highlight-.html?sid=275e5b2a0faea0c878b2a27fe7b83523

I am not subscribed to the list, so please CC me in replies.

Thanks,

Costa

