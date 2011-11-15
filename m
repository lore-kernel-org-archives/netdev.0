From: Martin Volf <martin.volf.42@gmail.com>
Subject: sky2 hw csum failure
Date: Tue, 15 Nov 2011 10:05:07 +0100
Message-ID: <CAM1AHpSuruDx3CxzK=Med0iyxxwu7wxgRZib7yhBMiCVKXqzeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, davem@davemloft.net, wcang@sfc.wide.ad.jp,
	zheng.z.yan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60676 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753590Ab1KOJFJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 04:05:09 -0500
Received: by fagn18 with SMTP id n18so138417fag.19
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2011 01:05:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

since 3.0.6 I get  many "eth0: hw csum failure" messages in dmesg
followed by a call trace (see at the end). 3.0.4 is OK, 3.1.1 is not.

When I revert the "bridge: Pseudo-header required for the checksum of
ICMPv6" commit, 4b275d7efa1c4412f0d572fcd7f78ed0919370b3, in 3.1.1,
the messages would not occur.

I have two sky2 interfaces bridged together and I use IPv6, but not
MLD. Most of the time only one interface is connected, the message
occurs for either of them. Another machine with bridged e1000 and
r8169 interfaces is OK even without the revert.

Let me know, if more information is needed to create the correct fix.

Martin Volf

--

HW info from 3.1.1 with the commit reverted:

uname -mp

x86_64 Intel(R) Core(TM)2 Duo CPU E8400 @ 3.00GHz

dmesg | fgrep sky2

[   11.226565] sky2: driver version 1.29
[   11.226601] sky2 0000:04:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
[   11.226614] sky2 0000:04:00.0: setting latency timer to 64
[   11.226644] sky2 0000:04:00.0: Yukon-2 EC Ultra chip revision 3
[   11.226719] sky2 0000:04:00.0: irq 47 for MSI/MSI-X
[   11.227327] sky2 0000:04:00.0: eth0: addr 00:22:15:98:82:ae
[   11.227338] sky2 0000:03:00.0: PCI INT A -> GSI 19 (level, low) -> IRQ 19
[   11.227346] sky2 0000:03:00.0: setting latency timer to 64
[   11.227366] sky2 0000:03:00.0: Yukon-2 EC Ultra chip revision 3
[   11.227436] sky2 0000:03:00.0: irq 48 for MSI/MSI-X
[   11.227625] sky2 0000:03:00.0: eth1: addr 00:22:15:98:92:e1
[   31.809358] sky2 0000:03:00.0: eth1: enabling interface
[   31.816587] sky2 0000:04:00.0: eth0: enabling interface
[   34.196835] sky2 0000:04:00.0: eth0: Link is up at 1000 Mbps, full
duplex, flow control both

ethtool -k eth0 (same for eth1)

Offload parameters for eth0:
rx-checksumming: on
tx-checksumming: on
scatter-gather: on
tcp-segmentation-offload: on
udp-fragmentation-offload: off
generic-segmentation-offload: on
generic-receive-offload: on
large-receive-offload: off
rx-vlan-offload: on
tx-vlan-offload: on
ntuple-filters: off
receive-hashing: on

lspci -vvvxxx
03:00.0 Ethernet controller: Marvell Technology Group Ltd. 88E8056
PCI-E Gigabit Ethernet Controller (rev 12)
        Subsystem: ASUSTeK Computer Inc. Device 81f8
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 48
        Region 0: Memory at fe9fc000 (64-bit, non-prefetchable) [size=16K]
        Region 2: I/O ports at c800 [size=256]
        Expansion ROM at fe9c0000 [disabled] [size=128K]
        Capabilities: [48] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=1 PME-
        Capabilities: [50] Vital Product Data
                Product Name: Marvell Yukon 88E8056 Gigabit Ethernet Controller
                Read-only fields:
                        [PN] Part number: Yukon 88E8056
                        [EC] Engineering changes: Rev. 1.2
                        [MN] Manufacture ID: 4d 61 72 76 65 6c 6c
                        [SN] Serial number: AbCdEfG9892E1
                        [CP] Extended capability: 01 10 cc 03
                        [RV] Reserved: checksum good, 9 byte(s) reserved
                Read/write fields:
                        [RW] Read-write area: 121 byte(s) free
                End
        Capabilities: [5c] MSI: Enable+ Count=1/1 Maskable- 64bit+
                Address: 00000000fee0300c  Data: 4199
        Capabilities: [e0] Express (v1) Legacy Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s
unlimited, L1 unlimited
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <256ns, L1 unlimited
                        ClockPM+ Surprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 128 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train-
SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [100 v1] Advanced Error Reporting
                UESta:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UEMsk:  DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt-
UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
                UESvrt: DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt-
UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
                CESta:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                CEMsk:  RxErr- BadTLP- BadDLLP- Rollover- Timeout- NonFatalErr+
                AERCap: First Error Pointer: 1f, GenCap- CGenEn- ChkCap- ChkEn-
        Kernel driver in use: sky2
        Kernel modules: sky2
