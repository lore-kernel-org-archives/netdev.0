From: "David Madsen" <david.madsen@gmail.com>
Subject: Re: Realtek 8111C transmit timed out
Date: Mon, 11 Aug 2008 22:42:23 -0700
Message-ID: <ec7e30370808112242y4be0ba5fy6d3567e0dc49b6fd@mail.gmail.com>
References: <2c2a4e250808041812j569f6565s9f4ae54f44bbfbb5@mail.gmail.com>
	 <2c2a4e250808041900id64a2b8h1b7cee3b70960ebc@mail.gmail.com>
	 <2c2a4e250808042042j6c448068v98a6b5e428fa1a7@mail.gmail.com>
	 <20080805214250.GA23226@electric-eye.fr.zoreil.com>
	 <2c2a4e250808052221p7d22adf5w7a656e423bff0b26@mail.gmail.com>
	 <20080806190353.GB17174@electric-eye.fr.zoreil.com>
	 <2c2a4e250808062251p74f97863l770727843921a5c4@mail.gmail.com>
	 <20080807223137.GA17407@electric-eye.fr.zoreil.com>
	 <2c2a4e250808072028h8b7a13av29ec02f76ab08cd1@mail.gmail.com>
	 <2c2a4e250808072051v6b0b42eaxb66e927e094dba78@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: "John P Poet" <jppoet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:52624 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbYHLFmZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 01:42:25 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1244430fgg.17
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2008 22:42:23 -0700 (PDT)
In-Reply-To: <2c2a4e250808072051v6b0b42eaxb66e927e094dba78@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 2) I am getting a lot of timeouts:
>
> Aug  4 17:49:35 saphire kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Aug  4 17:49:35 saphire kernel: r8169: eth0: link up
...
>
> While the booting problem is annoying, the timeouts are actually even
> more so.  I am a mythtv users, and those timeouts cause my video/audio
> streaming to fail.

I also have a Realtek GigE card that was quite stable running on
2.6.24.  I recently updated my kernel briefly to 2.6.25.10 then
ultimately to 2.6.26.2 and started seeing similar timeouts in both
kernel versions.  My configuration didn't change much between the
kernels, but I do remember enabling MSI when I rebuit the kernel.  I
have not yet had a chance to disable MSI to see if that fixes the
timeouts but I thought I'd post what info I have in case that might
steer the debug in the right direction.  The frequency of the timeouts
has been quite low, and once the interface comes back up everything
seems to continue to function properly.  I haven't applied any of the
discussed patches yet, but I have set up the machine to disable MSI
the next time I am able to reboot it.  Prior to the kernel update from
2.6.24, MSI was diabled and I did not have any issues with timeouts on
the interface.  Let me know if I can provide any more information that
may help with this debug.

Here is the initialization:

Aug  6 17:02:13 [kernel] r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
Aug  6 17:02:13 [kernel] ACPI: PCI Interrupt 0000:04:00.0[A] -> GSI 16
(level, low) -> IRQ 16
Aug  6 17:02:13 [kernel] PCI: Setting latency timer of device 0000:04:00.0 to 64
Aug  6 17:02:13 [kernel] eth0: RTL8168b/8111b at 0xf881e000,
00:1a:4d:53:cd:0f, XID 38000000 IRQ 218

Several days later the first timeout:

NETDEV WATCHDOG: eth0: transmit timed out
------------[ cut here ]------------
WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0xfd/0x110()
Modules linked in: xfs nfs coretemp it87 hwmon_vid eeprom nfsd lockd
sunrpc exportfs snd_pcm_oss snd_mixer_oss snd_seq_oss
snd_seq_midi_event snd_seq snd_seq_device fuse raid0 raid456 async_xor
async_memcpy async_tx xor md_mod raw1394 or51132 usbhid cx88_dvb
cx88_vp3054_i2c videobuf_dvb dvb_core tuner_simple tuner_types tda9887
tda8290 tuner tvaudio nvidia(P) msp3400 cx8800 cx88_alsa cx8802 cx88xx
bttv firmware_class compat_ioctl32 videodev v4l1_compat ir_common
i2c_algo_bit ehci_hcd v4l2_common videobuf_dma_sg ohci1394
videobuf_core btcx_risc ieee1394 uhci_hcd usbcore r8169 snd_hda_intel
evdev snd_pcm snd_timer tveeprom snd soundcore snd_page_alloc i2c_i801
i2c_core
Pid: 0, comm: swapper Tainted: P          2.6.26.2 #1
 [<c012258f>] warn_on_slowpath+0x5f/0x90
 [<c01191cb>] __wake_up_common+0x4b/0x80
 [<c011a38e>] __wake_up+0x3e/0x60
 [<c0122d6b>] wake_up_klogd+0x3b/0x40
 [<c0123431>] vprintk+0x2f1/0x380
 [<c012b857>] lock_timer_base+0x27/0x60
 [<c012b996>] __mod_timer+0x96/0xb0
 [<c013261b>] queue_delayed_work_on+0x7b/0xb0
 [<c02af9bd>] dev_watchdog+0xfd/0x110
 [<c012b2c0>] run_timer_softirq+0x120/0x190
 [<c013f264>] tick_program_event+0x44/0x70
 [<c02af8c0>] dev_watchdog+0x0/0x110
 [<c01275c2>] __do_softirq+0x82/0x100
 [<c0127677>] do_softirq+0x37/0x40
 [<c0127785>] irq_exit+0x75/0x90
 [<c0112787>] smp_apic_timer_interrupt+0x57/0x90
 [<c0103a7c>] apic_timer_interrupt+0x28/0x30
 [<c01093c2>] mwait_idle+0x32/0x40
 [<c0109390>] mwait_idle+0x0/0x40
 [<c0101a9d>] cpu_idle+0x4d/0xb0
 =======================
---[ end trace 3239fda7c0460ac6 ]---
r8169: eth0: link up


lspci output (a few hours after the timout occurred):

04:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. Unknown
device 8168 (rev 01)
        Subsystem: Giga-byte Technology Unknown device e000
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
        Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
        Latency: 0, Cache Line Size: 32 bytes
        Interrupt: pin A routed to IRQ 218
        Region 0: I/O ports at d000 [size=256]
        Region 2: Memory at ed000000 (64-bit, non-prefetchable) [size=4K]
        [virtual] Expansion ROM at 40000000 [disabled] [size=128K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME-
        Capabilities: [48] Vital Product Data
        Capabilities: [50] Message Signalled Interrupts: Mask- 64bit+
Queue=0/1 Enable+
                Address: 00000000fee0100c  Data: 4132
        Capabilities: [60] Express Endpoint IRQ 0
                Device: Supported: MaxPayload 1024 bytes, PhantFunc 0, ExtTag+
                Device: Latency L0s <128ns, L1 unlimited
                Device: AtnBtn+ AtnInd+ PwrInd+
                Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
                Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
                Device: MaxPayload 128 bytes, MaxReadReq 4096 bytes
                Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s, Port 0
                Link: Latency L0s unlimited, L1 unlimited
                Link: ASPM Disabled RCB 64 bytes CommClk- ExtSynch-
                Link: Speed 2.5Gb/s, Width x1
        Capabilities: [84] Vendor Specific Information
        Capabilities: [100] Advanced Error Reporting
        Capabilities: [12c] Virtual Channel
        Capabilities: [148] Device Serial Number 68-81-ec-10-00-00-00-00
        Capabilities: [154] Power Budgeting
