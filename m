From: Jan Kasprzak <kas@fi.muni.cz>
Subject: skge: PCI error cmd=0x117 status=0x22b0
Date: Fri, 14 Nov 2008 16:36:46 +0100
Message-ID: <20081114153646.GB7172@fi.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:60730 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305AbYKNPg6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Nov 2008 10:36:58 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hello,

I have an ASUS M2R32-MVP board with the skge network card. From time to=
 time
the network freezes with the following message (this one taken from
2.6.27-rc7, another one added even with timing information at the end
of this mail):

skge 0000:03:04.0: PCI error cmd=3D0x117 status=3D0x22b0
skge 0000:03:04.0: unable to clear error (so ignoring them)
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:219 dev_watchdog+0x11b/0x1ab()
NETDEV WATCHDOG: eth0 (skge): transmit timed out
Modules linked in: ati_remote bnep rfcomm l2cap ext4dev jbd2 crc16 flop=
py btusb bluetooth
Pid: 6, comm: ksoftirqd/1 Not tainted 2.6.27-rc7 #1

Call Trace:
 <IRQ>  [<ffffffff80245558>] warn_slowpath+0xb4/0xdc
 [<ffffffff8023bab2>] update_curr+0x3b/0x57
 [<ffffffff8023bab2>] update_curr+0x3b/0x57
 [<ffffffff8023f262>] enqueue_entity+0x1b/0xbc
 [<ffffffff80344ef9>] __next_cpu+0x19/0x26
 [<ffffffff8023f4ce>] tg_shares_up+0x172/0x18d
 [<ffffffff8023bb38>] place_entity+0x6a/0xa3
 [<ffffffff8023bf6d>] activate_task+0x29/0x3b
 [<ffffffff80240d81>] try_to_wake_up+0x16c/0x17e
 [<ffffffff8024f570>] signal_wake_up+0x24/0x33
 [<ffffffff80250555>] send_sigqueue+0x10e/0x11d
 [<ffffffff8049ba5f>] dev_watchdog+0x11b/0x1ab
 [<ffffffff80256604>] posix_timer_fn+0xa0/0xab
 [<ffffffff80256564>] posix_timer_fn+0x0/0xab
 [<ffffffff8049b944>] dev_watchdog+0x0/0x1ab
 [<ffffffff8024d5a7>] run_timer_softirq+0x151/0x1bf
 [<ffffffff80249ced>] __do_softirq+0x63/0xcc
 [<ffffffff80220f6c>] call_softirq+0x1c/0x28
 <EOI>  [<ffffffff802228fb>] do_softirq+0x2c/0x68
 [<ffffffff80249900>] ksoftirqd+0x56/0xcc
 [<ffffffff802498aa>] ksoftirqd+0x0/0xcc
 [<ffffffff8025689e>] kthread+0x47/0x73
 [<ffffffff80243247>] schedule_tail+0x27/0x5f
 [<ffffffff80220c09>] child_rip+0xa/0x11
 [<ffffffff80256857>] kthread+0x0/0x73
 [<ffffffff80220bff>] child_rip+0x0/0x11

---[ end trace 032a20d1e1b1dec2 ]---

	This happens usually when the _Tx_ network traffic is high.
The frequency is every week or two, so I don't have an easy way of
reproducing it. I have a 2.6.28-rc4 running now, so I may have
a report from the newer kernel as well soon. I have seen it also on old=
er
kernels.

	When this happens, the network on this box is dead (no packets
received nor transmitted), but the box is still alive (incl. my X sessi=
on).
I am not able to shut it down correctly, and even after I push the
reset button, it does not get past the BIOS setup. Holding the power
button for 4+ seconds makes the box switch off (except the standby powe=
r,
of course), but it still cannot boot. Only cutting off the power supply
for several seconds allows me to boot it again. So it _may_ be a hardwa=
re
problem (or the NIC needs the standby power to be cut off in order
to reset itself correctly).

	The box is AMD Athlon64 X2 6400+, AMD CrossFire Xpress 3200 + SB600
chipset, 8 GB RAM, Fedora 9. lspci of the network card is the
following:

03:04.0 Ethernet controller: Marvell Technology Group Ltd. 88E8001 Giga=
bit Ethernet Controller (rev 13)
	Subsystem: ASUSTeK Computer Inc. Marvell 88E8001 Gigabit Ethernet Cont=
roller (Asus)
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- St=
epping- SERR+ FastB2B- DisINTx-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAbort- <TA=
bort- <MAbort- >SERR- <PERR- INTx-
	Latency: 64 (5750ns min, 7750ns max), Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 23
	Region 0: Memory at fbffc000 (32-bit, non-prefetchable) [size=3D16K]
	Region 1: I/O ports at e800 [size=3D256]
	Expansion ROM at f0000000 [disabled] [size=3D128K]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=3D0mA PME(D0+,D1+,D2+,D3hot+,D=
3cold+)
		Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
	Capabilities: [50] Vital Product Data <?>
	Kernel driver in use: skge
	Kernel modules: skge

	Has anybody else seen this problem, or should I poke my HW vendor?