00: ab 11 64 43 07 04 10 00 12 00 00 02 08 00 00 00
10: 04 c0 9f fe 00 00 00 00 01 c8 00 00 00 00 00 00
20: 00 00 00 00 00 00 00 00 00 00 00 00 43 10 f8 81
30: 00 00 9c fe 48 00 00 00 00 00 00 00 05 01 00 00
40: 00 00 f0 01 00 80 a0 01 01 50 03 fe 00 20 00 13
50: 03 5c fc 80 00 00 00 78 00 00 00 01 05 e0 81 00
60: 0c 30 e0 fe 00 00 00 00 99 41 00 00 00 00 00 00
70: 00 03 00 00 00 00 00 00 00 00 00 00 00 00 00 00
80: 00 00 00 00 00 70 00 00 00 00 00 00 82 a8 e8 00
90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
e0: 10 00 11 00 c0 8f 28 00 00 20 19 00 11 ac 07 00
f0: 08 00 11 10 00 00 00 00 00 00 00 00 00 00 00 00

Call trace:

[   64.240856] eth1: hw csum failure.
[   64.240860] Pid: 0, comm: swapper Not tainted 3.1.1 #1
[   64.240862] Call Trace:
[   64.240864]  <IRQ>  [<ffffffff812acebf>] ? netdev_rx_csum_fault+0x29/0x31
[   64.240875]  [<ffffffff812a8e42>] ? __skb_checksum_complete_head+0x44/0x59
[   64.240884]  [<ffffffffa0174ea7>] ? br_multicast_rcv+0x7fc/0xc3f [bridge]
[   64.240888]  [<ffffffff81095c16>] ? dma_pool_alloc+0x267/0x279
[   64.240893]  [<ffffffff8102177d>] ? check_preempt_curr+0x38/0x61
[   64.240898]  [<ffffffffa016e187>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[   64.240903]  [<ffffffff812d1472>] ? nf_hook_slow+0x73/0x111
[   64.240908]  [<ffffffffa016e187>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[   64.240914]  [<ffffffffa0172706>] ? br_nf_forward_finish+0x95/0x95 [bridge]
[   64.240919]  [<ffffffffa016e205>] ?
br_handle_frame_finish+0x7e/0x1f3 [bridge]
[   64.240925]  [<ffffffffa017278f>] ?
br_nf_pre_routing_finish_ipv6+0x89/0x92 [bridge]
[   64.240931]  [<ffffffffa0171efe>] ? setup_pre_routing+0x38/0x5d [bridge]
[   64.240936]  [<ffffffffa0172f65>] ? br_nf_pre_routing+0x3bb/0x3cb [bridge]
[   64.240940]  [<ffffffff81026f31>] ? find_busiest_group+0x1fc/0x851
[   64.240943]  [<ffffffff810242c4>] ? enqueue_task_fair+0x126/0x219
[   64.240947]  [<ffffffff812d13c9>] ? nf_iterate+0x41/0x77
[   64.240952]  [<ffffffffa016e187>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[   64.240957]  [<ffffffffa016e187>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[   64.240961]  [<ffffffff812d1472>] ? nf_hook_slow+0x73/0x111
[   64.240966]  [<ffffffffa016e187>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[   64.240971]  [<ffffffffa016e187>] ? NF_HOOK.clone.4+0x56/0x56 [bridge]
[   64.240976]  [<ffffffffa016e16d>] ? NF_HOOK.clone.4+0x3c/0x56 [bridge]
[   64.240982]  [<ffffffffa016e529>] ? br_handle_frame+0x1af/0x1c6 [bridge]
[   64.240987]  [<ffffffffa016e37a>] ?
br_handle_frame_finish+0x1f3/0x1f3 [bridge]
[   64.240990]  [<ffffffff812af07b>] ? __netif_receive_skb+0x26a/0x3b1
[   64.240994]  [<ffffffff812af34e>] ? netif_receive_skb+0x52/0x58
[   64.240997]  [<ffffffff812af7fe>] ? napi_gro_receive+0x1f/0x2f
[   64.241000]  [<ffffffff812af425>] ? napi_skb_finish+0x1c/0x31
[   64.241011]  [<ffffffffa001459e>] ? sky2_poll+0x784/0x999 [sky2]
[   64.241015]  [<ffffffff812af8da>] ? net_rx_action+0x61/0x117
[   64.241019]  [<ffffffff81031164>] ? __do_softirq+0x7f/0x106
[   64.241023]  [<ffffffff8135af8c>] ? call_softirq+0x1c/0x30
[   64.241027]  [<ffffffff8100365a>] ? do_softirq+0x31/0x67
[   64.241030]  [<ffffffff81031390>] ? irq_exit+0x3f/0xa3
[   64.241033]  [<ffffffff810033b7>] ? do_IRQ+0x85/0x9e
[   64.241036]  [<ffffffff813597ab>] ? common_interrupt+0x6b/0x6b
[   64.241038]  <EOI>  [<ffffffff810081c1>] ? mwait_idle+0x59/0x5c
[   64.241044]  [<ffffffff8100098a>] ? cpu_idle+0x5c/0x7e
[   64.241047]  [<ffffffff8166f886>] ? start_kernel+0x304/0x30f
