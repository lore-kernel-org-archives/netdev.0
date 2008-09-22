From: Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: OOPS bug KERNEL LINUX- Version 2.6.26
Date: Tue, 23 Sep 2008 00:25:03 +0200
Message-ID: <200809230025.03680.IvDoorn@gmail.com>
References: <K7M9ZI$69A44BBF23D86D612A80B0EA98EEEE6B@libero.it> <20080922.151635.200306286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: andrea_monta-e7mAqy1nzl5eoWH0uzbU5w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080922.151635.200306286.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

> > 1. Problem with usb-wireless-key 
> > 2. I can't find my device typing ifconfig -a or iwconfig I don't find any wireless attached device. But I have my usb wireless connected. A belkin usb wireless key.Before, with the kernel 2.6.25 all worked well
> > 3. nothing
> > 4. Linux version 2.6.26 (root@clementino) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #1 PREEMPT Mon Sep 22 15:57:45 CEST 2008
> > 5.

You missed the message from rt2x00 2 lines above this trace, which undoubtly have said something like:
	"Invalid RT chipset detected."
which is triggered when rt73usb is loaded for a device it does not support

The current workaround for this issue is blacklisting rt73usb and making sure the driver
which is required for your driver is loaded instead.

I'll look into the reason why this actually triggers a NULL pointer, since that is obviously a nasty bug.

Ivo

