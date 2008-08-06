From: "John P Poet" <jppoet@gmail.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Tue, 5 Aug 2008 23:21:25 -0600
Message-ID: <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com>
	 <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com>
	 <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com>
	 <20080805214250.GA23226@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:50524 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbYHFFV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2008 01:21:28 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1487596fgg.17
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 22:21:26 -0700 (PDT)
In-Reply-To: <20080805214250.GA23226@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 5, 2008 at 3:42 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> (please Cc: the maintainer)
>
> John P Poet <jppoet@gmail.com> :
> [...]
>> I just tried applying ALL the patches found here:
>>
>> http://userweb.kernel.org/~romieu/r8169/2.6.27-rc1/20080803.tar.bz2
>>
>> against 2.6.26.1.  Worked for a while, I then I got:
>
> Try to add 0002-r8169-avoid-thrashing-PCI-conf-space-above-RTL_GIGA.patch
> from http://userweb.kernel.org/~romieu/r8169/2.6.26/20080717/
>
> It is in 2.6.27-rc1 as 77332894c21165404496c56763d7df6c15c4bb09.
>
> --
> Ueimor
>

Thank you for the response.  That DOES seem to fix the cold-boot issue.

Unfortunately, it does not fix the timeout problem.  I am still
experiencing transmittion problems:

===================================================================
Aug  5 22:42:31 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  5 22:42:31 saphire kernel: ------------[ cut here ]------------
Aug  5 22:42:31 saphire kernel: WARNING: at
net/sched/sch_generic.c:222 dev_watchdog+0xb6/0x116()
Aug  5 22:42:31 saphire kernel: Modules linked in: hdpvr videodev
v4l1_compat v4l2_common nfs nfsd lockd nfs_acl auth_rpcgss exportfs
autofs4 coretemp hwmon fuse sunrpc ipv6 acpi_cpufreq xfs dm_mirror
dm_log dm_multipath dm_mod raid456 async_xor async_memcpy async_tx xor
snd_hda_intel snd_seq_dummy snd_seq_oss snd_seq_midi_event i2c_i801
snd_seq serio_raw pcspkr sr_mod i2c_core cdrom snd_seq_device
snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd_page_alloc snd_hwdep
r8169 snd pl2303 usbserial soundcore sg button sata_mv sata_sil24 ahci
libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd
[last unloaded: microcode]
Aug  5 22:42:31 saphire kernel: Pid: 0, comm: swapper Not tainted 2.6.26.1b #1
Aug  5 22:42:31 saphire kernel:
Aug  5 22:42:31 saphire kernel: Call Trace:
Aug  5 22:42:31 saphire kernel:  <IRQ>  [<ffffffff81031fa8>]
warn_on_slowpath+0x58/0x86
Aug  5 22:42:31 saphire kernel:  [<ffffffff8103a78e>] ? __mod_timer+0xc1/0xd3
Aug  5 22:42:31 saphire kernel:  [<ffffffff81041458>] ?
queue_delayed_work_on+0xc3/0xd6
Aug  5 22:42:31 saphire kernel:  [<ffffffff81216891>] ? dev_watchdog+0x0/0x116
Aug  5 22:42:31 saphire kernel:  [<ffffffff810414a7>] ?
queue_delayed_work+0x21/0x23
Aug  5 22:42:31 saphire kernel:  [<ffffffff810414c2>] ?
schedule_delayed_work+0x19/0x1b
Aug  5 22:42:31 saphire kernel:  [<ffffffffa00ec0d2>] ?
:r8169:rtl8169_schedule_work+0x23/0x25
Aug  5 22:42:31 saphire kernel:  [<ffffffff81216947>] dev_watchdog+0xb6/0x116
Aug  5 22:42:31 saphire kernel:  [<ffffffff8103a230>]
run_timer_softirq+0x16c/0x1e1
Aug  5 22:42:31 saphire kernel:  [<ffffffff81036a93>] __do_softirq+0x57/0xc7
Aug  5 22:42:31 saphire kernel:  [<ffffffff8100d06c>] call_softirq+0x1c/0x28
Aug  5 22:42:31 saphire kernel:  [<ffffffff8100e7b6>] do_softirq+0x34/0x72
Aug  5 22:42:31 saphire kernel:  [<ffffffff81036a3a>] irq_exit+0x3f/0x41
Aug  5 22:42:31 saphire kernel:  [<ffffffff8101a078>]
smp_apic_timer_interrupt+0x8b/0xa7
Aug  5 22:42:31 saphire kernel:  [<ffffffff8100cb16>]
apic_timer_interrupt+0x66/0x70
Aug  5 22:42:31 saphire kernel:  <EOI>  [<ffffffff81174ada>] ?
acpi_safe_halt+0x2b/0x3e
Aug  5 22:42:31 saphire kernel:  [<ffffffff811e88b3>] ?
cpuidle_idle_call+0x0/0xa1
Aug  5 22:42:31 saphire kernel:  [<ffffffff81174b99>] ?
acpi_idle_enter_c1+0xac/0x10a
Aug  5 22:42:31 saphire kernel:  [<ffffffff811e8923>] ?
cpuidle_idle_call+0x70/0xa1
Aug  5 22:42:31 saphire kernel:  [<ffffffff811e88b3>] ?
cpuidle_idle_call+0x0/0xa1
Aug  5 22:42:31 saphire kernel:  [<ffffffff8100ac02>] ? cpu_idle+0x75/0x93
Aug  5 22:42:31 saphire kernel:  [<ffffffff8127356d>] ? rest_init+0x61/0x63
Aug  5 22:42:31 saphire kernel:
Aug  5 22:42:31 saphire kernel: ---[ end trace de25ab7d23456abe ]---
Aug  5 22:42:31 saphire kernel: r8169: eth0: link up

