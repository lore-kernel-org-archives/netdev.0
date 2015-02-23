From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: 3.19: ixgbe 0000:01:00.0 eth4: initiating reset due to tx timeout
Date: Mon, 23 Feb 2015 07:35:26 -0500
Message-ID: <CAO9zADyWkiMOXuZ10zDX8n2DbVt=xG=O_LE7za28hDAV+sEP+g@mail.gmail.com>
References: <000001d04e97$43b4b950$cb1e2bf0$@lucidpixels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: open list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <000001d04e97$43b4b950$cb1e2bf0$@lucidpixels.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 22, 2015 at 7:01 AM, Justin Piszcz <jpiszcz@lucidpixels.com> wrote:
>
> Hello,
>
> Kernel: 3.19.0
> Issue: When using robocopy to copy files (from Windows 8/8.1) to
> Linux/samba, the 10GbE NIC resets - dmesg [1] below.  To get it back working
> again, I have to down/up the interface.  Jumbo frames are being used (mtu of
> 9014) on each side. The lspci output is listed below.  Are there any other
> recommended workarounds for this issue as LRO is already off for me as shown
> below.  When using Linux<->Linux with rsync or NFS, there are no errors with
> 10GbE.  When using Samba<->Windows 8 over 10GbE, this issue occurs
> persistently as shown below when a copy is running.
>
> # ethtool -k eth4|grep large
> large-receive-offload: off [fixed]
>
> There is/was a similar issue as reported here:
> https://communities.intel.com/message/207408
>
> [1] dmesg
>
> [538576.098186] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [541013.223961] ------------[ cut here ]------------
> [541013.223970] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:303
> dev_watchdog+0x227/0x230()
> [541013.223971] NETDEV WATCHDOG: eth4 (ixgbe): transmit queue 0 timed out
> [541013.223972] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 3.19.0 #2
> [541013.223973] Hardware name: Supermicro X9SRL-F/X9SRL-F, BIOS 3.0a
> 12/05/2013
> [541013.223974]  ffffffff81d3a6ae ffff88107fc03da8 ffffffff819d07d7
> ffffffff81e34d98
> [541013.223976]  ffff88107fc03df8 ffff88107fc03de8 ffffffff810dbdab
> 0000000000000000
> [541013.223977]  0000000000000000 ffff881036304000 0000000000000000
> 0000000000000010
> [541013.223979] Call Trace:
> [541013.223979]  <IRQ>  [<ffffffff819d07d7>] dump_stack+0x45/0x57
> [541013.223985]  [<ffffffff810dbdab>] warn_slowpath_common+0x7b/0xc0
> [541013.223987]  [<ffffffff810dbe61>] warn_slowpath_fmt+0x41/0x50
> [541013.223990]  [<ffffffff810eec4c>] ? __queue_work+0xfc/0x290
> [541013.223996]  [<ffffffff818ef0a7>] dev_watchdog+0x227/0x230
> [541013.223997]  [<ffffffff818eee80>] ? qdisc_rcu_free+0x40/0x40
> [541013.223998]  [<ffffffff818eee80>] ? qdisc_rcu_free+0x40/0x40
> [541013.224001]  [<ffffffff811251f7>] call_timer_fn.isra.29+0x17/0x80
> [541013.224002]  [<ffffffff81125429>] run_timer_softirq+0x1c9/0x280
> [541013.224004]  [<ffffffff810dec7f>] __do_softirq+0xff/0x200
> [541013.224005]  [<ffffffff810deea6>] irq_exit+0x76/0xa0
> [541013.224007]  [<ffffffff8106ac11>] smp_apic_timer_interrupt+0x41/0x50
> [541013.224009]  [<ffffffff819da6aa>] apic_timer_interrupt+0x6a/0x70
> [541013.224009]  <EOI>  [<ffffffff8184e8f8>] ? cpuidle_enter_state+0x48/0xc0
> [541013.224013]  [<ffffffff8184e8ed>] ? cpuidle_enter_state+0x3d/0xc0
> [541013.224014]  [<ffffffff8184ea42>] cpuidle_enter+0x12/0x20
> [541013.224017]  [<ffffffff8110f222>] cpu_startup_entry+0x272/0x2f0
> [541013.224018]  [<ffffffff819cdd5d>] rest_init+0x6d/0x70
> [541013.224021]  [<ffffffff81ef0dbb>] start_kernel+0x353/0x360
> [541013.224022]  [<ffffffff81ef0495>] x86_64_start_reservations+0x2a/0x2c
> [541013.224023]  [<ffffffff81ef055f>] x86_64_start_kernel+0xc8/0xcc
> [541013.224024] ---[ end trace 59877113cf8b7358 ]---
> [541013.224026] ixgbe 0000:01:00.0 eth4: initiating reset due to tx timeout
> [541013.224036] ixgbe 0000:01:00.0 eth4: Reset adapter
> [541020.099402] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
>
> ( .. it continue but without the trace later .. )
>
> [567457.771728] ixgbe 0000:01:00.0 eth4: NIC Link is Down
> [567458.140112] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [567561.611941] ixgbe 0000:01:00.0 eth4: NIC Link is Down
> [567568.188422] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [570130.483823] ixgbe 0000:01:00.0 eth4: initiating reset due to tx timeout
> [570130.483924] ixgbe 0000:01:00.0 eth4: Reset adapter
> [570137.252167] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [572094.256452] ixgbe 0000:01:00.0 eth4: initiating reset due to tx timeout
> [572094.256538] ixgbe 0000:01:00.0 eth4: Reset adapter
> [572101.130915] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [573967.946084] ixgbe 0000:01:00.0 eth4: initiating reset due to tx timeout
> [573967.946097] ixgbe 0000:01:00.0 eth4: Reset adapter
> [573974.676387] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [575766.574731] ixgbe 0000:01:00.0 eth4: initiating reset due to tx timeout
> [575766.574753] ixgbe 0000:01:00.0 eth4: Reset adapter
> [575773.315067] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
> [585476.513732] perf interrupt took too long (5003 > 5000), lowering
> kernel.perf_event_max_sample_rate to 25000
> [597267.959412] ixgbe 0000:01:00.0 eth4: initiating reset due to tx timeout
> [597267.959452] ixgbe 0000:01:00.0 eth4: Reset adapter
> [597274.709728] ixgbe 0000:01:00.0 eth4: NIC Link is Up 10 Gbps, Flow
> Control: RX/TX
>
> [2] lspci
>
> 01:00.0 Ethernet controller: Intel Corporation 82598EB 10-Gigabit AT2 Server
> Adapter (rev 01)
>   Subsystem: Intel Corporation 82598EB 10-Gigabit AT2 Server Adapter
>   Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx+
>   Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
> <MAbort- >SERR- <PERR- INTx-
>   Latency: 0, Cache Line Size: 64 bytes
>   Interrupt: pin A routed to IRQ 85
>   Region 0: Memory at fbe40000 (32-bit, non-prefetchable) [size=128K]
>   Region 1: Memory at fbe00000 (32-bit, non-prefetchable) [size=256K]
>   Region 2: I/O ports at e000 [size=32]
>   Region 3: Memory at fbe60000 (32-bit, non-prefetchable) [size=16K]
>   Capabilities: [40] Power Management version 3
>     Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0+,D1-,D2-,D3hot+,D3cold-)
>     Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
>   Capabilities: [50] MSI: Enable- Count=1/1 Maskable- 64bit+
>     Address: 0000000000000000  Data: 0000
>   Capabilities: [60] MSI-X: Enable+ Count=18 Masked-
>     Vector table: BAR=3 offset=00000000
>     PBA: BAR=3 offset=00002000
>   Capabilities: [a0] Express (v2) Endpoint, MSI 00
>     DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s <512ns, L1 <64us
>       ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
>     DevCtl: Report errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
>       RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
>       MaxPayload 256 bytes, MaxReadReq 512 bytes
>     DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr- TransPend-
>     LnkCap: Port #0, Speed 2.5GT/s, Width x8, ASPM L0s L1, Exit Latency L0s
> <4us, L1 <64us
>       ClockPM- Surprise- LLActRep- BwNot-
>     LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- CommClk+
>       ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
>     LnkSta: Speed 2.5GT/s, Width x8, TrErr- Train- SlotClk+ DLActive-
> BWMgmt- ABWMgmt-
>     DevCap2: Completion Timeout: Range ABCD, TimeoutDis+, LTR-, OBFF Not
> Supported
>     DevCtl2: Completion Timeout: 16ms to 55ms, TimeoutDis-, LTR-, OBFF
> Disabled
>     LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-
>        Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
> ComplianceSOS-
>        Compliance De-emphasis: -6dB
>     LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete-,
> EqualizationPhase1-
>        EqualizationPhase2-, EqualizationPhase3-, LinkEqualizationRequest-
>   Capabilities: [100 v1] Advanced Error Reporting
>     UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq- ACSViol-
>     UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF-
> MalfTLP- ECRC- UnsupReq+ ACSViol-
>     UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+
> MalfTLP+ ECRC- UnsupReq- ACSViol-
>     CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr-
>     CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
>     AERCap: First Error Pointer: 00, GenCap- CGenEn- ChkCap- ChkEn-
>   Capabilities: [140 v1] Device Serial Number 00-1b-21-ff-ff-58-e6-aa
>   Kernel driver in use: ixgbe
> 00: 86 80 0b 15 07 04 10 00 01 00 00 02 10 00 00 00
> 10: 00 00 e4 fb 00 00 e0 fb 01 e0 00 00 00 00 e6 fb
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 80 2c a1
> 30: 00 00 00 00 40 00 00 00 00 00 00 00 0b 01 00 00
> 40: 01 50 23 48 00 20 00 fa 00 00 00 00 00 00 00 00
> 50: 05 60 80 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 11 a0 11 80 03 00 00 00 03 20 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 10 00 02 00 c1 8c 00 00 2f 28 00 00 81 6c 03 00
> b0: 40 00 81 10 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 1f 00 00 00 05 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 100: 01 00 01 14 00 00 00 00 00 00 10 00 11 20 06 00
> 110: 00 00 00 00 00 20 00 00 00 00 00 00 00 00 00 00
> 120: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 130: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 140: 03 00 01 00 aa e6 58 ff ff 21 1b 00 00 00 00 00
> 150: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  (the rest are: XXX: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00)
>
> Justin.
>

+CC netdev@

I also tried the latest ixgbe (3.23.2) from Intel and it does not
compile against 3.19-- is there a newer version I should be trying or
possibly try different module parameters/tweaking to work-around this
issue?

https://downloadcenter.intel.com/Detail_Desc.aspx?DwnldID=14687

Thanks,

Justin.
