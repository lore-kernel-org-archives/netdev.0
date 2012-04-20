From: Ying Cai <ycai@google.com>
Subject: Re: e1000e tx queue timeout in 3.3.0 (bisected to BQL
	support for e1000e)
Date: Thu, 19 Apr 2012 23:44:06 -0700
Message-ID: <CAL1qit9_v6082U3QXWjou=FRqa=C8BKE8LZ1qCh=FWwFt14WJA@mail.gmail.com>
References: <4F909F4B.1010707@candelatech.com>
	<CA+mtBx9ZjfC692g1EwNsw=37ijWcGBOUaENCogVS=Bi9rfz0sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4454577262072958915=="
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <CA+mtBx9ZjfC692g1EwNsw=37ijWcGBOUaENCogVS=Bi9rfz0sg@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

--===============4454577262072958915==
Content-Type: multipart/alternative; boundary=00235452fd8c6e5f9e04be169de4

--00235452fd8c6e5f9e04be169de4
Content-Type: text/plain; charset=ISO-8859-1

No, we have seen it in our test. I just checked all our Ilium machines'
/var/log/messages back to earlier to month. We got numerous "tg3 transmit
timed out" on Ilium GLAG machines only, no e1000e transmit queue timed out.

The "tg3 transmit queue timed out" does not seem to be caused by BQL, since
I can see it happen even in 420 kernel!

Apr 13 18:36:08 lpb77 kernel: [   51.684212] ------------[ cut here
]------------
Apr 13 18:36:08 lpb77 kernel: [   51.684223] WARNING: at
net/sched/sch_generic.c:263 dev_watchdog+0x1c8/0x1f0()
Apr 13 18:36:08 lpb77 kernel: [   51.684226] Hardware name: Greencreek,ESB2
Apr 13 18:36:08 lpb77 kernel: [   51.684228] NETDEV WATCHDOG: eth4 (tg3):
transmit queue 0 timed out
Apr 13 18:36:08 lpb77 kernel: [   51.684230] Modules linked in: bonding
sata_mv i2c_imch pca954x i2c_virtual uhci_hcd msr cpuid i2c_dev i2c_i801
i2c_core i2c_debug tg3 e1000e ipv6 genrtc
Apr 13 18:36:08 lpb77 kernel: [   51.684246] Pid: 0, comm: swapper Not
tainted 2.6.34-smp-420.16 #1
Apr 13 18:36:08 lpb77 kernel: [   51.684248] Call Trace:
Apr 13 18:36:08 lpb77 kernel: [   51.684251]  <IRQ>  [<ffffffff811dc939>]
warn_slowpath_common+0x7c/0xce
Apr 13 18:36:08 lpb77 kernel: [   51.684261]  [<ffffffff811dc9e2>]
warn_slowpath_fmt+0x41/0x43
Apr 13 18:36:08 lpb77 kernel: [   51.684265]  [<ffffffff811494d8>]
dev_watchdog+0x1c8/0x1f0
Apr 13 18:36:08 lpb77 kernel: [   51.684270]  [<ffffffff811f14a5>] ?
sched_clock_local+0x1c/0x82
Apr 13 18:36:08 lpb77 kernel: [   51.684275]  [<ffffffff8101826c>]
run_timer_softirq+0x34c/0x360
Apr 13 18:36:08 lpb77 kernel: [   51.684278]  [<ffffffff81149310>] ?
dev_watchdog+0x0/0x1f0
Apr 13 18:36:08 lpb77 kernel: [   51.684282]  [<ffffffff8101780e>]
__do_softirq+0x39e/0x490
Apr 13 18:36:08 lpb77 kernel: [   51.684316]  [<ffffffff81020360>] ?
tick_program_event+0x60/0x120
Apr 13 18:36:08 lpb77 kernel: [   51.684319]  [<ffffffff811f14a5>] ?
sched_clock_local+0x1c/0x82
Apr 13 18:36:08 lpb77 kernel: [   51.684323]  [<ffffffff8107770c>]
call_softirq+0x1c/0x30
Apr 13 18:36:08 lpb77 kernel: [   51.684327]  [<ffffffff810009a2>]
do_softirq+0x42/0x80
Apr 13 18:36:08 lpb77 kernel: [   51.684329]  [<ffffffff81017159>]
irq_exit+0x49/0xa0
Apr 13 18:36:08 lpb77 kernel: [   51.684334]  [<ffffffff814ac184>]
smp_apic_timer_interrupt+0x84/0xf4
Apr 13 18:36:08 lpb77 kernel: [   51.684338]  [<ffffffff810771d3>]
apic_timer_interrupt+0x13/0x20
Apr 13 18:36:08 lpb77 kernel: [   51.684339]  <EOI>  [<ffffffff811b5709>] ?
mwait_idle+0x7a/0x81
Apr 13 18:36:08 lpb77 kernel: [   51.684355]  [<ffffffff811b56bb>] ?
mwait_idle+0x2c/0x81
Apr 13 18:36:08 lpb77 kernel: [   51.684358]  [<ffffffff810005c2>]
cpu_idle+0x92/0x140
Apr 13 18:36:08 lpb77 kernel: [   51.684363]  [<ffffffff81b80a53>]
start_secondary+0x1c3/0x1c7
Apr 13 18:36:08 lpb77 kernel: [   51.684373] ---[ end trace
fc8464e86676a1b7 ]---


