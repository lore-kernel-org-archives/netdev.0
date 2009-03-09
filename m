From: "Gerhard Pircher" <gerhard_pircher@gmx.net>
Subject: 3c59x: shared interrupt problem
Date: Mon, 09 Mar 2009 23:42:53 +0100
Message-ID: <20090309224253.135220@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:45184 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755252AbZCIWm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 18:42:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Large network transfers fail on my machine (with kernel versions
>v2.6.26) with the kernel oops below. eth0 (3c59x driver) normally
shares its IRQ line with 3 OHCI USB ports (IRQ 7), as the excerpt of
/proc/interrupt shows. Removing USB support from the kernel makes it
work again. I wasn't able to do a full git bisect run yet, as v2.6.27
didn't produce a bootable kernel image for my machine. The machine is
an AmigaOne PowerPC G4 with an onboard 3c920 network chip.

Any idea?

best regards,

Gerhard

PS: Please put me on CC:, as I'm not subscribed to this mailing list.

/proc/interrupts:
           CPU0
  1:       1648   i8259     Level     i8042
  5:          0   i8259     Level     uhci_hcd:usb4, uhci_hcd:usb5
  6:          4   i8259     Level     floppy
  7:     236520   i8259     Level     ohci_hcd:usb1, ohci_hcd:usb2, ohc=
i_hcd:usb3, eth0
  8:          2   i8259     Level     rtc0
  9:          0   i8259     Level     eth2
 12:        117   i8259     Level     i8042
 14:       8277   i8259     Level     ide0
 15:      17559   i8259     Level     ide1
BAD:          1

Kernel log:
Badness at net/sched/sch_generic.c:226
NIP: c0250118 LR: c0250118 CTR: c0013020
REGS: efffde90 TRAP: 0700   Not tainted  (2.6.29-rc6)
MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 42024024  XER: 00000000
TASK =3D c03915a0[0] 'swapper' THREAD: c03b2000
GPR00: c0250118 efffdf40 c03915a0 00000035 00008a62 ffffffff ffffffff 0=
0000000=20
GPR08: 00000000 c03c0000 00008a62 c0393104 22024042 00000000 0ffd5900 0=
080044c=20
GPR16: 00000001 ffffffff 00000000 007ffc00 0ffd3158 0f0689b0 0ffff220 0=
07ffbc0=20
GPR24: 00000000 00000000 0000000a 00000004 efffc000 c024ffb0 00000100 e=
f847000=20
NIP [c0250118] dev_watchdog+0x168/0x244
LR [c0250118] dev_watchdog+0x168/0x244
Call Trace:
[efffdf40] [c0250118] dev_watchdog+0x168/0x244 (unreliable)
[efffdfa0] [c002f564] run_timer_softirq+0x12c/0x1b4
[efffdfd0] [c002ab0c] __do_softirq+0x6c/0x108
[efffdff0] [c0011ef0] call_do_softirq+0x14/0x24
[c03b3e90] [c0006c30] do_softirq+0x64/0x88
[c03b3eb0] [c002a968] irq_exit+0x38/0x7c
[c03b3ec0] [c000f634] timer_interrupt+0x138/0x150
[c03b3ee0] [c0012bd4] ret_from_except+0x0/0x14
--- Exception: 901 at cpu_idle+0xa4/0xec
    LR =3D cpu_idle+0x98/0xec
[c03b3fa0] [c0009f38] cpu_idle+0x4c/0xec (unreliable)
[c03b3fb0] [c0297214] __got2_end+0x58/0x68
[c03b3fc0] [c03637e4] start_kernel+0x28c/0x2a0
[c03b3ff0] [0000380c] 0x380c
Instruction dump:
80099d6c 2f800000 40be0038 38810008 7fe3fb78 38a00040 4bfee811 7fe4fb78=
=20
7c651b78 3c60c034 3863f264 4bdd6005 <0fe00000> 38000001 3d20c03c 90099d=
6c=20
eth0: transmit timed out, tx_status 00 status e601.
  diagnostics: net 0ccc media 8880 dma 0000003a fifo 0000
eth0: Interrupt posted but not delivered -- IRQ blocked by another devi=
ce?
  Flags; bus-master 1, dirty 16(0) current 16(0)
  Transmit list 00000000 vs. f101a200.
  0: @f101a200  length 80000156 status 00010156
  1: @f101a2a0  length 80000156 status 00010156
  2: @f101a340  length 80000156 status 00010156
  3: @f101a3e0  length 80000156 status 00010156
  4: @f101a480  length 80000156 status 00010156
  5: @f101a520  length 80000156 status 00010156
  6: @f101a5c0  length 80000156 status 00010156
  7: @f101a660  length 80000156 status 00010156
  8: @f101a700  length 8000003c status 0001003c
  9: @f101a7a0  length 8000003c status 0001003c
  10: @f101a840  length 8000003c status 0001003c
  11: @f101a8e0  length 8000003c status 0001003c
  12: @f101a980  length 8000003c status 0001003c
  13: @f101aa20  length 8000003c status 0001003c
  14: @f101aac0  length 80000036 status 80010036
  15: @f101ab60  length 800000f5 status 8c0100f5
eth0: Resetting the Tx ring pointer.

--=20
Psssst! Schon vom neuen GMX MultiMessenger geh=F6rt? Der kann`s mit all=
en: http://www.gmx.net/de/go/multimessenger01
