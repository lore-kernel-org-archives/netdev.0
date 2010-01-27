From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [E1000-devel] 2.6.33-rc5: (e1000): transmit queue 0 timed out
Date: Wed, 27 Jan 2010 11:55:50 +0300
Message-ID: <a4423d671001270055h6b699678rb117b560276f194d@mail.gmail.com>
References: <a4423d671001230737i3b3c7da1q6cd4ce615888b36e@mail.gmail.com>
	 <alpine.WNT.2.00.1001251704310.2536@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:56118 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752731Ab0A0Izw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 03:55:52 -0500
Received: by ewy19 with SMTP id 19so179545ewy.21
        for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 00:55:50 -0800 (PST)
In-Reply-To: <alpine.WNT.2.00.1001251704310.2536@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/1/26 Brandeburg, Jesse <jesse.brandeburg@intel.com>:
>
>
> On Sat, 23 Jan 2010, Alexander Beregalov wrote:
>> It is x86_32, UP
>>
>> e1000: eth0: e1000_clean_tx_irq: Detected Tx Unit Hang
>> =C2=A0 Tx Queue =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 <0>
>> =C2=A0 TDH =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0<0>
>
> The queue seems to have not been started... =C2=A0what test are you r=
unning?
> what kind of traffic and system? =C2=A0(lspci -vvv please)

The host just does regular tasks - NFS server and rtorrent client.

01:0a.0 Ethernet controller [0200]: Intel Corporation 82540EM Gigabit
Ethernet Controller [8086:100e] (rev 02)
        Subsystem: Intel Corporation PRO/1000 MT Desktop Adapter [8086:=
002e]
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx-
        Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=3Dmedium
>TAbort- <TAbort- <MAbort- >SERR- <PERR+ INTx-
        Latency: 64 (63750ns min)
        Interrupt: pin A routed to IRQ 18
        Region 0: Memory at ec000000 (32-bit, non-prefetchable) [size=3D=
128K]
        Region 1: Memory at ec020000 (32-bit, non-prefetchable) [size=3D=
128K]
        Region 2: I/O ports at a040 [size=3D64]
        [virtual] Expansion ROM at 60080000 [disabled] [size=3D128K]
        Capabilities: [dc] Power Management version 2
                Flags: PMEClk- DSI+ D1- D2- AuxCurrent=3D0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                Status: D0 NoSoftRst- PME-Enable- DSel=3D0 DScale=3D1 P=
ME-
        Capabilities: [e4] PCI-X non-bridge device
                Command: DPERE- ERO+ RBC=3D512 OST=3D1
                Status: Dev=3D00:00.0 64bit- 133MHz- SCD- USC- DC=3Dsim=
ple
DMMRBC=3D2048 DMOST=3D1 DMCRS=3D16 RSCEM- 266MHz- 533MHz-
        Capabilities: [f0] MSI: Enable- Count=3D1/1 Maskable- 64bit+
                Address: 0000000000000000  Data: 0000
        Kernel driver in use: e1000

>
>
>> =C2=A0 TDT =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0<1f>
>> =C2=A0 next_to_use =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<1f>
>> =C2=A0 next_to_clean =C2=A0 =C2=A0 =C2=A0 =C2=A0<30>
>> buffer_info[next_to_clean]
>> =C2=A0 time_stamp =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 <12d519>
>> =C2=A0 next_to_watch =C2=A0 =C2=A0 =C2=A0 =C2=A0<30>
>> =C2=A0 jiffies =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0<12da=
92>
>> =C2=A0 next_to_watch.status <0>
>> WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x1c5/0x1d0()
>> Hardware name:
>> NETDEV WATCHDOG: eth0 (e1000): transmit queue 0 timed out
>> Modules linked in: hwmon_vid sata_sil i2c_nforce2
>> Pid: 0, comm: swapper Not tainted 2.6.33-rc5 #1
>> Call Trace:
>> =C2=A0[<c102a49d>] warn_slowpath_common+0x6d/0xa0
>> =C2=A0[<c12ea885>] ? dev_watchdog+0x1c5/0x1d0
>> =C2=A0[<c12ea885>] ? dev_watchdog+0x1c5/0x1d0
>> =C2=A0[<c102a516>] warn_slowpath_fmt+0x26/0x30
>> =C2=A0[<c12ea885>] dev_watchdog+0x1c5/0x1d0
>> =C2=A0[<c1033bb7>] ? run_timer_softirq+0xd7/0x240
>> =C2=A0[<c1033c31>] run_timer_softirq+0x151/0x240
>> =C2=A0[<c1033bb7>] ? run_timer_softirq+0xd7/0x240
>> =C2=A0[<c12ea6c0>] ? dev_watchdog+0x0/0x1d0
>> =C2=A0[<c102f40a>] __do_softirq+0x7a/0x110
>> =C2=A0[<c102f4ed>] do_softirq+0x4d/0x60
>> =C2=A0[<c102f625>] irq_exit+0x65/0x70
>> =C2=A0[<c1015fe7>] smp_apic_timer_interrupt+0x47/0x80
>> =C2=A0[<c11d6904>] ? trace_hardirqs_off_thunk+0xc/0x18
>> =C2=A0[<c1350e63>] apic_timer_interrupt+0x2f/0x34
>> =C2=A0[<c10088fd>] ? default_idle+0x2d/0x60
>> =C2=A0[<c1001b19>] cpu_idle+0x39/0x60
>> =C2=A0[<c13451e8>] rest_init+0x48/0x50
>> =C2=A0[<c16196b4>] start_kernel+0x26d/0x274
>> =C2=A0[<c1619275>] ? unknown_bootoption+0x0/0x19c
>> =C2=A0[<c1619068>] i386_start_kernel+0x68/0x6e
>> ---[ end trace 828c510cca9472df ]---
>> BUG: unable to handle kernel paging request at 2e8ca4f3
>> IP: [<c1071c51>] put_page+0x11/0x120
>
> hm, put_page panic, are you running with jumbo frames enabled? =C2=A0=
Does your
> network have jumbo frame traffic on it?