On Thu, Apr 19, 2012 at 7:39 PM, Tom Herbert <therbert@google.com> wrote:

> Thanks, will try to reproduce.
>
> Tom
>
> On Thu, Apr 19, 2012 at 4:27 PM, Ben Greear <greearb@candelatech.com>
> wrote:
> > Test case:
> >
> > Run full duplex traffic (900Mbps rx, 400Mbps tx) UDP traffic
> > (moderate speeds of traffic has issues as well, maybe not as easy to
> > reproduce)
> > reset peer interface
> > ----> tx queue timeout
> >
> >
> > Apr 19 16:12:48 localhost kernel: e1000e: eth2 NIC Link is Down
> > Apr 19 16:12:48 localhost kernel: e1000e 0000:08:00.0: eth2: Reset
> adapter
> > Apr 19 16:12:48 localhost kernel: e1000e: eth3 NIC Link is Down
> > Apr 19 16:12:50 localhost kernel: e1000e: eth2 NIC Link is Up 1000 Mbps
> Full
> > Duplex, Flow Control: Rx/Tx
> > Apr 19 16:12:50 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth2: link
> > becomes ready
> > Apr 19 16:12:50 localhost kernel: e1000e: eth3 NIC Link is Up 1000 Mbps
> Full
> > Duplex, Flow Control: Rx/Tx
> > Apr 19 16:12:50 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth3: link
> > becomes ready
> > Apr 19 16:12:54 localhost /usr/sbin/irqbalance: Load average increasing,
> > re-enabling all cpus for irq balancing
> > Apr 19 16:12:55 localhost kernel: ------------[ cut here ]------------
> > Apr 19 16:12:55 localhost kernel: WARNING: at
> > /home/greearb/git/linux-3.3.dev.y/net/sched/sch_generic.c:256
> > dev_watchdog+0xf4/0x154()
> > Apr 19 16:12:55 localhost kernel: Hardware name: X7DBU
> > Apr 19 16:12:55 localhost kernel: NETDEV WATCHDOG: eth2 (e1000e):
> transmit
> > queue 0 timed out
> > Apr 19 16:12:55 localhost kernel: Modules linked in: xt_CT iptable_raw
> 8021q
> > garp stp llc veth ppdev parport_pc lp parport fuse macvlan pktgen
> iscsi_tcp
> > libiscsi_tcp libiscsi scsi_transport_iscsi lockd w83793 w83627hf
> hwmon_vid
> > coretemp iTCO_wdt microcode iTCO_vendor_support pcspkr i5k_amb ioatdma
> > i2c_i801
> > i5000_edac dca edac_core e1000e shpchp uinput sunrpc ipv6 autofs4 floppy
> > radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core [last unloaded:
> > nf_nat]
> > Apr 19 16:12:55 localhost kernel: Pid: 0, comm: kworker/0:1 Not tainted
> > 3.2.0-rc2+ #36
> > Apr 19 16:12:55 localhost kernel: Call Trace:
> > Apr 19 16:12:55 localhost kernel: <IRQ>  [<ffffffff81042902>]
> > warn_slowpath_common+0x80/0x98
> > Apr 19 16:12:55 localhost kernel: [<ffffffff810429ae>]
> > warn_slowpath_fmt+0x41/0x43
> > Apr 19 16:12:55 localhost kernel: [<ffffffff8139f8a3>]
> > dev_watchdog+0xf4/0x154
> > Apr 19 16:12:55 localhost kernel: [<ffffffff8104d371>]
> > run_timer_softirq+0x16f/0x201
> > Apr 19 16:12:55 localhost kernel: [<ffffffff8139f7af>] ?
> > netif_tx_unlock+0x57/0x57
> > Apr 19 16:12:55 localhost kernel: [<ffffffff81047e47>]
> > __do_softirq+0x86/0x12f
> > Apr 19 16:12:55 localhost kernel: [<ffffffff8105d54e>] ?
> > hrtimer_interrupt+0x12b/0x1bd
> > Apr 19 16:12:55 localhost kernel: [<ffffffff8144296c>]
> > call_softirq+0x1c/0x30
> > Apr 19 16:12:55 localhost kernel: [<ffffffff8100bb75>]
> do_softirq+0x41/0x7e
> > Apr 19 16:12:55 localhost kernel: [<ffffffff81047c26>] irq_exit+0x3f/0xbb
> > Apr 19 16:12:55 localhost kernel: [<ffffffff81021df5>]
> > smp_apic_timer_interrupt+0x85/0x93
> > Apr 19 16:12:55 localhost kernel: [<ffffffff814411de>]
> > apic_timer_interrupt+0x6e/0x80
> > Apr 19 16:12:55 localhost kernel: <EOI>  [<ffffffff81010b8c>] ?
> > mwait_idle+0x6e/0x8c
> > Apr 19 16:12:55 localhost kernel: [<ffffffff81010b7f>] ?
> > mwait_idle+0x61/0x8c
> > Apr 19 16:12:55 localhost kernel: [<ffffffff81009e72>] cpu_idle+0x67/0xbe
> > Apr 19 16:12:55 localhost kernel: [<ffffffff81435477>]
> > start_secondary+0x194/0x199
> > Apr 19 16:12:55 localhost kernel: ---[ end trace e3ca12fc1a8b85da ]---
> > Apr 19 16:12:55 localhost kernel: e1000e 0000:08:00.0: eth2: Reset
> adapter
> > Apr 19 16:12:57 localhost abrt-dump-oops[898]: abrt-dump-oops: Found
> oopses:
> > 1
> > Apr 19 16:12:57 localhost abrt-dump-oops[898]: abrt-dump-oops: Creating
> dump
> > directories
> > Apr 19 16:12:57 localhost abrtd: Directory
> 'oops-2012-04-19-16:12:57-898-0'
> > creation detected
> > Apr 19 16:12:57 localhost abrt-dump-oops: Reported 1 kernel oopses to
> Abrt
> > Apr 19 16:12:57 localhost abrtd: Can't open file
> > '/var/spool/abrt/oops-2012-04-19-16:12:57-898-0/uid': No such file or
> > directory
> > Apr 19 16:12:57 localhost abrtd: DUP_OF_DIR:
> > /var/spool/abrt/oops-2012-04-19-15:02:13-862-0
> > Apr 19 16:12:57 localhost abrtd: Dump directory is a duplicate of
> > /var/spool/abrt/oops-2012-04-19-15:02:13-862-0
> > Apr 19 16:12:57 localhost abrtd: Deleting dump directory
> > oops-2012-04-19-16:12:57-898-0 (dup of oops-2012-04-19-15:02:13-862-0),
> > sending dbus signal
> > Apr 19 16:12:58 localhost kernel: e1000e: eth2 NIC Link is Up 1000 Mbps
> Full
> > Duplex, Flow Control: Rx/Tx
> > Apr 19 16:12:58 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth2: link
> > becomes ready
> > Apr 19 16:13:03 localhost /usr/sbin/irqbalance: Load average increasing,
> > re-enabling all cpus for irq balancing
> > Apr 19 16:13:04 localhost kernel: e1000e 0000:08:00.0: eth2: Reset
> adapter
> > Apr 19 16:13:05 localhost chronyd[1003]: Selected source 108.59.2.194
> > Apr 19 16:13:07 localhost kernel: e1000e: eth2 NIC Link is Up 1000 Mbps
> Full
> > Duplex, Flow Control: Rx/Tx
> > Apr 19 16:13:07 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth2: link
> > becomes ready
> > ....
> >
> > lspci:
> >
> > 08:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
> > Controller (rev 06)
> >        Subsystem: Intel Corporation PRO/1000 PT Dual Port Server Adapter
> >        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
> ParErr+
> > Stepping- SERR+ FastB2B- DisINTx+
> >        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
> > <TAbort- <MAbort- >SERR- <PERR- INTx-
> >        Latency: 0, Cache Line Size: 32 bytes
> >        Interrupt: pin A routed to IRQ 74
> >        Region 0: Memory at d8300000 (32-bit, non-prefetchable)
> [size=128K]
> >        Region 2: I/O ports at 3000 [size=32]
> >        [virtual] Expansion ROM at d8d00000 [disabled] [size=128K]
> >        Capabilities: [c8] Power Management version 2
> >                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> > PME(D0+,D1-,D2-,D3hot+,D3cold-)
> >                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
> >        Capabilities: [d0] MSI: Enable+ Count=1/1 Maskable- 64bit+
> >                Address: 00000000feeff00c  Data: 41a3
> >        Capabilities: [e0] Express (v1) Endpoint, MSI 00
> >                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
> > <512ns, L1 <64us
> >                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE- FLReset-
> >                DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+
> > Unsupported+
> >                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> >                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
> >                DevSta: CorrErr- UncorrErr+ FatalErr- UnsuppReq+ AuxPwr-
> > TransPend-
> >                LnkCap: Port #1, Speed 2.5GT/s, Width x2, ASPM L0s L1,
> > Latency L0 <4us, L1 <64us
> >                        ClockPM- Surprise- LLActRep- BwNot-
> >                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
> > CommClk-
> >                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
> >                LnkSta: Speed 2.5GT/s, Width x2, TrErr- Train- SlotClk+
> > DLActive- BWMgmt- ABWMgmt-
> >        Capabilities: [100 v1] Advanced Error Reporting
> >                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
> > RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
> >                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt-
> > RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
> >                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt-
> > RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
> >                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> > NonFatalErr-
> >                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout-
> > NonFatalErr-
> >                AERCap: First Error Pointer: 14, GenCap- CGenEn- ChkCap-
> > ChkEn-
> >        Capabilities: [140 v1] Device Serial Number
> 00-e0-ed-ff-ff-0c-11-6e
> >        Kernel driver in use: e1000e
> >        Kernel modules: e1000e
> >
> >
> > 3f0cfa3bc11e7f00c9994e0f469cbc0e7da7b00c is the first bad commit
> > commit 3f0cfa3bc11e7f00c9994e0f469cbc0e7da7b00c
> > Author: Tom Herbert <therbert@google.com>
> > Date:   Mon Nov 28 16:33:16 2011 +0000
> >
> >    e1000e: Support for byte queue limits
> >
> >    Changes to e1000e to use byte queue limits.
> >
> >    Signed-off-by: Tom Herbert <therbert@google.com>
> >    Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
> >    Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > :040000 040000 bf3e2ec64fd74253563e1ab39797b27a5f2df3fe
> > 51914e221547b95a989b5c7e9b037c9370fd734e M      drivers
> >
> >
> > Thanks,
> > Ben
> >
> > --
> > Ben Greear <greearb@candelatech.com>
> > Candela Technologies Inc  http://www.candelatech.com
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

--00235452fd8c6e5f9e04be169de4--


--===============4454577262072958915==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
--===============4454577262072958915==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4454577262072958915==--
