From: Rui Santos <rsantos@ruisantos.com>
Subject: Re: 2.6.28: r8169: NETDEV WATCHDOG: eth0 (r8169): transmit timed
 out
Date: Mon, 16 Feb 2009 13:02:06 +0000
Message-ID: <499963CE.2060705@ruisantos.com>
References: <alpine.DEB.1.10.0901131617550.6193@p34.internal.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Alan Piszcz <ap@solarrain.com>,
	romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Justin Piszcz <jpiszcz@lucidpixels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly02.isp.novis.pt ([195.23.133.212]:38608 "EHLO
	mailrly02.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755860AbZBPNJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 08:09:27 -0500
In-Reply-To: <alpine.DEB.1.10.0901131617550.6193@p34.internal.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Justin Piszcz wrote:
> Most likely disabling this (onboard-nic) and using Intel PCI-Express 1
> Gbps card but FYI:
>
> [505628.695393] ------------[ cut here ]------------
> [505628.695398] WARNING: at net/sched/sch_generic.c:226
> dev_watchdog+0x22e/0x240()
> [505628.695400] NETDEV WATCHDOG: eth0 (r8169): transmit timed out
> [505628.695403] Pid: 0, comm: swapper Not tainted 2.6.28 #1
> [505628.695405] Call Trace:
> [505628.695407]  <IRQ>  [<ffffffff8024f628>] warn_slowpath+0xc8/0x110
> [505628.695416]  [<ffffffff805b9310>] ip_finish_output+0x0/0x2b0
> [505628.695419]  [<ffffffff8059e3e4>] eth_header+0x34/0xd0
> [505628.695423]  [<ffffffff804078c9>] __next_cpu+0x19/0x30
> [505628.695427]  [<ffffffff802472dc>] find_busiest_group+0x1dc/0x970
> [505628.695432]  [<ffffffff802308b9>] read_tsc+0x9/0x20
> [505628.695436]  [<ffffffff802599c4>] lock_timer_base+0x34/0x70
> [505628.695440]  [<ffffffff8026aa98>] getnstimeofday+0x48/0xc0
> [505628.695443]  [<ffffffff8040d601>] strlcpy+0x41/0x50
> [505628.695447]  [<ffffffff8059e9fe>] dev_watchdog+0x22e/0x240
> [505628.695449]  [<ffffffff802308b9>] read_tsc+0x9/0x20
> [505628.695453]  [<ffffffff8059e7d0>] dev_watchdog+0x0/0x240
> [505628.695456]  [<ffffffff802594be>] run_timer_softirq+0x12e/0x200
> [505628.695460]  [<ffffffff80238c35>] lapic_next_event+0x15/0x20
> [505628.695463]  [<ffffffff80254e13>] __do_softirq+0x93/0x160
> [505628.695467]  [<ffffffff802684c2>] hrtimer_interrupt+0x152/0x1c0
> [505628.695471]  [<ffffffff8022aabc>] call_softirq+0x1c/0x30
> [505628.695474]  [<ffffffff8022c455>] do_softirq+0x35/0x70
> [505628.695477]  [<ffffffff802394f6>] smp_apic_timer_interrupt+0x86/0xd0
> [505628.695480]  [<ffffffff8022a50b>] apic_timer_interrupt+0x6b/0x70
> [505628.695482]  <EOI>  [<ffffffff805f0320>] unix_poll+0x0/0xb0
> [505628.695489]  [<ffffffff8023147c>] mwait_idle+0x3c/0x50
> [505628.695493]  [<ffffffff80228a1c>] cpu_idle+0x5c/0x90
> [505628.695495] ---[ end trace eddb8da7fddd6198 ]---
> [505628.700048] r8169: eth0: link up
>
> I believe this occured when trying to burn a DVD via Nero over a 1gbps
> connection.
>
> Justin.
> -- 
> To unsubscribe from this list: send the line "unsubscribe
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>
>
>
I'm also experiencing this problem on a Gigabit connection.
I can reproduce it when needed. Only need to scp a giant file out to
another gigabit enabled machine, issuing eg, scp -c arcfour <source
file> <destfile>
It's a specific NIC problem, as I have another 3 PCI NIC's, also using
the r8169 driver, and all of those work fine. The NIC that does not work
is an integrated PCI-E NIC. Details are as follow:

- Motherboard: Jetway NC92-300-LF (
http://www.jetway.com.tw/jw/ipcboard_view.asp?productid=573&proname=NC92-330-LF
)

- The failing NIC is the onboard integrated. Output from lspci -v:
01:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
        Subsystem: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
Express Gigabit Ethernet controller
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 64 bytes
        Interrupt: pin A routed to IRQ 25
        Region 0: I/O ports at de00 [size=256]
        Region 2: Memory at fdeff000 (64-bit, non-prefetchable) [size=4K]
        Region 4: Memory at fdbf0000 (64-bit, prefetchable) [size=64K]
        [virtual] Expansion ROM at fdb00000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=0/0 Enable+
                Address: 00000000fee0f00c  Data: 4171
        Capabilities: [70] Express (v1) Endpoint, MSI 01
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<512ns, L1 <64us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 4096 bytes
                DevSta: CorrErr- UncorrErr- FatalErr- UnsuppReq- AuxPwr+
TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <512ns, L1 <64us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain-
CommClk+
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train- SlotClk+
DLActive- BWMgmt- ABWMgmt-
        Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00000800
        Capabilities: [d0] Vital Product Data <?>
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Virtual Channel <?>
        Capabilities: [160] Device Serial Number 00-e0-4c-68-00-00-00-33
        Kernel driver in use: r8169
        Kernel modules: r8169

- Working NICS. Ony of the daughter board expansion also using r8169 (
http://www.jetway.com.tw/jw/ipcboard_view.asp?productid=174&proname=AD3RTLAN-G
). Output of lspci -vvv:
02:04.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
        Subsystem: Jetway Information Co., Ltd. Device 10ec
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 18
        Region 0: I/O ports at ee00 [size=256]
        Region 1: Memory at fddff000 (32-bit, non-prefetchable) [size=256]
        [virtual] Expansion ROM at fdc00000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: r8169
        Kernel modules: r8169

02:06.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
        Subsystem: Jetway Information Co., Ltd. Device 10ec
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 19
        Region 0: I/O ports at ec00 [size=256]
        Region 1: Memory at fddfe000 (32-bit, non-prefetchable) [size=256]
        [virtual] Expansion ROM at fdc20000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: r8169
        Kernel modules: r8169

02:07.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8110SC/8169SC Gigabit Ethernet (rev 10)
        Subsystem: Jetway Information Co., Ltd. Device 10ec
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 64 (8000ns min, 16000ns max), Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 16
        Region 0: I/O ports at ea00 [size=256]
        Region 1: Memory at fddfd000 (32-bit, non-prefetchable) [size=256]
        [virtual] Expansion ROM at fdc40000 [disabled] [size=128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Kernel driver in use: r8169
        Kernel modules: r8169

This is first time install. It happens on a 2.6.29-rc5 on x86_64 Kernel.
It is not a clean vanilla, but an openSUSE Kotd Kernel. However, by
taking a wide look at openSUSE's source rpm, i found no patch that could
trigger this... I could test it with a vanilla kernel. It would be hard
to compile a kernel on a Dual Atom 330 cpu but, is feasible...

Is there any patch I can try before trying anything more elaborate ?
I've scanned the 2.6.29-rc5 r8169 driver and found no specific tweek for
this NIC ( RTL8111/8168B ), so it may be a case of lack of support for it...

Also CCing driver maintainer Francois Romieu and netdev ML.

Thanks for your time,

-- 
Rui Santos
http://www.ruisantos.com/

Veni, vidi, Linux!