...

Aug  5 22:45:07 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  5 22:45:07 saphire kernel: r8169: eth0: link up

...

Aug  5 22:49:37 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  5 22:49:37 saphire kernel: r8169: eth0: link up
Aug  5 22:50:49 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
Aug  5 22:50:49 saphire kernel: r8169: eth0: link up

06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
        Subsystem: Giga-byte Technology Unknown device e000
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 2292
        Region 0: I/O ports at 9000 [size=256]
        Region 2: Memory at e0010000 (64-bit, prefetchable) [size=4K]
        Region 4: Memory at e0000000 (64-bit, prefetchable) [size=64K]
        [virtual] Expansion ROM at e0020000 [disabled] [size=64K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=0/1 Enable+
                Address: 00000000fee0200c  Data: 41d1
        Capabilities: [70] Express (v1) Endpoint, MSI 01
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<512ns, L1 <8us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <512ns, L1 <64us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train-
SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00000800
        Capabilities: [d0] Vital Product Data <?>
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Virtual Channel <?>
        Capabilities: [160] Device Serial Number 78-56-34-12-78-56-34-12
        Kernel driver in use: r8169
        Kernel modules: r8169
===================================================================


I tried applying that patch along with the others I had already
grabbed from your directory and I still had the timeout problem.  I
unpacked a fresh copy of linux-2.6.26.1 and just applied that one
patch to it and still have the timeout problem.


Again, in case it helps:
===================================================================
lspci -vv
06:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)
        Subsystem: Giga-byte Technology Unknown device e000
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B- DisINTx+
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR- INTx-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 2292
        Region 0: I/O ports at 9000 [size=256]
        Region 2: Memory at e0010000 (64-bit, prefetchable) [size=4K]
        Region 4: Memory at e0000000 (64-bit, prefetchable) [size=64K]
        [virtual] Expansion ROM at e0020000 [disabled] [size=64K]
        Capabilities: [40] Power Management version 3
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=0/1 Enable+
                Address: 00000000fee0200c  Data: 41d1
        Capabilities: [70] Express (v1) Endpoint, MSI 01
                DevCap: MaxPayload 256 bytes, PhantFunc 0, Latency L0s
<512ns, L1 <8us
                        ExtTag- AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
                DevCtl: Report errors: Correctable- Non-Fatal- Fatal-
Unsupported-
                        RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop-
                        MaxPayload 128 bytes, MaxReadReq 512 bytes
                DevSta: CorrErr+ UncorrErr- FatalErr- UnsuppReq+
AuxPwr+ TransPend-
                LnkCap: Port #0, Speed 2.5GT/s, Width x1, ASPM L0s L1,
Latency L0 <512ns, L1 <64us
                        ClockPM+ Suprise- LLActRep- BwNot-
                LnkCtl: ASPM Disabled; RCB 64 bytes Disabled- Retrain- CommClk-
                        ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
                LnkSta: Speed 2.5GT/s, Width x1, TrErr- Train-
SlotClk+ DLActive- BWMgmt- ABWMgmt-
        Capabilities: [b0] MSI-X: Enable- Mask- TabSize=2
                Vector table: BAR=4 offset=00000000
                PBA: BAR=4 offset=00000800
        Capabilities: [d0] Vital Product Data <?>
        Capabilities: [100] Advanced Error Reporting <?>
        Capabilities: [140] Virtual Channel <?>
        Capabilities: [160] Device Serial Number 78-56-34-12-78-56-34-12
        Kernel driver in use: r8169
        Kernel modules: r8169
===================================================================


I have run memtest86+ on this machine for 12 hours, and it did not
find any problems.

Is there anything else I can try?

Thanks,

John
-- 
A: Because it messes up the order in which people normally read text.
Q: Why is top-posting such a bad thing?
