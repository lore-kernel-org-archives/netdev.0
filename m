From: Tom Herbert <therbert@google.com>
Subject: Re: e1000e tx queue timeout in 3.3.0 (bisected to BQL
	support for e1000e)
Date: Fri, 20 Apr 2012 12:05:46 -0700
Message-ID: <CA+mtBx9s70wawA4E3+LyOQhJXRr1y-0j_Pzno5bBSz8TS3SUOA@mail.gmail.com>
References: <4F909F4B.1010707@candelatech.com>
	<CA+mtBx9ZjfC692g1EwNsw=37ijWcGBOUaENCogVS=Bi9rfz0sg@mail.gmail.com>
	<4F91B250.8090509@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel list <e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <4F91B250.8090509@candelatech.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> I am seeing something similar with the 'igb' driver, though this
> NIC also involves a side-driver that does bypass. =A0When I enable/disable
> bypass, the links bounce (as expected), and igb reports the same
> timeout that I was seeing with e1000e.
>

Hi Ben,

Are the circumstances the same between igb and e1000e for the issue?
That is in both cases are links being bounced or reset?

Thanks,
Tom

> If I revert the igb BQL patch, then it works fine (kernel 3.3.2+).
>
> I did not do an exhaustive bisect, nor have tested non-bypass
> igb hardware, but since reverting the patch fixes the problem....
>
> Maybe there is some fundamental issue with BQL when a NIC
> resets itself (in this case, due to remote port doing
> a reset) =A0Maybe we are not properly accounting pkts cleared
> from the xmit queue on reset or something of that nature?
>
> I'm happy to test patches of someone has suggestions...
>
> Thanks,
> Ben
>
>
>>
>> Tom
>>
>> On Thu, Apr 19, 2012 at 4:27 PM, Ben Greear<greearb@candelatech.com>
>> =A0wrote:
>>>
>>> Test case:
>>>
>>> Run full duplex traffic (900Mbps rx, 400Mbps tx) UDP traffic
>>> (moderate speeds of traffic has issues as well, maybe not as easy to
>>> reproduce)
>>> reset peer interface
>>> ----> =A0tx queue timeout
>>>
>>>
>>> Apr 19 16:12:48 localhost kernel: e1000e: eth2 NIC Link is Down
>>> Apr 19 16:12:48 localhost kernel: e1000e 0000:08:00.0: eth2: Reset
>>> adapter
>>> Apr 19 16:12:48 localhost kernel: e1000e: eth3 NIC Link is Down
>>> Apr 19 16:12:50 localhost kernel: e1000e: eth2 NIC Link is Up 1000 Mbps
>>> Full
>>> Duplex, Flow Control: Rx/Tx
>>> Apr 19 16:12:50 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth2: link
>>> becomes ready
>>> Apr 19 16:12:50 localhost kernel: e1000e: eth3 NIC Link is Up 1000 Mbps
>>> Full
>>> Duplex, Flow Control: Rx/Tx
>>> Apr 19 16:12:50 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth3: link
>>> becomes ready
>>> Apr 19 16:12:54 localhost /usr/sbin/irqbalance: Load average increasing,
>>> re-enabling all cpus for irq balancing
>>> Apr 19 16:12:55 localhost kernel: ------------[ cut here ]------------
>>> Apr 19 16:12:55 localhost kernel: WARNING: at
>>> /home/greearb/git/linux-3.3.dev.y/net/sched/sch_generic.c:256
>>> dev_watchdog+0xf4/0x154()
>>> Apr 19 16:12:55 localhost kernel: Hardware name: X7DBU
>>> Apr 19 16:12:55 localhost kernel: NETDEV WATCHDOG: eth2 (e1000e):
>>> transmit
>>> queue 0 timed out
>>> Apr 19 16:12:55 localhost kernel: Modules linked in: xt_CT iptable_raw
>>> 8021q
>>> garp stp llc veth ppdev parport_pc lp parport fuse macvlan pktgen
>>> iscsi_tcp
>>> libiscsi_tcp libiscsi scsi_transport_iscsi lockd w83793 w83627hf
>>> hwmon_vid
>>> coretemp iTCO_wdt microcode iTCO_vendor_support pcspkr i5k_amb ioatdma
>>> i2c_i801
>>> i5000_edac dca edac_core e1000e shpchp uinput sunrpc ipv6 autofs4 floppy
>>> radeon ttm drm_kms_helper drm hwmon i2c_algo_bit i2c_core [last unloade=
d:
>>> nf_nat]
>>> Apr 19 16:12:55 localhost kernel: Pid: 0, comm: kworker/0:1 Not tainted
>>> 3.2.0-rc2+ #36
>>> Apr 19 16:12:55 localhost kernel: Call Trace:
>>> Apr 19 16:12:55 localhost kernel:<IRQ> =A0 =A0[<ffffffff81042902>]
>>> warn_slowpath_common+0x80/0x98
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff810429ae>]
>>> warn_slowpath_fmt+0x41/0x43
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff8139f8a3>]
>>> dev_watchdog+0xf4/0x154
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff8104d371>]
>>> run_timer_softirq+0x16f/0x201
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff8139f7af>] ?
>>> netif_tx_unlock+0x57/0x57
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff81047e47>]
>>> __do_softirq+0x86/0x12f
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff8105d54e>] ?
>>> hrtimer_interrupt+0x12b/0x1bd
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff8144296c>]
>>> call_softirq+0x1c/0x30
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff8100bb75>]
>>> do_softirq+0x41/0x7e
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff81047c26>] irq_exit+0x3f/0x=
bb
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff81021df5>]
>>> smp_apic_timer_interrupt+0x85/0x93
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff814411de>]
>>> apic_timer_interrupt+0x6e/0x80
>>> Apr 19 16:12:55 localhost kernel:<EOI> =A0 =A0[<ffffffff81010b8c>] ?
>>> mwait_idle+0x6e/0x8c
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff81010b7f>] ?
>>> mwait_idle+0x61/0x8c
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff81009e72>] cpu_idle+0x67/0x=
be
>>> Apr 19 16:12:55 localhost kernel: [<ffffffff81435477>]
>>> start_secondary+0x194/0x199
>>> Apr 19 16:12:55 localhost kernel: ---[ end trace e3ca12fc1a8b85da ]---
>>> Apr 19 16:12:55 localhost kernel: e1000e 0000:08:00.0: eth2: Reset
>>> adapter
>>> Apr 19 16:12:57 localhost abrt-dump-oops[898]: abrt-dump-oops: Found
>>> oopses:
>>> 1
>>> Apr 19 16:12:57 localhost abrt-dump-oops[898]: abrt-dump-oops: Creating
>>> dump
>>> directories
>>> Apr 19 16:12:57 localhost abrtd: Directory
>>> 'oops-2012-04-19-16:12:57-898-0'
>>> creation detected
>>> Apr 19 16:12:57 localhost abrt-dump-oops: Reported 1 kernel oopses to
>>> Abrt
>>> Apr 19 16:12:57 localhost abrtd: Can't open file
>>> '/var/spool/abrt/oops-2012-04-19-16:12:57-898-0/uid': No such file or
>>> directory
>>> Apr 19 16:12:57 localhost abrtd: DUP_OF_DIR:
>>> /var/spool/abrt/oops-2012-04-19-15:02:13-862-0
>>> Apr 19 16:12:57 localhost abrtd: Dump directory is a duplicate of
>>> /var/spool/abrt/oops-2012-04-19-15:02:13-862-0
>>> Apr 19 16:12:57 localhost abrtd: Deleting dump directory
>>> oops-2012-04-19-16:12:57-898-0 (dup of oops-2012-04-19-15:02:13-862-0),
>>> sending dbus signal
>>> Apr 19 16:12:58 localhost kernel: e1000e: eth2 NIC Link is Up 1000 Mbps
>>> Full
>>> Duplex, Flow Control: Rx/Tx
>>> Apr 19 16:12:58 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth2: link
>>> becomes ready
>>> Apr 19 16:13:03 localhost /usr/sbin/irqbalance: Load average increasing,
>>> re-enabling all cpus for irq balancing
>>> Apr 19 16:13:04 localhost kernel: e1000e 0000:08:00.0: eth2: Reset
>>> adapter
>>> Apr 19 16:13:05 localhost chronyd[1003]: Selected source 108.59.2.194
>>> Apr 19 16:13:07 localhost kernel: e1000e: eth2 NIC Link is Up 1000 Mbps
>>> Full
>>> Duplex, Flow Control: Rx/Tx
>>> Apr 19 16:13:07 localhost kernel: ADDRCONF(NETDEV_CHANGE): eth2: link
>>> becomes ready
>>> ....
>>>
>>> lspci:
>>>
>>> 08:00.0 Ethernet controller: Intel Corporation 82571EB Gigabit Ethernet
>>> Controller (rev 06)
>>> =A0 =A0 =A0 =A0Subsystem: Intel Corporation PRO/1000 PT Dual Port Serve=
r Adapter
>>> =A0 =A0 =A0 =A0Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASno=
op-
>>> ParErr+
>>> Stepping- SERR+ FastB2B- DisINTx+
>>> =A0 =A0 =A0 =A0Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=3Dfast>=
TAbort-
>>> <TAbort-<MAbort->SERR-<PERR- INTx-
>>> =A0 =A0 =A0 =A0Latency: 0, Cache Line Size: 32 bytes
>>> =A0 =A0 =A0 =A0Interrupt: pin A routed to IRQ 74
>>> =A0 =A0 =A0 =A0Region 0: Memory at d8300000 (32-bit, non-prefetchable)
>>> [size=3D128K]
>>> =A0 =A0 =A0 =A0Region 2: I/O ports at 3000 [size=3D32]
>>> =A0 =A0 =A0 =A0[virtual] Expansion ROM at d8d00000 [disabled] [size=3D1=
28K]
>>> =A0 =A0 =A0 =A0Capabilities: [c8] Power Management version 2
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Flags: PMEClk- DSI+ D1- D2- AuxCurrent=
=3D0mA
>>> PME(D0+,D1-,D2-,D3hot+,D3cold-)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Status: D0 NoSoftRst- PME-Enable- DSel=
=3D0 DScale=3D1 PME-
>>> =A0 =A0 =A0 =A0Capabilities: [d0] MSI: Enable+ Count=3D1/1 Maskable- 64=
bit+
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Address: 00000000feeff00c =A0Data: 41a3
>>> =A0 =A0 =A0 =A0Capabilities: [e0] Express (v1) Endpoint, MSI 00
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCap: MaxPayload 256 bytes, PhantFunc =
0, Latency L0s
>>> <512ns, L1<64us
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ExtTag- AttnBtn- AttnInd=
- PwrInd- RBE- FLReset-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevCtl: Report errors: Correctable+ Non-=
Fatal+ Fatal+
>>> Unsupported+
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RlxdOrd+ ExtTag- PhantFu=
nc- AuxPwr- NoSnoop+
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0MaxPayload 128 bytes, Ma=
xReadReq 4096 bytes
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0DevSta: CorrErr- UncorrErr+ FatalErr- Un=
suppReq+ AuxPwr-
>>> TransPend-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkCap: Port #1, Speed 2.5GT/s, Width x2=
, ASPM L0s L1,
>>> Latency L0<4us, L1<64us
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ClockPM- Surprise- LLAct=
Rep- BwNot-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkCtl: ASPM Disabled; RCB 64 bytes Disa=
bled- Retrain-
>>> CommClk-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ExtSynch- ClockPM- AutWi=
dDis- BWInt- AutBWInt-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0LnkSta: Speed 2.5GT/s, Width x2, TrErr- =
Train- SlotClk+
>>> DLActive- BWMgmt- ABWMgmt-
>>> =A0 =A0 =A0 =A0Capabilities: [100 v1] Advanced Error Reporting
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UESta: =A0DLP- SDES- TLP- FCP- CmpltTO- =
CmpltAbrt- UnxCmplt-
>>> RxOF- MalfTLP- ECRC- UnsupReq+ ACSViol-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UEMsk: =A0DLP- SDES- TLP- FCP- CmpltTO- =
CmpltAbrt- UnxCmplt-
>>> RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- Cm=
pltAbrt- UnxCmplt-
>>> RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CESta: =A0RxErr- BadTLP- BadDLLP- Rollov=
er- Timeout-
>>> NonFatalErr-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CEMsk: =A0RxErr- BadTLP- BadDLLP- Rollov=
er- Timeout-
>>> NonFatalErr-
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0AERCap: First Error Pointer: 14, GenCap-=
 CGenEn- ChkCap-
