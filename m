From: Jesper Dangaard Brouer <jdb@comx.dk>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 12:01:50 +0100
Message-ID: <1226487710.6834.53.camel@localhost.localdomain>
References: <20081111.155041.90523159.davem@davemloft.net>
	 <20081111.161849.251632080.davem@davemloft.net>
	 <1226482593.6834.43.camel@localhost.localdomain>
	 <20081112.014923.68124784.davem@davemloft.net>
Reply-To: jdb@comx.dk
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:46978 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315AbYKLLCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 06:02:01 -0500
In-Reply-To: <20081112.014923.68124784.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 01:49 -0800, David Miller wrote:
> Oddly, you tried without MSI enabled (do I remember right ?) and that
> still failed, so it doesn't seem like it could be a MSI specific
> problem.

Just to be absolutly sure that MSI got disabled, I have compiled a
kernel without SMP and without MSI support.

This kernel still shows the problem.

dcu-router-ng:~# cat /proc/interrupts 
           CPU0       
  0:     373724    XT-PIC-XT        timer
  1:          2    XT-PIC-XT        i8042
  2:          0    XT-PIC-XT        cascade
  3:          7    XT-PIC-XT        serial
  5:       4539    XT-PIC-XT        uhci_hcd:usb1, ehci_hcd:usb6, ipmi_si, eth0, eth2
  7:          0    XT-PIC-XT        uhci_hcd:usb2, eth3
  9:          0    XT-PIC-XT        acpi
 10:      40319    XT-PIC-XT        cciss0, uhci_hcd:usb3, uhci_hcd:usb4, uhci_hcd:usb5
 12:          4    XT-PIC-XT        i8042
 14:         58    XT-PIC-XT        ata_piix
 15:          0    XT-PIC-XT        ata_piix
NMI:          0   Non-maskable interrupts
TRM:          0   Thermal event interrupts
ERR:          0


niu: disagrees about version of symbol struct_module
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:226 dev_watchdog+0x221/0x230()
NETDEV WATCHDOG: eth2 (niu): transmit timed out
Modules linked in: serio_raw ipmi_si ipmi_msghandler hpilo hpwdt rng_core ehci_hcd uhci_hcd bnx2 zlib_inflate niu sr_mod cdrom
Pid: 0, comm: swapper Not tainted 2.6.28-rc4-davem-nosmp #16
Call Trace:
 [<c0118fe3>] warn_slowpath+0x63/0x80
 [<c0130030>] ? down_interruptible+0x30/0x50
 [<c0136249>] ? lock_release_holdtime+0x79/0xc0
 [<c0132ffb>] ? clocksource_get_next+0x3b/0x50
 [<c0107fbc>] ? native_sched_clock+0x1c/0x70
 [<c0136abd>] ? __lock_acquire+0xfd/0x8e0
 [<c0136abd>] ? __lock_acquire+0xfd/0x8e0
 [<c0136abd>] ? __lock_acquire+0xfd/0x8e0
 [<c0136249>] ? lock_release_holdtime+0x79/0xc0
 [<c020c87e>] ? strlcpy+0x1e/0x60
 [<c0308f71>] dev_watchdog+0x221/0x230
 [<c0136249>] ? lock_release_holdtime+0x79/0xc0
 [<c01217d7>] ? run_timer_softirq+0x107/0x180
 [<c01217e9>] run_timer_softirq+0x119/0x180
 [<c0308d50>] ? dev_watchdog+0x0/0x230
 [<c011d754>] __do_softirq+0x64/0x110
 [<c014d660>] ? handle_level_irq+0xa0/0xd0
 [<c011d82b>] do_softirq+0x2b/0x40
 [<c011dac5>] irq_exit+0x65/0x80
 [<c0104c16>] do_IRQ+0x46/0x80
 [<c0103d6f>] common_interrupt+0x23/0x28
 [<c0108800>] ? mwait_idle+0x30/0x40
 [<c0101c01>] cpu_idle+0x31/0x80
 [<c035aa61>] rest_init+0x61/0x70
---[ end trace d500bfdcd991627f ]---
niu 0000:0b:00.0: niu: eth2: Transmit timed out, resetting
niu 0000:0b:00.0: niu: eth2: LDG[idx(0):num(0)] V0[sw(0x1)hw(0x0)] V1[sw(0x0)hw(0x0)] V2[sw(0x0)hw(0x0)]
niu 0000:0b:00.0: niu: eth2: Dumping transmitter state.
niu 0000:0b:00.0: niu: eth2: TX_RING[ 0] CHANNEL 0 LDN 32
niu 0000:0b:00.0: niu: eth2: TX_RING[ 0] parent->lgd_map[ldn] 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 0] Num pending TX SKBs: 2
niu 0000:0b:00.0: niu: eth2: TX_RING[ 0] TX_CS sw[0000000000000000] hw[0002000000000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 1] CHANNEL 1 LDN 33
niu 0000:0b:00.0: niu: eth2: TX_RING[ 1] parent->lgd_map[ldn] 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 1] Num pending TX SKBs: 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 1] TX_CS sw[0000000000000000] hw[0000000000000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 2] CHANNEL 2 LDN 34
niu 0000:0b:00.0: niu: eth2: TX_RING[ 2] parent->lgd_map[ldn] 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 2] Num pending TX SKBs: 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 2] TX_CS sw[0000000000000000] hw[0000000000000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 3] CHANNEL 3 LDN 35
niu 0000:0b:00.0: niu: eth2: TX_RING[ 3] parent->lgd_map[ldn] 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 3] Num pending TX SKBs: 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 3] TX_CS sw[0000000000000000] hw[0000000000000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] CHANNEL 4 LDN 36
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] parent->lgd_map[ldn] 0
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] Num pending TX SKBs: 237
niu 0000:0b:00.0: niu: eth2: TX_RING[ 4] TX_CS sw[00c000bf00000000] hw[00ed00bf00000000]
niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] CHANNEL 5 LDN 37
niu 0000:0b:00.0: niu: eth2: TX_RING[ 5] parent->lgd_map[ldn] 0
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
