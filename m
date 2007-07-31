From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: [BUG] ISIC + 2.6.22 (via-rhine)
Date: Tue, 31 Jul 2007 23:11:18 +0200
Message-ID: <46AFA576.1060902@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.235]:36349 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbXGaVL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 17:11:28 -0400
Received: by hu-out-0506.google.com with SMTP id 19so4387hue
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 14:11:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi,

Running  ISIC -- IP Stack Integrity Checker ( http://isic.sf.net ),
in Fedora-7-i386 with 2.6.22, the NIC stopped to send packages.
But one second latter it began to send out more of them.
dmesg shows the bug.


command is:
# tcpsic -s rand -d 172.26.0.2 -I100


driver is:
via-rhine.c:v1.10-LK1.4.3 2007-03-06 Written by Donald Becker
eth0: VIA Rhine II at 0xbc000000, 00:11:d8:54:e9:3c, IRQ 19.
eth0: MII PHY found at address 1, status 0x786d advertising 01e1 Link 45e1.
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
eth0: no IPv6 routers present

---lspci--
00:12.0 0200: 1106:3065 (rev 78)
         Subsystem: 1043:80ed
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping+ SERR- FastB2B-
         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (750ns min, 2000ns max), Cache Line Size: 32 bytes
         Interrupt: pin A routed to IRQ 19
         Region 0: I/O ports at 7000 [size=256]
         Region 1: Memory at bc000000 (32-bit, non-prefetchable) [size=256]
         Capabilities: [40] Power Management version 2
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
--end--


--dmesg output--
[...]
NETDEV WATCHDOG: eth0: transmit timed out
eth0: Transmit timed out, status 0000, PHY status 786d, resetting...

=================================
[ INFO: inconsistent lock state ]
2.6.22 #1
---------------------------------
inconsistent {in-hardirq-W} -> {hardirq-on-W} usage.
swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
  (&rp->lock){++..}, at: [<f8c890db>] rhine_tx_timeout+0x6f/0xf4 [via_rhine]
{in-hardirq-W} state was registered at:
   [<c04440d4>] __lock_acquire+0x38c/0xb12
   [<c0444c1b>] lock_acquire+0x56/0x6f
   [<c0615279>] _spin_lock+0x2b/0x38
   [<f8c87b49>] rhine_interrupt+0x16b/0x69b [via_rhine]
   [<c045aac6>] handle_IRQ_event+0x1a/0x46
   [<c045bbc0>] handle_fasteoi_irq+0x7d/0xb6
   [<c0407089>] do_IRQ+0xb1/0xd8
   [<ffffffff>] 0xffffffff
irq event stamp: 18052892
hardirqs last  enabled at (18052892): [<c061567d>] _spin_unlock_irqrestore+0x36/0x3c
hardirqs last disabled at (18052891): [<c061558d>] _spin_lock_irqsave+0x12/0x44
softirqs last  enabled at (18052876): [<c042d272>] __do_softirq+0xe3/0xe9
softirqs last disabled at (18052887): [<c0406f72>] do_softirq+0x61/0xc7

other info that might help us debug this:
1 lock held by swapper/0:
  #0:  (_xmit_ETHER){-+..}, at: [<c05c042a>] dev_watchdog+0x14/0xbf

stack backtrace:
  [<c0405e6a>] show_trace_log_lvl+0x1a/0x2f
  [<c04068cf>] show_trace+0x12/0x14
  [<c0406928>] dump_stack+0x16/0x18
  [<c0442ccd>] print_usage_bug+0x141/0x14b
  [<c04434fd>] mark_lock+0x1fd/0x409
  [<c0444144>] __lock_acquire+0x3fc/0xb12
  [<c0444c1b>] lock_acquire+0x56/0x6f
  [<c0615279>] _spin_lock+0x2b/0x38
  [<f8c890db>] rhine_tx_timeout+0x6f/0xf4 [via_rhine]
  [<c05c048c>] dev_watchdog+0x76/0xbf
  [<c04303be>] run_timer_softirq+0x11a/0x182
  [<c042d1fe>] __do_softirq+0x6f/0xe9
  [<c0406f72>] do_softirq+0x61/0xc7
  =======================
via-rhine: Reset not complete yet. Trying harder.
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
--end---



-thanks-


-- 
Politicos de mierda, yo no soy un terrorista.

