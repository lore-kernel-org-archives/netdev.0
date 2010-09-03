From: "Greg Trahair" <Greg.Trahair@tomtom.com>
Subject: Re: [BUG] __vlan_hwaccel_rx system call causes kernel panic
Date: Sat, 4 Sep 2010 00:46:34 +0200
Message-ID: <D3EC401C-83E9-4948-A971-F69D2E716592@tomtom.com>
References: <7360C1812CDFF247A3342E16BF5CBE0A01277F6A@NL-EXC-06.intra.local> <AANLkTin9ND42s0o-3Wv-vZuG5RTxSheJOCdSnr3qyHX5@mail.gmail.com> <80769D7B14936844A23C0C43D9FBCF0F25AF9E8E56@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0 (iPhone Mail 8A400)
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Chris Leech" <chris.leech@gmail.com>, <netdev@vger.kernel.org>,
	<e1000-devel@lists.sourceforge.net>, <linux-net@vger.kernel.org>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F25AF9E8E56@orsmsx501.amr.corp.intel.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alex,

The igb driver is 2.1.9, and I've compiled the 2.3.7 to test on Monday. Can you confirm your fix was post 2.1.9 and I can get Citrix to patch their kernel for their other customers.

Thanks,
- Greg

On 3 Sep 2010, at 18:14, "Duyck, Alexander H" <alexander.h.duyck@intel.com> wrote:

