From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 11:04:00 +0100
Message-ID: <1226484240.6834.47.camel@localhost.localdomain>
References: <20081111.155041.90523159.davem@davemloft.net>
	 <20081111.161849.251632080.davem@davemloft.net>
	 <1226482593.6834.43.camel@localhost.localdomain>
	 <20081112.014923.68124784.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:43253 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbYKLKEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 05:04:11 -0500
In-Reply-To: <20081112.014923.68124784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 01:49 -0800, David Miller wrote:
> From: Jesper Dangaard Brouer <jdb@comx.dk>
> Date: Wed, 12 Nov 2008 10:36:33 +0100
>
> Oddly, you tried without MSI enabled (do I remember right ?) and that
> still failed, so it doesn't seem like it could be a MSI specific
> problem.

Yes, I have tried to disable MSI.

> Get the dump from the patch I sent and I should be able to have some
> idea why this problem might be happening.

------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x21e/0x230()
NETDEV WATCHDOG: eth2 (niu): transmit timed out
Modules linked in: niu rng_core hpilo bnx2 serio_raw ipmi_si ipmi_msghandler hpwdt zlib_inflate ehci_hcd uhci_hcd sr_mod cdrom [last unloaded: nxge]
Pid: 0, comm: swapper Not tainted 2.6.28-rc2-davem #15
Call Trace:
 [<c01256a3>] warn_slowpath+0x63/0x80
 [<c011ef6e>] ? __enqueue_entity+0x8e/0xb0
 [<c0145154>] ? __lock_acquire+0x104/0x8e0
 [<c0144899>] ? lock_release_holdtime+0x79/0xc0
 [<c021fb4e>] ? strlcpy+0x1e/0x60
 [<c031f2ae>] dev_watchdog+0x21e/0x230
 [<c0144899>] ? lock_release_holdtime+0x79/0xc0
 [<c012e33d>] ? run_timer_softirq+0x10d/0x190
 [<c012e34f>] run_timer_softirq+0x11f/0x190
 [<c014333c>] ? tick_dev_program_event+0x3c/0xc0
 [<c031f090>] ? dev_watchdog+0x0/0x230
 [<c012a084>] __do_softirq+0x94/0x160
 [<c013c4c0>] ? hrtimer_interrupt+0x150/0x180
 [<c012a18b>] do_softirq+0x3b/0x50
 [<c012a395>] irq_exit+0x75/0x90
 [<c011365a>] smp_apic_timer_interrupt+0x5a/0x90
 [<c013c2ca>] ? hrtimer_start+0x1a/0x20
 [<c0103f0c>] apic_timer_interrupt+0x28/0x30
 [<c01090e5>] ? mwait_idle+0x35/0x40
 [<c0101c1e>] cpu_idle+0x4e/0xa0
---[ end trace aebd29b927afeb8b ]---
niu 0000:0b:00.0: niu: eth2: Transmit timed out, resetting
niu 0000:0b:00.0: niu: eth2: LDG[idx(0):num(0)] V0[sw(0x0)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: LDG[idx(1):num(1)] V0[sw(0x0)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: LDG[idx(2):num(2)] V0[sw(0x0)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: LDG[idx(3):num(3)] V0[sw(0x1)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: LDG[idx(4):num(4)] V0[sw(0x0)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: LDG[idx(5):num(5)] V0[sw(0x0)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: LDG[idx(6):num(6)] V0[sw(0x0)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: LDG[idx(7):num(7)] V0[sw(0x0)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: LDG[idx(8):num(8)] V0[sw(0x0)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: LDG[idx(9):num(9)] V0[sw(0x400000000)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: Dumping transmitter state.
niu 0000:0b:00.0: niu: eth2: TX_RING[ 0] CHANNEL 0 LDN 32
niu 0000:0b:00.0: niu: eth2: TX_RING[ 0] parent->lgd_map[ldn] 7
niu 0000:0b:00.0: niu: eth2: TX_RING[ 0] Num pending TX SKBs: 3
niu 0000:0b:00.0: niu: eth2: TX_RING[ 0] TX_CS sw[0000000000000000] hw[0003000000000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 1] CHANNEL 1 LDN 33
niu 0000:0b:00.0: niu: eth2: TX_RING[ 1] parent->lgd_map[ldn] 8
niu 0000:0b:00.0: niu: eth2: TX_RING[ 1] Num pending TX SKBs: 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 1] TX_CS sw[0000000000000000] hw[0000000000000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 2] CHANNEL 2 LDN 34
niu 0000:0b:00.0: niu: eth2: TX_RING[ 2] parent->lgd_map[ldn] 9
niu 0000:0b:00.0: niu: eth2: TX_RING[ 2] Num pending TX SKBs: 237
niu 0000:0b:00.0: niu: eth2: TX_RING[ 2] TX_CS sw[00c000bf00000000] hw[00ed00bf00000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 3] CHANNEL 3 LDN 35
niu 0000:0b:00.0: niu: eth2: TX_RING[ 3] parent->lgd_map[ldn] 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 3] Num pending TX SKBs: 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 3] TX_CS sw[0000000000000000] hw[0000000000000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] CHANNEL 4 LDN 36
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] parent->lgd_map[ldn] 1
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] Num pending TX SKBs: 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] TX_CS sw[0000000000000000] hw[0000000000000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] CHANNEL 5 LDN 37
niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] parent->lgd_map[ldn] 2
niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] Num pending TX SKBs: 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] TX_CS sw[0000000000000000] hw[0000000000000000]

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer
