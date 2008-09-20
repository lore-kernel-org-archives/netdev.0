From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: NetDev! Please help!
Date: Sat, 20 Sep 2008 17:19:24 +0400
Message-ID: <48D4F85C.8090709@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:54436 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751869AbYITN3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 09:29:38 -0400
Received: from localhost (localhost [127.0.0.1])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 08BC3A6C623
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2008 17:19:31 +0400 (MSD)
Received: from mail.bigtelecom.ru ([127.0.0.1])
	by localhost (mail.bigtelecom.ru [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id mi5+HSSaj6yg for <netdev@vger.kernel.org>;
	Sat, 20 Sep 2008 17:19:24 +0400 (MSD)
Received: from [87.255.0.131] (slavon.bigtelecom.ru [87.255.0.131])
	by mail.bigtelecom.ru (Postfix) with ESMTP id 5B969A6C2EB
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2008 17:19:24 +0400 (MSD)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all.

We buy 10 Intel servers and paste it to shape traffic. After 5-15 hours
all PC is was freeze!  Kernel not see TCO watchdog at this platform and
can't reboot it!. Soft Watchdog not reboot pc in this situation.  =(

At screen we see messages like this (when it freeze and i was near monitor):

http://www.kerneloops.org/guilty.php?guilty=dev_watchdog&version=2.6.26-release&start=1736704&end=1769471&class=warn

Also by netconsole we was get this one time:

[ 1352.245851] netconsole: network logging started
[ 1458.400133] 802.1Q VLAN Support v1.8 Ben Greear <greearb@candelatech.com>
[ 1458.400133] All bugs added by David S. Miller <davem@redhat.com>
[ 4956.420298] CPU 1: Machine Check Exception: 0000000000000005
[ 4956.420298] e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
[ 4956.420300]   Tx Queue             <0>
[ 4956.420300]   TDH                  <81>
[ 4956.420301]   TDT                  <81>
[ 4956.420302]   next_to_use          <81>
[ 4956.420302]   next_to_clean        <d6>
[ 4956.420303] buffer_info[next_to_clean]
[ 4956.420303]   time_stamp           <15498d>
[ 4956.420304]   next_to_watch        <d6>
[ 4956.420304]   jiffies              <15511c>
[ 4956.420305]   next_to_watch.status <1>
[ 4956.420537] eth1: Detected Tx Unit Hang:
[ 4956.420538]   TDH                  <b0>
[ 4956.420538]   TDT                  <b0>
[ 4956.420539]   next_to_use          <b0>
[ 4956.420539]   next_to_clean        <5>
[ 4956.420540] buffer_info[next_to_clean]:
[ 4956.420540]   time_stamp           <15498e>
[ 4956.420541]   next_to_watch        <5>
[ 4956.420542]   jiffies              <15511c>
[ 4956.420542]   next_to_watch.status <1>
[ 4956.423064] CPU 1: Bank 0: 3200004000000800
[ 4956.423190] CPU 1: Bank 5: 3200220024080400
[ 4956.423315] Kernel panic - not syncing: CPU context corrupt
[ 4956.423933] Rebooting in 3 seconds..[  531.843998] CPU 2: Machine
Check Exception: 0000000000000005
[  531.843998] CPU 0: Machine Check Exception: 0000000000000004
[  531.844000] CPU 0: Bank 0: 3200004000000800
[  531.844001] CPU 0: Bank 5: 3200121014040400
[  531.844002] Kernel panic - not syncing: CPU context corrupt
[  531.844916] Rebooting in 3 seconds..

This out of lspci:

00:00.0 Host bridge: Intel Corporation Server DRAM Controller
00:19.0 Ethernet controller: Intel Corporation 82566DM-2 Gigabit Network
Connection (rev 02)
00:1a.0 USB Controller: Intel Corporation USB UHCI Controller #4 (rev 02)
00:1a.1 USB Controller: Intel Corporation USB UHCI Controller #5 (rev 02)
00:1a.2 USB Controller: Intel Corporation USB UHCI Controller #6 (rev 02)
00:1a.7 USB Controller: Intel Corporation USB2 EHCI Controller #2 (rev 02)
00:1c.0 PCI bridge: Intel Corporation PCI Express Port 1 (rev 02)
00:1c.4 PCI bridge: Intel Corporation PCI Express Port 5 (rev 02)
00:1d.0 USB Controller: Intel Corporation USB UHCI Controller #1 (rev 02)
00:1d.1 USB Controller: Intel Corporation USB UHCI Controller #2 (rev 02)
00:1d.2 USB Controller: Intel Corporation USB UHCI Controller #3 (rev 02)
00:1d.7 USB Controller: Intel Corporation USB2 EHCI Controller #1 (rev 02)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
00:1f.0 ISA bridge: Intel Corporation LPC Interface Controller (rev 02)
00:1f.2 SATA controller: Intel Corporation 6 port SATA AHCI Controller
(rev 02)
00:1f.3 SMBus: Intel Corporation SMBus Controller (rev 02)
02:00.0 VGA compatible controller: Matrox Graphics, Inc. MGA G200e
[Pilot] ServerEngines (SEP1) (rev 02)
03:02.0 Ethernet controller: Intel Corporation 82541GI Gigabit Ethernet
Controller (rev 05)

lspci -tv
-[0000:00]-+-00.0  Intel Corporation Server DRAM Controller
           +-19.0  Intel Corporation 82566DM-2 Gigabit Network Connection
           +-1a.0  Intel Corporation USB UHCI Controller #4
           +-1a.1  Intel Corporation USB UHCI Controller #5
           +-1a.2  Intel Corporation USB UHCI Controller #6
           +-1a.7  Intel Corporation USB2 EHCI Controller #2
           +-1c.0-[0000:01]--
           +-1c.4-[0000:02]----00.0  Matrox Graphics, Inc. MGA G200e
[Pilot] ServerEngines (SEP1)
           +-1d.0  Intel Corporation USB UHCI Controller #1
           +-1d.1  Intel Corporation USB UHCI Controller #2
           +-1d.2  Intel Corporation USB UHCI Controller #3
           +-1d.7  Intel Corporation USB2 EHCI Controller #1
           +-1e.0-[0000:03]----02.0  Intel Corporation 82541GI Gigabit
Ethernet Controller
           +-1f.0  Intel Corporation LPC Interface Controller
           +-1f.2  Intel Corporation 6 port SATA AHCI Controller
           \-1f.3  Intel Corporation SMBus Controller

All tests in 2.6.26.2 kernel... now i try compile 2.6.26.5 kernel, but
if KernelOops is right - its not  will help.

I hope NetDev help!
If any information or test is needed - please write!

Thanks for anyone!

Badalian Vyacheslav.