>>> ChkEn-
>>> =A0 =A0 =A0 =A0Capabilities: [140 v1] Device Serial Number
>>> 00-e0-ed-ff-ff-0c-11-6e
>>> =A0 =A0 =A0 =A0Kernel driver in use: e1000e
>>> =A0 =A0 =A0 =A0Kernel modules: e1000e
>>>
>>>
>>> 3f0cfa3bc11e7f00c9994e0f469cbc0e7da7b00c is the first bad commit
>>> commit 3f0cfa3bc11e7f00c9994e0f469cbc0e7da7b00c
>>> Author: Tom Herbert<therbert@google.com>
>>> Date: =A0 Mon Nov 28 16:33:16 2011 +0000
>>>
>>> =A0 =A0e1000e: Support for byte queue limits
>>>
>>> =A0 =A0Changes to e1000e to use byte queue limits.
>>>
>>> =A0 =A0Signed-off-by: Tom Herbert<therbert@google.com>
>>> =A0 =A0Acked-by: Eric Dumazet<eric.dumazet@gmail.com>
>>> =A0 =A0Signed-off-by: David S. Miller<davem@davemloft.net>
>>>
>>> :040000 040000 bf3e2ec64fd74253563e1ab39797b27a5f2df3fe
>>> 51914e221547b95a989b5c7e9b037c9370fd734e M =A0 =A0 =A0drivers
>>>
>>>
>>> Thanks,
>>> Ben
>>>
>>> --
>>> Ben Greear<greearb@candelatech.com>
>>> Candela Technologies Inc =A0http://www.candelatech.com
>>>
>
>
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc =A0http://www.candelatech.com
>

---------------------------------------------------------------------------=
---
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.co=
m/community/wired