> > BUG: unable to handle kernel NULL pointer dereference at 0000001c
> > IP: [<c01406d3>] __lock_acquire+0x1d3/0xfd0
> > *pde = 00000000
> > Oops: 0000 [#1] PREEMPT
> > Modules linked in: rt73usb(+) crc_itu_t rt2x00usb rt2x00lib rfkill led_class input_polldev usbhid p54usb p54common mac80211 cfg80211 snd_via82xx i2c_viapro gameport snd_ac97_codec ac97_bus snd_mpu401_uart tuner_simple tuner_types snd_rawmidi tuner tvaudio via_rhine msp3400 snd_bt87x snd_pcm_oss snd_mixer_oss bttv videodev v4l1_compat ir_common snd_pcm compat_ioctl32 i2c_algo_bit uhci_hcd via_ircc v4l2_common videobuf_dma_sg videobuf_core ehci_hcd btcx_risc irda thermal button snd_timer snd_page_alloc tveeprom usbcore i2c_core shpchp pci_hotplug via_agp evdev
> > 
> > Pid: 2137, comm: modprobe Not tainted (2.6.26 #1)
> > EIP: 0060:[<c01406d3>] EFLAGS: 00010046 CPU: 0
> > EIP is at __lock_acquire+0x1d3/0xfd0
> > EAX: 00000000 EBX: 00000246 ECX: 00000000 EDX: 00000018
> > ESI: 00000000 EDI: 00000000 EBP: edc07cb4 ESP: edc07c48
> >  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> > Process modprobe (pid: 2137, ti=edc06000 task=ef9fe030 task.ti=edc06000)
> > Stack: ef9fe030 c049283a 00000246 00000000 00000213 c068b262 ee9cf374 00000043
> >        00000000 00000000 00000018 00000004 ef9fe030 edc07c84 c04928d8 edc07cb4
> >        f0a766a4 00003000 edc07cf4 00001618 ee9cf160 00000002 edc07cb4 c011fa5b
> > Call Trace:
> >  [<c049283a>] ? __mutex_unlock_slowpath+0xaa/0x140
> >  [<c04928d8>] ? mutex_unlock+0x8/0x10
> >  [<f0a766a4>] ? rt2x00usb_vendor_request_buff+0x64/0x80 [rt2x00usb]
> >  [<c011fa5b>] ? printk+0x1b/0x20
> >  [<c0141548>] ? lock_acquire+0x78/0xa0
> >  [<c012f6e0>] ? flush_workqueue+0x0/0x60
> >  [<c012f715>] ? flush_workqueue+0x35/0x60
> >  [<c012f6e0>] ? flush_workqueue+0x0/0x60
> >  [<f0a7b2b3>] ? rt2x00lib_remove_dev+0x33/0x60 [rt2x00lib]
> >  [<f0a7bbda>] ? rt2x00lib_probe_dev+0x5a/0x3e0 [rt2x00lib]
> >  [<f0a760ac>] ? rt2x00usb_alloc_reg+0x4c/0xa0 [rt2x00usb]
> >  [<c0135483>] ? __mutex_init+0x43/0x60
> >  [<f0a76b0b>] ? rt2x00usb_probe+0xcb/0x150 [rt2x00usb]
> >  [<f087b97a>] ? usb_match_one_id+0x2a/0xb0 [usbcore]
> >  [<f087c719>] ? usb_probe_interface+0x69/0xe0 [usbcore]
> >  [<c0341ebb>] ? driver_sysfs_add+0x5b/0x80
> >  [<c0341fe3>] ? driver_probe_device+0x83/0x180
> >  [<c0494409>] ? _spin_unlock_irqrestore+0x39/0x70
> >  [<c0342155>] ? __driver_attach+0x75/0x80
> >  [<c0341693>] ? bus_for_each_dev+0x43/0x70
> >  [<c0341e59>] ? driver_attach+0x19/0x20
> >  [<c03420e0>] ? __driver_attach+0x0/0x80
> >  [<c0341aef>] ? bus_add_driver+0xaf/0x220
> >  [<c03422ef>] ? driver_register+0x4f/0x130
> >  [<c02c5cc2>] ? __spin_lock_init+0x32/0x60
> >  [<f087c2a2>] ? usb_register_driver+0x82/0x100 [usbcore]
> >  [<f08ae017>] ? rt73usb_init+0x17/0x19 [rt73usb]
> >  [<c0147e03>] ? sys_init_module+0x123/0x1a10
> >  [<f0a7c710>] ? rt2x00mac_bss_info_changed+0x0/0x100 [rt2x00lib]
> >  [<c0104189>] ? sysenter_past_esp+0x6a/0xb1
> >  =======================
> > Code: 24 a4 82 56 c0 e8 8e f3 fd ff 8d b4 26 00 00 00 00 8d bc 27 00 00 00 00 31 d2 83 c4 60 89 d0 5b 5e 5f 5d c3 8d 74 26 00 8b 55 bc <8b> 7a 04 85 ff 0f 84 7a fe ff ff ff 87 c0 00 00 00 89 f8 e8 95
> > EIP: [<c01406d3>] __lock_acquire+0x1d3/0xfd0 SS:ESP 0068:edc07c48
> > ---[ end trace 69bb391af1abff2a ]---
> > eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
> > NET: Registered protocol family 17
> > NET: Registered protocol family 10
> > lo: Disabled Privacy Extensions
> > warning: `avahi-daemon' uses 32-bit capabilities (legacy support in use)
> > eth0: no IPv6 routers present
> > 6.
> > 7. Linux debian
> > 7.2 processor       : 0
> > vendor_id       : GenuineIntel
> > cpu family      : 15
> > model           : 2
> > model name      : Intel(R) Celeron(R) CPU 2.60GHz
> > stepping        : 9
> > cpu MHz         : 2599.925
> > cache size      : 128 KB
> > fdiv_bug        : no
> > hlt_bug         : no
> > f00f_bug        : no
> > coma_bug        : no
> > fpu             : yes
> > fpu_exception   : yes
> > cpuid level     : 2
> > wp              : yes
> > flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe pebs bts cid xtpr
> > bogomips        : 5206.37
> > clflush size    : 64
> > power management:
> > 7.3 modules
> > ipv6 269652 8 - Live 0xf0b26000
> > af_packet 16400 2 - Live 0xf0a95000
> > rt73usb 25625 1 - Loading 0xf0a8d000
> > crc_itu_t 2176 1 rt73usb, Live 0xf0964000
> > rt2x00usb 10632 1 rt73usb, Live 0xf0a76000
> > rt2x00lib 26032 2 rt73usb,rt2x00usb, Live 0xf0a7b000
> > rfkill 6812 1 rt2x00lib, Live 0xf082c000
> > led_class 4108 1 rt2x00lib, Live 0xf0a6e000
> > input_polldev 4248 1 rt2x00lib, Live 0xf0a6b000
> > usbhid 28608 0 - Live 0xf098f000
> > p54usb 12680 0 - Live 0xf0977000
> > p54common 11272 1 p54usb, Live 0xf097c000
> > mac80211 172716 4 rt2x00usb,rt2x00lib,p54usb,p54common, Live 0xf0aa2000
> > cfg80211 24344 2 rt2x00lib,mac80211, Live 0xf0988000
> > snd_via82xx 23088 0 - Live 0xf0981000
> > i2c_viapro 7956 0 - Live 0xf0923000
> > gameport 12312 1 snd_via82xx, Live 0xf08a2000
> > snd_ac97_codec 98884 1 snd_via82xx, Live 0xf09da000
> > ac97_bus 1920 1 snd_ac97_codec, Live 0xf095d000
> > snd_mpu401_uart 7320 1 snd_via82xx, Live 0xf0927000
> > tuner_simple 13840 1 - Live 0xf0972000
> > tuner_types 13952 1 tuner_simple, Live 0xf096d000
> > snd_rawmidi 20672 1 snd_mpu401_uart, Live 0xf0966000
> > tuner 26440 0 - Live 0xf091b000
> > tvaudio 22076 0 - Live 0xf0956000
> > via_rhine 21784 0 - Live 0xf08d9000
> > msp3400 29644 0 - Live 0xf0908000
> > snd_bt87x 12260 0 - Live 0xf0904000
> > snd_pcm_oss 36800 0 - Live 0xf0911000
> > snd_mixer_oss 13960 1 snd_pcm_oss, Live 0xf08ff000
> > bttv 174580 0 - Live 0xf092a000
> > videodev 31648 3 tuner,msp3400,bttv, Live 0xf08b0000
> > v4l1_compat 14084 1 videodev, Live 0xf08d4000
> > ir_common 40068 1 bttv, Live 0xf08e0000
> > snd_pcm 72492 4 snd_via82xx,snd_ac97_codec,snd_bt87x,snd_pcm_oss, Live 0xf08ec000
> > compat_ioctl32 1280 1 bttv, Live 0xf08a7000
> > i2c_algo_bit 6020 1 bttv, Live 0xf08a9000
> > uhci_hcd 21652 0 - Live 0xf089b000
> > via_ircc 18972 0 - Live 0xf085e000
> > v4l2_common 11264 4 tuner,tvaudio,msp3400,bttv, Live 0xf084e000
> > videobuf_dma_sg 12420 1 bttv, Live 0xf0864000
> > videobuf_core 17932 2 bttv,videobuf_dma_sg, Live 0xf0895000
> > ehci_hcd 32404 0 - Live 0xf086a000
> > btcx_risc 4616 1 bttv, Live 0xf085b000
> > irda 106476 1 via_ircc, Live 0xf08b9000
> > thermal 15524 0 - Live 0xf0837000
> > button 6288 0 - Live 0xf084b000
> > snd_timer 21148 1 snd_pcm, Live 0xf0854000
> > snd_page_alloc 8584 3 snd_via82xx,snd_bt87x,snd_pcm, Live 0xf083c000
> > tveeprom 12164 1 bttv, Live 0xf0847000
> > usbcore 133808 7 rt73usb,rt2x00usb,usbhid,p54usb,uhci_hcd,ehci_hcd, Live 0xf0873000
> > i2c_core 22672 9 i2c_viapro,tuner_simple,tuner,tvaudio,msp3400,bttv,i2c_algo_bit,v4l2_common,tveeprom, Live 0xf0840000
> > shpchp 31056 0 - Live 0xf0823000
> > pci_hotplug 27812 1 shpchp, Live 0xf082f000
> > via_agp 8192 1 - Live 0xf0820000
> > evdev 9760 0 - Live 0xf081c000
> > 7.4 
> > 0000-001f : dma1
> > 0020-0021 : pic1
> > 0040-0043 : timer0
> > 0050-0053 : timer1
> > 0060-0060 : keyboard
> > 0064-0064 : keyboard
> > 0070-0077 : rtc
> > 0080-008f : dma page reg
> > 00a0-00a1 : pic2
> > 00c0-00df : dma2
> > 00f0-00ff : fpu
> > 0170-0177 : 0000:00:11.1
> >   0170-0177 : VP_IDE
> > 01f0-01f7 : 0000:00:11.1
> >   01f0-01f7 : VP_IDE
> > 0376-0376 : 0000:00:11.1
> >   0376-0376 : VP_IDE
> > 03c0-03df : vga+
> > 03f2-03f5 : floppy
> > 03f6-03f6 : 0000:00:11.1
> >   03f6-03f6 : VP_IDE
> > 03f7-03f7 : floppy DIR
> > 03f8-03ff : serial
> > 0400-040f : 0000:00:11.0
> >   0400-0407 : vt596_smbus
> > 0800-087f : 0000:00:11.0
> >   0800-0803 : ACPI PM1a_EVT_BLK
> >   0804-0805 : ACPI PM1a_CNT_BLK
> >   0808-080b : ACPI PM_TMR
> >   0810-0815 : ACPI CPU throttle
> >   0820-0823 : ACPI GPE0_BLK
> > 0cf8-0cff : PCI conf1
> > dc00-dcff : 0000:00:12.0
> >   dc00-dcff : via-rhine
> > e000-e0ff : 0000:00:11.5
> >   e000-e0ff : VIA8233
> > e400-e41f : 0000:00:10.0
> >   e400-e41f : uhci_hcd
> > e800-e81f : 0000:00:10.1
> >   e800-e81f : uhci_hcd
> > ec00-ec1f : 0000:00:10.2
> >   ec00-ec1f : uhci_hcd
> > fc00-fc0f : 0000:00:11.1
> >   fc00-fc0f : VP_IDE
> > -------------------------------
> > 00000000-0009fbff : System RAM
> > 0009fc00-0009ffff : reserved
> > 000a0000-000bffff : Video RAM area
> > 000c0000-000cf7ff : Video ROM
> > 000d4000-000d9fff : reserved
> > 000f0000-000fffff : System ROM
> > 00100000-2ffeffff : System RAM
> >   00100000-00494ed6 : Kernel code
> >   00494ed7-0061f797 : Kernel data
> >   0067a000-008c5f57 : Kernel bss
> > 2fff0000-2fff7fff : ACPI Tables
> > 2fff8000-2fffffff : ACPI Non-volatile Storage
> > cdc00000-ddcfffff : PCI Bus 0000:01
> >   d0000000-d7ffffff : 0000:01:00.0
> > dddfe000-dddfefff : 0000:00:09.0
> >   dddfe000-dddfefff : bttv0
> > dddff000-dddfffff : 0000:00:09.1
> >   dddff000-dddfffff : Bt87x audio
> > dde00000-dfefffff : PCI Bus 0000:01
> >   de000000-deffffff : 0000:01:00.0
> >   dfee0000-dfefffff : 0000:01:00.0
> > dffffe00-dffffeff : 0000:00:12.0
> >   dffffe00-dffffeff : via-rhine
> > dfffff00-dfffffff : 0000:00:10.3
> >   dfffff00-dfffffff : ehci_hcd
> > e0000000-e3ffffff : 0000:00:00.0
> > fec00000-fec00fff : reserved
> > fee00000-fee00fff : reserved
> > fff80000-ffffffff : reserved
> > 7.5 lspci -vvv
> > 00:00.0 Host bridge: VIA Technologies, Inc. P4M266 Host Bridge
> >         Subsystem: VIA Technologies, Inc. Unknown device 0000
> >         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> >         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
> >         Latency: 8
> >         Region 0: Memory at e0000000 (32-bit, prefetchable) [size=64M]
> >         Capabilities: [a0] AGP version 2.0
> >                 Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- HTrans- 64bit- FW- AGP3- Rate=x1,x2,x4
> >                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW- Rate=<none>
> >         Capabilities: [c0] Power Management version 2
> >                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:01.0 PCI bridge: VIA Technologies, Inc. VT8633 [Apollo Pro266 AGP] (prog-if 00 [Normal decode])
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
> >         Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
> >         Latency: 0
> >         Bus: primary=00, secondary=01, subordinate=01, sec-latency=0
> >         I/O behind bridge: 0000f000-00000fff
> >         Memory behind bridge: dde00000-dfefffff
> >         Prefetchable memory behind bridge: cdc00000-ddcfffff
> >         Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> >         BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-
> >         Capabilities: [80] Power Management version 2
> >                 Flags: PMEClk- DSI- D1+ D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:09.0 Multimedia video controller: Brooktree Corporation Bt878 Video Capture (rev 02)
> >         Subsystem: Hauppauge computer works Inc. WinTV Series
> >         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
> >         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 32 (4000ns min, 10000ns max)
> >         Interrupt: pin A routed to IRQ 10
> >         Region 0: Memory at dddfe000 (32-bit, prefetchable) [size=4K]
> > 
> > 00:09.1 Multimedia controller: Brooktree Corporation Bt878 Audio Capture (rev 02)
> >         Subsystem: Hauppauge computer works Inc. WinTV Series
> >         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
> >         Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 32 (1000ns min, 63750ns max)
> >         Interrupt: pin A routed to IRQ 10
> >         Region 0: Memory at dddff000 (32-bit, prefetchable) [size=4K]
> > 
> > 00:10.0 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 80) (prog-if 00 [UHCI])
> >         Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
> >         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 32, Cache Line Size: 32 bytes
> >         Interrupt: pin A routed to IRQ 11
> >         Region 4: I/O ports at e400 [size=32]
> >         Capabilities: [80] Power Management version 2
> >                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:10.1 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 80) (prog-if 00 [UHCI])
> >         Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
> >         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 32, Cache Line Size: 32 bytes
> >         Interrupt: pin B routed to IRQ 10
> >         Region 4: I/O ports at e800 [size=32]
> >         Capabilities: [80] Power Management version 2
> >                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:10.2 USB Controller: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller (rev 80) (prog-if 00 [UHCI])
> >         Subsystem: VIA Technologies, Inc. VT82xxxxx UHCI USB 1.1 Controller
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
> >         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 32, Cache Line Size: 32 bytes
> >         Interrupt: pin C routed to IRQ 5
> >         Region 4: I/O ports at ec00 [size=32]
> >         Capabilities: [80] Power Management version 2
> >                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:10.3 USB Controller: VIA Technologies, Inc. USB 2.0 (rev 82) (prog-if 20 [EHCI])
> >         Subsystem: VIA Technologies, Inc. USB 2.0
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
> >         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 32, Cache Line Size: 128 bytes
> >         Interrupt: pin D routed to IRQ 12
> >         Region 0: Memory at dfffff00 (32-bit, non-prefetchable) [size=256]
> >         Capabilities: [80] Power Management version 2
> >                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:11.0 ISA bridge: VIA Technologies, Inc. VT8235 ISA Bridge
> >         Subsystem: VIA Technologies, Inc. Unknown device 0000
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
> >         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 0
> >         Capabilities: [c0] Power Management version 2
> >                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:11.1 IDE interface: VIA Technologies, Inc. VT82C586A/B/VT82C686/A/B/VT823x/A/C PIPC Bus Master IDE (rev 06) (prog-if 8a [Master SecP PriP])
> >         Subsystem: VIA Technologies, Inc. VT82C586/B/VT82C686/A/B/VT8233/A/C/VT8235 PIPC Bus Master IDE
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> >         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 32
> >         Interrupt: pin A routed to IRQ 255
> >         Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable) [size=8]
> >         Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable) [size=1]
> >         Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable) [size=8]
> >         Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable) [size=1]
> >         Region 4: I/O ports at fc00 [size=16]
> >         Capabilities: [c0] Power Management version 2
> >                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:11.5 Multimedia audio controller: VIA Technologies, Inc. VT8233/A/8235/8237 AC97 Audio Controller (rev 50)
> >         Subsystem: VIA Technologies, Inc. K7VT2 motherboard
> >         Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> >         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Interrupt: pin C routed to IRQ 5
> >         Region 0: I/O ports at e000 [size=256]
> >         Capabilities: [c0] Power Management version 2
> >                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (rev 74)
> >         Subsystem: VIA Technologies, Inc. VT6102 [Rhine II] Embeded Ethernet Controller on VT8235
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
> >         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 32 (750ns min, 2000ns max), Cache Line Size: 32 bytes
> >         Interrupt: pin A routed to IRQ 11
> >         Region 0: I/O ports at dc00 [size=256]
> >         Region 1: Memory at dffffe00 (32-bit, non-prefetchable) [size=256]
> >         Capabilities: [40] Power Management version 2
> >                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 01:00.0 VGA compatible controller: nVidia Corporation NV34 [GeForce FX 5200] (rev a1) (prog-if 00 [VGA])
> >         Subsystem: ASUSTeK Computer Inc. Unknown device 8180
> >         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> >         Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> >         Latency: 32 (1250ns min, 250ns max)
> >         Interrupt: pin A routed to IRQ 11
> >         Region 0: Memory at de000000 (32-bit, non-prefetchable) [size=16M]
> >         Region 1: Memory at d0000000 (32-bit, prefetchable) [size=128M]
> >         Expansion ROM at dfee0000 [disabled] [size=128K]
> >         Capabilities: [60] Power Management version 2
> >                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> >                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> >         Capabilities: [44] AGP version 3.0
> >                 Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA+ ITACoh- GART64- HTrans- 64bit- FW+ AGP3- Rate=x1,x2,x4
> >                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit- FW- Rate=<none>
> > 7.6 Nothing
> > 7.7 nothing
> >  
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
