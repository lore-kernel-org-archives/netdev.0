From: Stephen Hemminger <shemminger@vyatta.com>
Subject: BUG: skb_under_panic in eth_header (3.0.34)
Date: Thu, 27 Dec 2012 14:59:14 -0800
Message-ID: <20121227145914.7b318d10@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56471 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752261Ab2L0XAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 18:00:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Bug report from sysop@prisjakt.nu

It is a skb_under_panic in eth_header where it trying to make space for
the Ethernet header?

https://bugzilla.kernel.org/show_bug.cgi?id=42764


I got it one more time. Ethernet card is:
0e:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709S Gigabit
Ethernet (rev 20)

ethtool -i eth0
driver: bnx2
version: 2.1.6
firmware-version: bc 4.4.14 IPMI 0.1.16
bus-info: 0000:04:00.0

ethtool -i eth2
driver: bnx2
version: 2.1.6
firmware-version: bc 4.4.10
bus-info: 0000:0e:00.0

Could this be related to an old firmware?

This machine does a lot of network traffic, because it load data from a
database every night.

Kernel version is 3.0.34

Sorry for not reporting hardware, I thought it was a protocol bug not related
to a specific card.

------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:147!
invalid opcode: 0000 [#1] SMP 
CPU 2 
Modules linked in: af_packet ipmi_devintf ipmi_si ipmi_msghandler ipv6 fuse
loop sr_mod cdrom mptsas mptscsih mptbase scsi_transport_sas tpm_tis tpm bnx2
tpm_bios sg i2c_piix4 i2c_core shpchp pci_hotplug button serio_raw linear
scsi_dh_alua scsi_dh_rdac scsi_dh_hp_sw scsi_dh_emc dm_round_robin sd_mod
crc_t10dif qla2xxx scsi_transport_fc scsi_tgt dm_snapshot dm_multipath scsi_dh
scsi_mod edd dm_mod ext3 mbcache jbd fan thermal processor thermal_sys hwmon
[last unloaded: usbcore]

Pid: 21566, comm: nscd Not tainted 3.0.34-inps #5 IBM BladeCenter LS42
-[7902CQG]-/Server Blade
RIP: 0010:[<ffffffff8123fd12>]  [<ffffffff8123fd12>] skb_push+0x75/0x7e
RSP: 0018:ffff880b956c39d8  EFLAGS: 00010292
RAX: 0000000000000083 RBX: 0000000000000800 RCX: 0000000000023382
RDX: 0000000000007878 RSI: 0000000000000046 RDI: ffffffff8152ee9c
RBP: ffff880b956c39f8 R08: 0000000000000000 R09: 0720072007200720
R10: ffff880b956c37c8 R11: 0720072007200720 R12: 0000000000000000
R13: ffff8810231fb718 R14: 0000000000000055 R15: ffff880c25d24000
FS:  00007fd9a9222950(0000) GS:ffff880c3fc00000(0000) knlGS:00000000e8dafb90
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007fd9b403a000 CR3: 0000000c265e8000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process nscd (pid: 21566, threadinfo ffff880b956c2000, task ffff8803e50e4790)
Stack:
 0000000000000057 0000000000000080 ffff880c25d24000 ffff880c71806440
 ffff880b956c3a38 ffffffff8125e0c5 ffff880b956c3a28 0000000000000036
 ffff8810231fb680 ffff8810231fb718 ffff880b2cc49380 ffff8810231fb710
Call Trace:
 [<ffffffff8125e0c5>] eth_header+0x29/0xa8
 [<ffffffff81251a59>] neigh_resolve_output+0x284/0x2ed
 [<ffffffff8127575e>] ip_finish_output+0x24c/0x293
 [<ffffffff81097cac>] ? zone_watermark_ok+0x1a/0x1c
 [<ffffffff81275846>] ip_output+0xa1/0xa5
 [<ffffffff81274b92>] ip_local_out+0x24/0x29
 [<ffffffff81274ba0>] ip_send_skb+0x9/0x4c
 [<ffffffff8129178b>] udp_send_skb+0x28b/0x2e8
 [<ffffffff812935cb>] udp_sendmsg+0x501/0x708
 [<ffffffff810e42dd>] ? poll_freewait+0x8d/0x8d
 [<ffffffff812740ec>] ? ip_append_page+0x4f4/0x4f4
 [<ffffffff8109b8f2>] ? __alloc_pages_nodemask+0x731/0x77c
 [<ffffffff810541ad>] ? sched_clock_local+0x1c/0x80
 [<ffffffff81299607>] inet_sendmsg+0x83/0x90
 [<ffffffff81238e93>] sock_sendmsg+0xe3/0x106
 [<ffffffff810c7c8a>] ? ____cache_alloc_node+0x4c/0x132
 [<ffffffff810c7b4f>] ? fallback_alloc+0xe1/0x1d0
 [<ffffffff8126e390>] ? __ip_route_output_key+0x139/0x816
 [<ffffffff812d24e3>] ? _raw_spin_unlock_bh+0xf/0x11
 [<ffffffff8123ba9e>] ? release_sock+0xfd/0x106
 [<ffffffff81239463>] sys_sendto+0xfa/0x123
 [<ffffffff81239c3d>] ? sys_connect+0x88/0x9c
 [<ffffffff812d78bb>] system_call_fastpath+0x16/0x1b
Code: 8b 57 68 48 89 44 24 10 8b 87 d0 00 00 00 48 89 44 24 08 8b bf cc 00 00
00 31 c0 48 89 3c 24 48 c7 c7 5a 79 3a 81 e8 df 03 09 00 <0f> 0b eb fe 48 89 c8
c9 c3 55 89 f1 48 89 e5 48 83 ec 20 83 7f 
RIP  [<ffffffff8123fd12>] skb_push+0x75/0x7e
 RSP <ffff880b956c39d8>
---[ end trace 7e8c514a1c33a3f0 ]---

Output of lspci -vvv:

0e:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709S Gigabit
Ethernet (rev 20)
    Subsystem: IBM Device 039f
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx+
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin A routed to IRQ 26
    Region 0: Memory at ce000000 (64-bit, non-prefetchable) [size=32M]
    Capabilities: [48] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=1 PME-
    Capabilities: [50] Vital Product Data <?>
    Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Count=1/8
Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [a0] MSI-X: Enable+ Mask- TabSize=9
        Vector table: BAR=0 offset=0000c000
        PBA: BAR=0 offset=0000e000
    Capabilities: [ac] Express (v2) Endpoint, MSI 00
        DevCap:    MaxPayload 512 bytes, PhantFunc 0, Latency L0s <4us, L1
<64us
            ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
            RlxdOrd+ ExtTag- PhantFunc- AuxPwr+ NoSnoop+
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x4, ASPM L0s L1, Latency L0
<4us, L1 <4us
            ClockPM- Suprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; RCB 128 bytes Disabled- Retrain- CommClk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
        DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
        DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis+
        LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-,
Selectable De-emphasis: -6dB
             Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
ComplianceSOS-
             Compliance De-emphasis: -6dB
        LnkSta2: Current De-emphasis Level: -6dB
    Kernel driver in use: bnx2
    Kernel modules: bnx2

0e:00.1 Ethernet controller: Broadcom Corporation NetXtreme II BCM5709S Gigabit
Ethernet (rev 20)
    Subsystem: IBM Device 039f
    Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+
Stepping- SERR+ FastB2B- DisINTx-
    Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort-
<MAbort- >SERR- <PERR- INTx-
    Latency: 0, Cache Line Size: 64 bytes
    Interrupt: pin B routed to IRQ 26
    Region 0: Memory at d0000000 (64-bit, non-prefetchable) [size=32M]
    Capabilities: [48] Power Management version 3
        Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
        Status: D0 PME-Enable- DSel=0 DScale=1 PME-
    Capabilities: [50] Vital Product Data <?>
    Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+ Count=1/8
Enable-
        Address: 0000000000000000  Data: 0000
    Capabilities: [a0] MSI-X: Enable- Mask- TabSize=8
        Vector table: BAR=0 offset=0000c000
        PBA: BAR=0 offset=0000e000
    Capabilities: [ac] Express (v2) Endpoint, MSI 00
        DevCap:    MaxPayload 512 bytes, PhantFunc 0, Latency L0s <4us, L1
<64us
            ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
        DevCtl:    Report errors: Correctable- Non-Fatal+ Fatal+ Unsupported-
            RlxdOrd+ ExtTag- PhantFunc- AuxPwr+ NoSnoop+
            MaxPayload 256 bytes, MaxReadReq 4096 bytes
        DevSta:    CorrErr+ UncorrErr- FatalErr- UnsuppReq+ AuxPwr+ TransPend-
        LnkCap:    Port #0, Speed 2.5GT/s, Width x4, ASPM L0s L1, Latency L0
<4us, L1 <4us
            ClockPM- Suprise- LLActRep- BwNot-
        LnkCtl:    ASPM Disabled; RCB 128 bytes Disabled- Retrain- CommClk-
            ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
        LnkSta:    Speed 2.5GT/s, Width x4, TrErr- Train- SlotClk+ DLActive-
BWMgmt- ABWMgmt-
        DevCap2: Completion Timeout: Range ABCD, TimeoutDis+
        DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis+
        LnkCtl2: Target Link Speed: 2.5GT/s, EnterCompliance- SpeedDis-,
Selectable De-emphasis: -6dB
             Transmit Margin: Normal Operating Range, EnterModifiedCompliance-
ComplianceSOS-
             Compliance De-emphasis: -6dB
        LnkSta2: Current De-emphasis Level: -6dB
    Kernel driver in use: bnx2
    Kernel modules: bnx2
