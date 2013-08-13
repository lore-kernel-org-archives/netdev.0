From: Peter Zijlstra <peterz@infradead.org>
Subject: r8169 OOPSen in rtl_rx
Date: Tue, 13 Aug 2013 11:43:14 +0200
Message-ID: <20130813094314.GW3008@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: nic_swsd@realtek.com, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:49321 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619Ab3HMJnX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:43:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi r8169 people,

I've got an AMD x86_64 machine with two realtek NICs:

01:08.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 06)

I currently run a 3.10.0.6 based kernel on the machine and frequently
(several times a week) get OOPSen in the rtl_rx path. Now the horribly
sad part is that this machine doesn't (currently) have a working serial
line -- its got pins on the board but I need to go hunt for an expansion
bracket for it :/

I recently added the RTL8111 (rev 6) card so that this machine could
do firewall duties (it was a general server using the RTL-8169 for a
long time before that and always ran without problems).

I have tried netconsole, but that's not working, which leads me to
believe its the inward-facing NIC that's buggered -- which would be the
RTL-8169 (rev 10) -- pure speculation though, it could just crash hard
enough for nothing to really work anymore.

The video-card also doesn't support 80x50/60 text modes and
KMS/framebuffer also didn't work (as in, I get graphics based text at
high res but OOPSen don't actually make it to the screen).

So all I've got to offer currently is a partial backtrace -- see
attached image. Partial transcribe:

  ? rtl8169_try_rx_copy.isra.77
  rtl_rx
  rtl8169_poll
  net_rx_action
  ? get_vtime_delta
  __do_softirq
  irq_exit
  do_IRQ
  common_interrupt
  ? native_safe_halt
  ? rcu_eqs_enter_common.isra.48
  default_idle
  amd_e400_idle
  arch_cpu_idle
  cpu_idle_loop
  ...

I did look at the r8169 log between 3.10 and current head and there
wasn't anything obviously related to RX crashes so I haven't upgraded to
3.11-rc; if you think I should try please say so.

I'm also willing to try patches -- although as said, reproduction can
take a few days -- although sometimes I'm 'lucky' and it crashes
multiple times a day :/

~ Peter