> Greg,
> 
> What version of the igb driver are you using?  The issue you are describing sounds similar to an issue I fixed some time ago and my concern is your driver may be out of date.  You might try downloading and installing the latest igb from e1000.sf.net and seeing if you experience the same issue.
> 
> Thanks,
> 
> Alex
> 
>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of Chris Leech
>> Sent: Thursday, September 02, 2010 4:29 PM
>> To: Greg Trahair; netdev@vger.kernel.org; e1000-
>> devel@lists.sourceforge.net
>> Cc: linux-net@vger.kernel.org
>> Subject: [BUG] __vlan_hwaccel_rx system call causes kernel panic
>> 
>> Greg,
>> 
>> You'll probably get a better response for this sort of thing on netdev
>> than linux-net.  Also, because this involves an Intel network driver,
>> e1000-devel might be able to help.
>> 
>> - Chris
>> 
>> Forwarded conversation
>> Subject: [BUG] __vlan_hwaccel_rx system call causes kernel panic
>> ------------------------
>> 
>> From: Greg Trahair <Greg.Trahair@tomtom.com>
>> Date: Thu, Sep 2, 2010 at 1:17 AM
>> To: linux-net@vger.kernel.org
>> Cc: Sami Kerola <Sami.Kerola@tomtom.com>
>> 
>> 
>> I have recently upgraded Citrix XenServer from 5.5 to 5.6 (from
>> 2.6.18-128.1.6.el5.xs5.5.0.505.1024xen to
>> 2.6.27.42-0.1.1.xs5.6.0.44.111158xen) and when the system either
>> brings up, or shuts down a vlan tagged interface, the below stack
>> trace appears and system halts.
>> 
>> This problem is intermittent, it doesn't happen every time, but it's
>> quite reliably reproducible by starting/stopping OS.
>> 
>> 
>> Shutting down interface eth4.443:  BUG: unable to handle kernel NULL
>> pointer dereference at 00000010
>> IP: [<c0337695>] __vlan_hwaccel_rx+0x75/0x160
>> Oops: 0000 [#1] SMP
>> last sysfs file: /sys/class/iscsi_session/session1/ifacename
>> Modules linked in: nfs nfs_acl lockd sunrpc 8021q bridge stp llc(N)
>> ipt_REJECT nf_conntrack_ipv4 xt_state nf_conntrack xt_tcpudp
>> iptable_filter ip_tables x_tables binfmt_misc nls_utf8 isofs(N)
>> dm_mirror dm_log dm_mod sbs sbshc fan dock container battery ac
>> parport_pc lp parport nvram igb evdev(N) thermal button processor
>> thermal_sys bnx2 serio_raw zlib_inflate(N) rtc_cmos rtc_core rtc_lib
>> 8250_pnp 8250 serial_core pcspkr ide_generic ide_disk mptsas
>> scsi_transport_sas mppVhba mptscsih mptbase mppUpper sg sd_mod
>> scsi_mod ext3 jbd uhci_hcd ohci_hcd ehci_hcd usbcore fbcon(N) font(N)
>> tileblit(N) bitblit(N) softcursor(N) [last unloaded:
>> scsi_transport_iscsi]
>> Supported: No
>> 
>> Pid: 31322, comm: vconfig Tainted: G
>> (2.6.27.42-0.1.1.xs5.6.0.44.111158xen #1)
>> EIP: 0061:[<c0337695>] EFLAGS: 00010247 CPU: 0
>> EIP is at __vlan_hwaccel_rx+0x75/0x160
>> EAX: 00000000 EBX: eeb47c00 ECX: 0000013f EDX: 00000000
>> ESI: 00000000 EDI: 0000013f EBP: eb9a7d6c ESP: eb9a7d5c
>>  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0069
>> Process vconfig (pid: 31322, ti=eb9a6000 task=eba3f030
>> task.ti=eb9a6000)
>> Stack: 00000000 000000e6 eeb6a4c0 eeb47c00 eb9a7e48 f02ba946 00000001
>> 00000002
>>       c16bdb00 00000000 eac84900 00000002 00000942 00000000 00000005
>> 01025e93
>>       eb9a7db0 c01d002c eb0f4000 00000040 ee060dcc eced85c0 eeb6a4c0
>> ee060dc0
>> Call Trace:
>>  [<f02ba946>] ? igb_poll+0x8e6/0xc90 [igb]
>>  [<c01d002c>] ? release_sysfs_dirent+0x1c/0xc0
>>  [<c0346ee5>] ? schedule_timeout+0x75/0xc0
>>  [<c025b715>] ? device_release+0x15/0x70
>>  [<c0346ce2>] ? wait_for_completion+0x12/0x20
>>  [<c02d44a5>] ? net_rx_action+0x165/0x250
>>  [<c012e322>] ? __do_softirq+0xb2/0x160
>>  [<c012e457>] ? do_softirq+0x87/0x90
>>  [<c012e77b>] ? irq_exit+0x3b/0x50
>>  [<c026d0ec>] ? evtchn_do_upcall+0x1dc/0x1f0
>>  [<c02c5620>] ? sock_ioctl+0x0/0x220
>>  [<c0105565>] ? hypervisor_callback+0x41/0x49
>>  [<c02c5620>] ? sock_ioctl+0x0/0x220
>>  [<f036fa79>] ? vlan_ioctl_handler+0xa9/0x390 [8021q]
>>  [<c02c57d0>] ? sock_ioctl+0x1b0/0x220
>>  [<c02c5620>] ? sock_ioctl+0x0/0x220
>>  [<c0191458>] ? vfs_ioctl+0x28/0x80
>>  [<c0191507>] ? do_vfs_ioctl+0x57/0x290
>>  [<c02c74ff>] ? sys_socketcall+0x6f/0x290
>>  [<c0182bb9>] ? filp_close+0x49/0x70
>>  [<c01917a0>] ? sys_ioctl+0x60/0x70
>>  [<c01053ce>] ? syscall_call+0x7/0xb
>>  =======================
>> Code: 00 00 8d 74 26 00 0f b7 81 c6 00 00 00 a8 04 75 55 89 f9 8b 75
>> f0 66 81 e1 ff 0f 89 c8 66 c1 e8 09 0f b7 c0 66 89 bb 88 00 00 00 <8b>
>> 54 86 10 31 c0 85 d2 74 0a 89 c8 25 ff 01 00 00 8b 04 82 89
>> EIP: [<c0337695>] __vlan_hwaccel_rx+0x75/0x160 SS:ESP 0069:eb9a7d5c
>> 
>> --
>> Greg Trahair | Lead System Engineer | TomTom
>> 
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-net"
>> in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> 
>> ----------
>> From: Greg Trahair <Greg.Trahair@tomtom.com>
>> Date: Thu, Sep 2, 2010 at 2:43 AM
>> To: linux-net@vger.kernel.org
>> Cc: Sami Kerola <Sami.Kerola@tomtom.com>
>> 
>> 
>> Oops, I forgot to include the hardware:
>> 
>> 06:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network
>> Connection (rev 01)
>>        Subsystem: Intel Corporation Gigabit ET Quad Port Server
>> Adapter
>>        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>> ParErr- Stepping- SERR- FastB2B-
>>        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR-
>>        Latency: 0, Cache Line Size: 64 bytes
>>        Interrupt: pin A routed to IRQ 47
>>        Region 0: Memory at ddfc0000 (32-bit, non-prefetchable)
>> [size=128K]
>>        Region 1: Memory at de000000 (32-bit, non-prefetchable)
>> [size=4M]
>>        Region 2: I/O ports at ecc0 [size=32]
>>        Region 3: Memory at ddfb8000 (32-bit, non-prefetchable)
>> [size=16K]
>>        Capabilities: [40] Power Management version 3
>>                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
>> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>>                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>>        Capabilities: [50] Message Signalled Interrupts: 64bit+
>> Queue=0/0 Enable-
>>                Address: 0000000000000000  Data: 0000
>>        Capabilities: [70] MSI-X: Enable+ Mask- TabSize=10
>>                Vector table: BAR=3 offset=00000000
>>                PBA: BAR=3 offset=00002000
>>        Capabilities: [a0] Express Endpoint IRQ 0
>>                Device: Supported: MaxPayload 512 bytes, PhantFunc 0,
>> ExtTag-
>>                Device: Latency L0s <512ns, L1 <64us
>>                Device: AtnBtn- AtnInd- PwrInd-
>>                Device: Errors: Correctable- Non-Fatal+ Fatal+
>> Unsupported+
>>                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
>>                Link: Supported Speed 2.5Gb/s, Width x4, ASPM L0s L1,
>> Port 2
>>                Link: Latency L0s <4us, L1 <64us
>>                Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>>                Link: Speed 2.5Gb/s, Width x4
>>        Capabilities: [100] Advanced Error Reporting
>>        Capabilities: [140] Device Serial Number c0-57-55-ff-ff-21-1b-
>> 00
>>        Capabilities: [150] Unknown (14)
>>        Capabilities: [160] Unknown (16)
>> 
>> 06:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network
>> Connection (rev 01)
>>        Subsystem: Intel Corporation Gigabit ET Quad Port Server
>> Adapter
>>        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>> ParErr- Stepping- SERR- FastB2B-
>>        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR-
>>        Latency: 0, Cache Line Size: 64 bytes
>>        Interrupt: pin B routed to IRQ 46
>>        Region 0: Memory at ddfe0000 (32-bit, non-prefetchable)
>> [size=128K]
>>        Region 1: Memory at de400000 (32-bit, non-prefetchable)
>> [size=4M]
>>        Region 2: I/O ports at ece0 [size=32]
>>        Region 3: Memory at ddfbc000 (32-bit, non-prefetchable)
>> [size=16K]
>>        Capabilities: [40] Power Management version 3
>>                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
>> PME(D0+,D1-,D2-,D3hot+,D3cold+)
>>                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>>        Capabilities: [50] Message Signalled Interrupts: 64bit+
>> Queue=0/0 Enable-
>>                Address: 0000000000000000  Data: 0000
>>        Capabilities: [70] MSI-X: Enable+ Mask- TabSize=10
>>                Vector table: BAR=3 offset=00000000
>>                PBA: BAR=3 offset=00002000
>>        Capabilities: [a0] Express Endpoint IRQ 0
>>                Device: Supported: MaxPayload 512 bytes, PhantFunc 0,
>> ExtTag-
>>                Device: Latency L0s <512ns, L1 <64us
>>                Device: AtnBtn- AtnInd- PwrInd-
>>                Device: Errors: Correctable- Non-Fatal+ Fatal+
>> Unsupported+
>>                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
>>                Link: Supported Speed 2.5Gb/s, Width x4, ASPM L0s L1,
>> Port 2
>>                Link: Latency L0s <4us, L1 <64us
>>                Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>>                Link: Speed 2.5Gb/s, Width x4
>>        Capabilities: [100] Advanced Error Reporting
>>        Capabilities: [140] Device Serial Number c0-57-55-ff-ff-21-1b-
>> 00
>>        Capabilities: [150] Unknown (14)
>>        Capabilities: [160] Unknown (16)
>> 
>> 07:00.0 Ethernet controller: Intel Corporation 82576 Gigabit Network
>> Connection (rev 01)
>>        Subsystem: Intel Corporation Gigabit ET Quad Port Server
>> Adapter
>>        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>> ParErr- Stepping- SERR- FastB2B-
>>        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR-
>>        Latency: 0, Cache Line Size: 64 bytes
>>        Interrupt: pin A routed to IRQ 38
>>        Region 0: Memory at dd3c0000 (32-bit, non-prefetchable)
>> [size=128K]
>>        Region 1: Memory at dd400000 (32-bit, non-prefetchable)
>> [size=4M]
>>        Region 2: I/O ports at dcc0 [size=32]
>>        Region 3: Memory at dd3b8000 (32-bit, non-prefetchable)
>> [size=16K]
>>        Capabilities: [40] Power Management version 3
>>                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
>> PME(D0+,D1-,D2-,D3hot+,D3cold-)
>>                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>>        Capabilities: [50] Message Signalled Interrupts: 64bit+
>> Queue=0/0 Enable-
>>                Address: 0000000000000000  Data: 0000
>>        Capabilities: [70] MSI-X: Enable+ Mask- TabSize=10
>>                Vector table: BAR=3 offset=00000000
>>                PBA: BAR=3 offset=00002000
>>        Capabilities: [a0] Express Endpoint IRQ 0
>>                Device: Supported: MaxPayload 512 bytes, PhantFunc 0,
>> ExtTag-
>>                Device: Latency L0s <512ns, L1 <64us
>>                Device: AtnBtn- AtnInd- PwrInd-
>>                Device: Errors: Correctable- Non-Fatal+ Fatal+
>> Unsupported+
>>                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
>>                Link: Supported Speed 2.5Gb/s, Width x4, ASPM L0s L1,
>> Port 4
>>                Link: Latency L0s <4us, L1 <64us
>>                Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>>                Link: Speed 2.5Gb/s, Width x4
>>        Capabilities: [100] Advanced Error Reporting
>>        Capabilities: [140] Device Serial Number c4-57-55-ff-ff-21-1b-
>> 00
>>        Capabilities: [150] Unknown (14)
>>        Capabilities: [160] Unknown (16)
>> 
>> 07:00.1 Ethernet controller: Intel Corporation 82576 Gigabit Network
>> Connection (rev 01)
>>        Subsystem: Intel Corporation Gigabit ET Quad Port Server
>> Adapter
>>        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
>> ParErr- Stepping- SERR- FastB2B-
>>        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
>> <TAbort- <MAbort- >SERR- <PERR-
>>        Latency: 0, Cache Line Size: 64 bytes
>>        Interrupt: pin B routed to IRQ 45
>>        Region 0: Memory at dd3e0000 (32-bit, non-prefetchable)
>> [size=128K]
>>        Region 1: Memory at dd800000 (32-bit, non-prefetchable)
>> [size=4M]
>>        Region 2: I/O ports at dce0 [size=32]
>>        Region 3: Memory at dd3bc000 (32-bit, non-prefetchable)
>> [size=16K]
>>        Capabilities: [40] Power Management version 3
>>                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
>> PME(D0+,D1-,D2-,D3hot+,D3cold-)
>>                Status: D0 PME-Enable- DSel=0 DScale=1 PME-
>>        Capabilities: [50] Message Signalled Interrupts: 64bit+
>> Queue=0/0 Enable-
>>                Address: 0000000000000000  Data: 0000
>>        Capabilities: [70] MSI-X: Enable+ Mask- TabSize=10
>>                Vector table: BAR=3 offset=00000000
>>                PBA: BAR=3 offset=00002000
>>        Capabilities: [a0] Express Endpoint IRQ 0
>>                Device: Supported: MaxPayload 512 bytes, PhantFunc 0,
>> ExtTag-
>>                Device: Latency L0s <512ns, L1 <64us
>>                Device: AtnBtn- AtnInd- PwrInd-
>>                Device: Errors: Correctable- Non-Fatal+ Fatal+
>> Unsupported+
>>                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
>>                Device: MaxPayload 256 bytes, MaxReadReq 512 bytes
>>                Link: Supported Speed 2.5Gb/s, Width x4, ASPM L0s L1,
>> Port 4
>>                Link: Latency L0s <4us, L1 <64us
>>                Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
>>                Link: Speed 2.5Gb/s, Width x4
>>        Capabilities: [100] Advanced Error Reporting
>>        Capabilities: [140] Device Serial Number c4-57-55-ff-ff-21-1b-
>> 00
>>        Capabilities: [150] Unknown (14)
>>        Capabilities: [160] Unknown (16)
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