Thanks,

-Yenya

[ the second dmesg output ]
Nov 14 15:04:03 calypso kernel: skge 0000:03:04.0: PCI error cmd=3D0x11=
7 status=3D0x22b0
Nov 14 15:04:03 calypso kernel: skge 0000:03:04.0: unable to clear erro=
r (so ignoring them)
Nov 14 15:05:09 calypso kernel: ------------[ cut here ]------------
Nov 14 15:05:09 calypso kernel: WARNING: at net/sched/sch_generic.c:219=
 dev_watchdog+0x11b/0x1ab()
Nov 14 15:05:09 calypso kernel: NETDEV WATCHDOG: eth0 (skge): transmit =
timed out
Nov 14 15:05:09 calypso kernel: Modules linked in: udf crc_itu_t ov511 =
bnep rfcomm l2cap ext4dev jbd2 crc16 btusb bluetooth floppy
Nov 14 15:05:09 calypso kernel: Pid: 0, comm: swapper Not tainted 2.6.2=
7-rc7 #1
Nov 14 15:05:09 calypso kernel:
Nov 14 15:05:09 calypso kernel: Call Trace:
Nov 14 15:05:09 calypso kernel: <IRQ>  [<ffffffff80245558>] warn_slowpa=
th+0xb4/0xdc
Nov 14 15:05:09 calypso kernel: [<ffffffff8023f400>] tg_shares_up+0xa4/=
0x18d
Nov 14 15:05:09 calypso kernel: [<ffffffff8023bb38>] place_entity+0x6a/=
0xa3
Nov 14 15:05:09 calypso kernel: [<ffffffff80344ef9>] __next_cpu+0x19/0x=
26
Nov 14 15:05:09 calypso kernel: [<ffffffff8023db82>] find_busiest_group=
+0x315/0x7c3
Nov 14 15:05:09 calypso kernel: [<ffffffff8025b418>] getnstimeofday+0x3=
8/0x92
Nov 14 15:05:09 calypso kernel: [<ffffffff8049ba5f>] dev_watchdog+0x11b=
/0x1ab
Nov 14 15:05:09 calypso kernel: [<ffffffff8025ab97>] sched_clock_cpu+0x=
123/0x12b
Nov 14 15:05:09 calypso kernel: [<ffffffff8049b944>] dev_watchdog+0x0/0=
x1ab
Nov 14 15:05:09 calypso kernel: [<ffffffff8024d5a7>] run_timer_softirq+=
0x151/0x1bf
Nov 14 15:05:09 calypso kernel: [<ffffffff802597e2>] ktime_get+0xc/0x41
Nov 14 15:05:09 calypso kernel: [<ffffffff80249ced>] __do_softirq+0x63/=
0xcc
Nov 14 15:05:09 calypso kernel: [<ffffffff80220f6c>] call_softirq+0x1c/=
0x28
Nov 14 15:05:09 calypso kernel: [<ffffffff802228fb>] do_softirq+0x2c/0x=
68
Nov 14 15:05:09 calypso kernel: [<ffffffff80249a33>] irq_exit+0x3f/0x85
Nov 14 15:05:09 calypso kernel: [<ffffffff8022f2f9>] smp_apic_timer_int=
errupt+0x8a/0xa2
Nov 14 15:05:09 calypso kernel: [<ffffffff802209b6>] apic_timer_interru=
pt+0x66/0x70
Nov 14 15:05:09 calypso kernel: <EOI>  [<ffffffff8022ee1f>] lapic_next_=
event+0x0/0xe
Nov 14 15:05:09 calypso kernel: [<ffffffff80226437>] default_idle+0x27/=
0x3b
Nov 14 15:05:09 calypso kernel: [<ffffffff8022659e>] c1e_idle+0xd0/0xd4
Nov 14 15:05:09 calypso kernel: [<ffffffff8021ee83>] cpu_idle+0x48/0x89
Nov 14 15:05:09 calypso kernel:
Nov 14 15:05:09 calypso kernel: ---[ end trace f6cdd1d002fa89c4 ]---

--=20
| Jan "Yenya" Kasprzak  <kas at {fi.muni.cz - work | yenya.net - privat=
e}> |
| GPG: ID 1024/D3498839      Fingerprint 0D99A7FB206605D7 8B35FCDE05B18=
A5E |
| http://www.fi.muni.cz/~kas/    Journal: http://www.fi.muni.cz/~kas/bl=
og/ |
>>  If you find yourself arguing with Alan Cox, you=E2=80=99re _probabl=
y_ wrong.  <<
>>     --James Morris in "How and Why You Should Become a Kernel Hacker=
"  <<