Jumbo frames are disabled, no jumbo frame traffic.
>
>> *pde =3D 00000000
>> Oops: 0000 [#1]
>> last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspe=
ed
>> Modules linked in: hwmon_vid sata_sil i2c_nforce2
>>
>> Pid: 5, comm: events/0 Tainted: G =C2=A0 =C2=A0 =C2=A0 =C2=A0W =C2=A0=
2.6.33-rc5 #1
>> NF7-S/NF7,NF7-V (nVidia-nForce2)/
>> EIP: 0060:[<c1071c51>] EFLAGS: 00010282 CPU: 0
>> EIP is at put_page+0x11/0x120
>> EAX: 2e8ca4f3 EBX: 2e8ca4f3 ECX: 00000000 EDX: ee960640
>> ESI: f6482620 EDI: 000016b0 EBP: f7065ea8 ESP: f7065e98
>> =C2=A0DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
>> Process events/0 (pid: 5, ti=3Df7064000 task=3Df70553c0 task.ti=3Df7=
064000)
>> Stack:
>> =C2=A000000206 00000001 f6482620 000016b0 f7065eb8 c12d3100 f6482620=
 f71d9f50
>> <0> f7065ec4 c12d2e32 f80376b0 f7065ecc c12d2ec5 f7065f00 c1276970 c=
ccccccd
>> <0> f7065f00 f711fafc f711fafc f711faa0 00000000 f702b440 000000f2 f=
702b440
>> Call Trace:
>> =C2=A0[<c12d3100>] ? skb_release_data+0x90/0xa0
>> =C2=A0[<c12d2e32>] ? __kfree_skb+0x12/0x90
>> =C2=A0[<c12d2ec5>] ? consume_skb+0x15/0x30
>> =C2=A0[<c1276970>] ? e1000_clean_rx_ring+0x80/0x150
>> =C2=A0[<c127c743>] ? e1000_down+0x1b3/0x1d0
>> =C2=A0[<c127cf60>] ? e1000_reset_task+0x0/0x10
>> =C2=A0[<c127cd3b>] ? e1000_reinit_locked+0x4b/0x70
>> =C2=A0[<c127cf6d>] ? e1000_reset_task+0xd/0x10
>> =C2=A0[<c103a9ea>] ? worker_thread+0x14a/0x230
>> =C2=A0[<c103a989>] ? worker_thread+0xe9/0x230
>> =C2=A0[<c103e160>] ? autoremove_wake_function+0x0/0x40
>> =C2=A0[<c103a8a0>] ? worker_thread+0x0/0x230
>> =C2=A0[<c103de6c>] ? kthread+0x6c/0x80
>> =C2=A0[<c103de00>] ? kthread+0x0/0x80
>> =C2=A0[<c100303a>] ? kernel_thread_helper+0x6/0x1c
>> Code: 00 00 00 8d bc 27 00 00 00 00 55 b8 e0 1f 07 c1 89 e5 e8 83 93
>> fc ff c9 c3 90 55 89 e5 83 ec 10 89 5d f4 89 75 f8 89 c3 89 7d fc <6=
6>
>> f7 00 00 c0 0f 85 e4 00 00 00 8b 40 04 85 c0 0f 84 e3 00 00
>> EIP: [<c1071c51>] put_page+0x11/0x120 SS:ESP 0068:f7065e98
>> CR2: 000000002e8ca4f3
>> ---[ end trace 828c510cca9472e0 ]---
>
>
> Thanks for the report, do you believe it to be new to e1000 in 2.6.33=
-rc5?
> Have you had failure like this before and/or can you see the same fai=
lure
> on 2.6.32?

Yes, I believe it is new to 2.6.33-rc5, I have not seen it before.
