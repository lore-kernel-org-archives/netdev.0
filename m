From: Andre Tomt <andre@tomt.net>
Subject: sundance buckles under load
Date: Thu, 23 Sep 2004 18:56:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41530028.6040600@tomt.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have one of those cheap ass so far mostly unusable D-Link 4port 
sundance based NIC's laying around collecting dust. So far its been a 
troublesome card to use, it worked OK for a while in 2.4, but at least 
in recent 2.6 it's rather unstable. I know this is a piece of junk, but 
it would be cool to have it working anyway ;-)

Even a simple iperf test tips it over into triggering the netdev 
watchdog, often within seconds, or if we're lucky - a few minutes. 
Usually the reset gets it back online again - for a short period of 
time, untill netdev watchdog trigger again.

running iperf -s on the pc with sundance, and iperf -c <ip> -d 
(bi-directional test) on a client, triggers it reliably.

The machine is running with ACPI disabled (automaticly at boot, as BIOS 
is from 2000 or earlier.) Other than that, the kernel has vectorized 
interrupts enabled, but it doesn't seem to be used in this case.

kernel version is equalent of 2.6.8.1, CONFIG_SUNDANCE_MMIO is off.

from the kernel log:
> Sep 18 09:16:46 localhost kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Sep 18 09:16:46 localhost kernel: eth0: Transmit timed out, TxStatus 00 TxFrameId 17, resetting...
> Sep 18 09:16:46 localhost kernel: 00 0f45e000 0f45e010 00008001(00) 0f2d308e 800005ea
> Sep 18 09:16:46 localhost kernel: 01 0f45e010 0f45e020 00000005(01) 0474488e 800005ea
> Sep 18 09:16:46 localhost kernel: 02 0f45e020 0f45e030 00000009(02) 0bffd88e 800005ea
> Sep 18 09:16:46 localhost kernel: 03 0f45e030 0f45e040 0000000d(03) 041f108e 800005ea
> Sep 18 09:16:46 localhost kernel: 04 0f45e040 0f45e050 00000011(04) 0efb008e 800005ea
> Sep 18 09:16:46 localhost kernel: 05 0f45e050 0f45e060 00000015(05) 0d87708e 800005ea
> Sep 18 09:16:46 localhost kernel: 06 0f45e060 0f45e070 00000019(06) 029e608e 800005ea
> Sep 18 09:16:46 localhost kernel: 07 0f45e070 0f45e080 0000001d(07) 0dd3208e 800005ea
> Sep 18 09:16:46 localhost kernel: 08 0f45e080 0f45e090 00000021(08) 0c07188e 800005ea
> Sep 18 09:16:46 localhost kernel: 09 0f45e090 0f45e0a0 00000025(09) 0b91008e 800005ea
> Sep 18 09:16:46 localhost kernel: 0a 0f45e0a0 0f45e0b0 00000029(0a) 0c77d88e 800005ea
> Sep 18 09:16:46 localhost kernel: 0b 0f45e0b0 0f45e0c0 0000002d(0b) 0b99908e 800005ea
> Sep 18 09:16:46 localhost kernel: 0c 0f45e0c0 0f45e0d0 00000031(0c) 0d85688e 800005ea
> Sep 18 09:16:46 localhost kernel: 0d 0f45e0d0 0f45e0e0 00000035(0d) 0fb2708e 800005ea
> Sep 18 09:16:46 localhost kernel: 0e 0f45e0e0 0f45e0f0 00000039(0e) 04b7e08e 800005ea
> Sep 18 09:16:46 localhost kernel: 0f 0f45e0f0 0f45e100 0000003d(0f) 04b3908e 800005ea
> Sep 18 09:16:46 localhost kernel: 10 0f45e100 0f45e110 00000041(10) 0b9ac08e 800005ea
> Sep 18 09:16:46 localhost kernel: 11 0f45e110 0f45e120 00000045(11) 0b9ac88e 800005ea
> Sep 18 09:16:46 localhost kernel: 12 0f45e120 0f45e130 00000049(12) 04ad808e 800005ea
> Sep 18 09:16:46 localhost kernel: 13 0f45e130 00000000 0000804d(13) 04ad888e 800005ea
> Sep 18 09:16:46 localhost kernel: 14 0f45e140 0f45e150 00018051(14) 00000000 00000000
> Sep 18 09:16:46 localhost kernel: 15 0f45e150 0f45e160 00010055(15) 00000000 00000000
> Sep 18 09:16:46 localhost kernel: 16 0f45e160 0f45e170 00010059(16) 00000000 00000000
> Sep 18 09:16:46 localhost kernel: 17 0f45e170 0f45e180 0001005d(17) 00000000 00000000
> Sep 18 09:16:46 localhost kernel: 18 0f45e180 0f45e190 00008061(18) 0dc2a88e 800005ea
> Sep 18 09:16:46 localhost kernel: 19 0f45e190 0f45e1a0 00000065(19) 0d33488e 800005ea
> Sep 18 09:16:46 localhost kernel: 1a 0f45e1a0 0f45e1b0 00000069(1a) 0f7d108e 800005ea
> Sep 18 09:16:46 localhost kernel: 1b 0f45e1b0 0f45e1c0 0000006d(1b) 0415508e 800005ea
> Sep 18 09:16:46 localhost kernel: 1c 0f45e1c0 0f45e1d0 00008071(1c) 0b9a188e 800005ea
> Sep 18 09:16:46 localhost kernel: 1d 0f45e1d0 0f45e1e0 00000075(1d) 0f73588e 800005ea
> Sep 18 09:16:46 localhost kernel: 1e 0f45e1e0 0f45e1f0 00000079(1e) 0e12b88e 800005ea
> Sep 18 09:16:46 localhost kernel: 1f 0f45e1f0 0f45e000 0000007d(1f) 042c788e 800005ea
> Sep 18 09:16:46 localhost kernel: TxListPtr=0f45e180 netif_queue_stopped=1
> Sep 18 09:16:46 localhost kernel: cur_tx=9449428(14) dirty_tx=9449400(18)
> Sep 18 09:16:46 localhost kernel: cur_rx=33 dirty_rx=33
> Sep 18 09:16:46 localhost kernel: cur_task=9449428
> Sep 18 09:16:54 localhost kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Sep 18 09:16:54 localhost kernel: eth0: Transmit timed out, TxStatus 00 TxFrameId 00, resetting...
> Sep 18 09:16:54 localhost kernel: 00 0f45e000 0f45e010 00010001(00) 00000000 00000000
> Sep 18 09:16:54 localhost kernel: 01 0f45e010 0f45e020 00000005(01) 0d87308e 800005ea
> Sep 18 09:16:54 localhost kernel: 02 0f45e020 0f45e030 00000009(02) 0c77b08e 800005ea
> Sep 18 09:16:54 localhost kernel: 03 0f45e030 0f45e040 0000000d(03) 0f95808e 800005ea
> Sep 18 09:16:54 localhost kernel: 04 0f45e040 0f45e050 00000011(04) 0f8e828e 80000042
> Sep 18 09:16:54 localhost kernel: 05 0f45e050 0f45e060 00000015(05) 0f8e848e 80000042
> Sep 18 09:16:54 localhost kernel: 06 0f45e060 0f45e070 00000019(06) 0d61188e 800005ea
> Sep 18 09:16:54 localhost kernel: 07 0f45e070 0f45e080 0000001d(07) 0b99708e 800005ea
> Sep 18 09:16:54 localhost kernel: 08 0f45e080 0f45e090 00000021(08) 04b3988e 800005ea
> Sep 18 09:16:54 localhost kernel: 09 0f45e090 0f45e0a0 00000025(09) 0faad08e 800005ea
> Sep 18 09:16:54 localhost kernel: 0a 0f45e0a0 0f45e0b0 00000029(0a) 0edb788e 800005ea
> Sep 18 09:16:54 localhost kernel: 0b 0f45e0b0 0f45e0c0 0000002d(0b) 0d08b88e 800005ea
> Sep 18 09:16:54 localhost kernel: 0c 0f45e0c0 0f45e0d0 00000031(0c) 0bffd08e 800005ea
> Sep 18 09:16:54 localhost kernel: 0d 0f45e0d0 0f45e0e0 00000035(0d) 0b9a108e 800005ea
> Sep 18 09:16:54 localhost kernel: 0e 0f45e0e0 0f45e0f0 00000039(0e) 0f62a88e 800005ea
> Sep 18 09:16:54 localhost kernel: 0f 0f45e0f0 0f45e100 0000003d(0f) 0f7d188e 800005ea
> Sep 18 09:16:54 localhost kernel: 10 0f45e100 0f45e110 00000041(10) 0d84288e 800005ea
> Sep 18 09:16:54 localhost kernel: 11 0f45e110 0f45e120 00000045(11) 0dd3288e 800005ea
> Sep 18 09:16:54 localhost kernel: 12 0f45e120 0f45e130 00000049(12) 0ed1808e 800005ea
> Sep 18 09:16:54 localhost kernel: 13 0f45e130 0f45e140 0000004d(13) 0427188e 800005ea
> Sep 18 09:16:54 localhost kernel: 14 0f45e140 0f45e150 00000051(14) 0c30808e 800005ea
> Sep 18 09:16:54 localhost kernel: 15 0f45e150 0f45e160 00000055(15) 0427108e 800005ea
> Sep 18 09:16:54 localhost kernel: 16 0f45e160 0f45e170 00000059(16) 0137208e 800005ea
> Sep 18 09:16:54 localhost kernel: 17 0f45e170 0f45e180 0000005d(17) 0d5d608e 800005ea
> Sep 18 09:16:54 localhost kernel: 18 0f45e180 0f45e190 00000061(18) 04b7e88e 800005ea
> Sep 18 09:16:54 localhost kernel: 19 0f45e190 0f45e1a0 00000065(19) 0b9af88e 800005ea
> Sep 18 09:16:54 localhost kernel: 1a 0f45e1a0 0f45e1b0 00000069(1a) 0ba9708e 800005ea
> Sep 18 09:16:54 localhost kernel: 1b 0f45e1b0 0f45e1c0 0000006d(1b) 04adb88e 800005ea
> Sep 18 09:16:54 localhost kernel: 1c 0f45e1c0 0f45e1d0 00000071(1c) 0474688e 800005ea
> Sep 18 09:16:54 localhost kernel: 1d 0f45e1d0 00000000 00008075(1d) 0f73f08e 800005ea
> Sep 18 09:16:54 localhost kernel: 1e 0f45e1e0 0f45e1f0 00000079(1e) 0e12b88e 800005ea
> Sep 18 09:16:54 localhost kernel: 1f 0f45e1f0 0f45e000 0000007d(1f) 042c788e 800005ea
> Sep 18 09:16:54 localhost kernel: TxListPtr=0f45e010 netif_queue_stopped=1
> Sep 18 09:16:54 localhost kernel: cur_tx=30(1e) dirty_tx=1(01)
> Sep 18 09:16:54 localhost kernel: cur_rx=35 dirty_rx=35
> Sep 18 09:16:54 localhost kernel: cur_task=30
> Sep 18 09:17:46 localhost kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Sep 18 09:17:46 localhost kernel: eth0: Transmit timed out, TxStatus 00 TxFrameId 00, resetting...
> Sep 18 09:17:46 localhost kernel: 00 0f45e000 0f45e010 00008001(00) 0423388e 800005ea
> Sep 18 09:17:46 localhost kernel: 01 0f45e010 0f45e020 00008005(01) 0f866c82 8000004e
> Sep 18 09:17:46 localhost kernel: 02 0f45e020 0f45e030 00008009(02) 0a17a88e 800005ea
> Sep 18 09:17:46 localhost kernel: 03 0f45e030 0f45e040 0000800d(03) 0f866402 8000002a
> Sep 18 09:17:46 localhost kernel: 04 0f45e040 00000000 00008011(04) 0f866602 8000002a
> Sep 18 09:17:46 localhost kernel: 05 0f45e050 0f45e060 00010015(05) 00000000 00000000
> Sep 18 09:17:46 localhost kernel: 06 0f45e060 0f45e070 00010019(06) 00000000 00000000
> Sep 18 09:17:46 localhost kernel: 07 0f45e070 0f45e080 0000001d(07) 0f8eb28e 80000042
> Sep 18 09:17:46 localhost kernel: 08 0f45e080 0f45e090 00000021(08) 0f8eba8e 80000042
> Sep 18 09:17:46 localhost kernel: 09 0f45e090 0f45e0a0 00000025(09) 0f8eb88e 80000042
> Sep 18 09:17:46 localhost kernel: 0a 0f45e0a0 0f45e0b0 00000029(0a) 0f8ebe8e 80000042
> Sep 18 09:17:46 localhost kernel: 0b 0f45e0b0 0f45e0c0 0000002d(0b) 0fc1968e 80000042
> Sep 18 09:17:46 localhost kernel: 0c 0f45e0c0 0f45e0d0 00000031(0c) 0f8e8e8e 80000042
> Sep 18 09:17:46 localhost kernel: 0d 0f45e0d0 0f45e0e0 00000035(0d) 0f8eb48e 80000042
> Sep 18 09:17:46 localhost kernel: 0e 0f45e0e0 0f45e0f0 00000039(0e) 0fc19e8e 80000042
> Sep 18 09:17:46 localhost kernel: 0f 0f45e0f0 0f45e100 0000003d(0f) 0fc19a8e 80000042
> Sep 18 09:17:46 localhost kernel: 10 0f45e100 0f45e110 00000041(10) 0f8e8a8e 80000042
> Sep 18 09:17:46 localhost kernel: 11 0f45e110 0f45e120 00000045(11) 0fc1988e 80000042
> Sep 18 09:17:46 localhost kernel: 12 0f45e120 0f45e130 00000049(12) 0f8e868e 80000042
> Sep 18 09:17:46 localhost kernel: 13 0f45e130 0f45e140 0000004d(13) 0fe04482 8000004e
> Sep 18 09:17:46 localhost kernel: 14 0f45e140 0f45e150 00000051(14) 0c30888e 800005ea
> Sep 18 09:17:46 localhost kernel: 15 0f45e150 0f45e160 00000055(15) 0fe04c82 8000004e
> Sep 18 09:17:46 localhost kernel: 16 0f45e160 0f45e170 00000059(16) 0474608e 800005ea
> Sep 18 09:17:46 localhost kernel: 17 0f45e170 0f45e180 0000005d(17) 0fe04a82 8000004e
> Sep 18 09:17:46 localhost kernel: 18 0f45e180 0f45e190 00000061(18) 0edb708e 800005ea
> Sep 18 09:17:46 localhost kernel: 19 0f45e190 0f45e1a0 00000065(19) 0fe04282 8000004e
> Sep 18 09:17:46 localhost kernel: 1a 0f45e1a0 0f45e1b0 00000069(1a) 0497708e 800005ea
> Sep 18 09:17:46 localhost kernel: 1b 0f45e1b0 0f45e1c0 0000006d(1b) 0fc0c682 8000004e
> Sep 18 09:17:46 localhost kernel: 1c 0f45e1c0 0f45e1d0 00000071(1c) 042c708e 800005ea
> Sep 18 09:17:46 localhost kernel: 1d 0f45e1d0 0f45e1e0 00008075(1d) 0f8eb682 8000004e
> Sep 18 09:17:46 localhost kernel: 1e 0f45e1e0 0f45e1f0 00008079(1e) 0ba3508e 800005ea
> Sep 18 09:17:46 localhost kernel: 1f 0f45e1f0 0f45e000 0000807d(1f) 0f8e4482 8000004e
> Sep 18 09:17:46 localhost kernel: TxListPtr=0f45e070 netif_queue_stopped=1
> Sep 18 09:17:46 localhost kernel: cur_tx=37(05) dirty_tx=7(07)
> Sep 18 09:17:46 localhost kernel: cur_rx=37 dirty_rx=37
> Sep 18 09:17:46 localhost kernel: cur_task=37
> Sep 18 09:21:42 localhost kernel: NETDEV WATCHDOG: eth0: transmit timed out
> Sep 18 09:21:42 localhost kernel: eth0: Transmit timed out, TxStatus 00 TxFrameId 00, resetting...
> Sep 18 09:21:42 localhost kernel: 00 0f45e000 0f45e010 00008001(00) 0fcfd202 8000002a
> Sep 18 09:21:42 localhost kernel: 01 0f45e010 0f45e020 00008005(01) 0fcfda02 8000002a
> Sep 18 09:21:42 localhost kernel: 02 0f45e020 0f45e030 00008009(02) 0fcfe202 8000002a
> Sep 18 09:21:42 localhost kernel: 03 0f45e030 0f45e040 0000800d(03) 0fcfea02 8000002a
> Sep 18 09:21:42 localhost kernel: 04 0f45e040 0f45e050 00008011(04) 0fcfe802 8000002a
> Sep 18 09:21:42 localhost kernel: 05 0f45e050 0f45e060 00008015(05) 0fcfe402 8000002a
> Sep 18 09:21:42 localhost kernel: 06 0f45e060 0f45e070 00008019(06) 0fcfec02 8000002a
> Sep 18 09:21:42 localhost kernel: 07 0f45e070 00000000 0000801d(07) 0fcfe602 8000002a
> Sep 18 09:21:42 localhost kernel: 08 0f45e080 0f45e090 00018021(08) 00000000 00000000
> Sep 18 09:21:42 localhost kernel: 09 0f45e090 0f45e0a0 00018025(09) 00000000 00000000
> Sep 18 09:21:42 localhost kernel: 0a 0f45e0a0 0f45e0b0 00008029(0a) 0f8ec802 8000002a
> Sep 18 09:21:42 localhost kernel: 0b 0f45e0b0 0f45e0c0 0000802d(0b) 0f867802 8000002a
> Sep 18 09:21:42 localhost kernel: 0c 0f45e0c0 0f45e0d0 00008031(0c) 0f867a02 8000002a
> Sep 18 09:21:42 localhost kernel: 0d 0f45e0d0 0f45e0e0 00008035(0d) 0fcf5602 8000002a
> Sep 18 09:21:42 localhost kernel: 0e 0f45e0e0 0f45e0f0 00008039(0e) 0fcf5c02 8000002a
> Sep 18 09:21:42 localhost kernel: 0f 0f45e0f0 0f45e100 0000803d(0f) 0fcf5202 8000002a
> Sep 18 09:21:42 localhost kernel: 10 0f45e100 0f45e110 00008041(10) 0fcf5e02 8000002a
> Sep 18 09:21:42 localhost kernel: 11 0f45e110 0f45e120 00008045(11) 0fcf5802 8000002a
> Sep 18 09:21:42 localhost kernel: 12 0f45e120 0f45e130 00008049(12) 0fcf5402 8000002a
> Sep 18 09:21:42 localhost kernel: 13 0f45e130 0f45e140 0000804d(13) 0fcf5a02 8000002a
> Sep 18 09:21:42 localhost kernel: 14 0f45e140 0f45e150 00008051(14) 0f885c02 8000002a
> Sep 18 09:21:42 localhost kernel: 15 0f45e150 0f45e160 00008055(15) 0f885a02 8000002a
> Sep 18 09:21:42 localhost kernel: 16 0f45e160 0f45e170 00008059(16) 0f885602 8000002a
> Sep 18 09:21:42 localhost kernel: 17 0f45e170 0f45e180 0000805d(17) 0f881a02 8000002a
> Sep 18 09:21:42 localhost kernel: 18 0f45e180 0f45e190 00008061(18) 0f881402 8000002a
> Sep 18 09:21:42 localhost kernel: 19 0f45e190 0f45e1a0 00008065(19) 0f881e02 8000002a
> Sep 18 09:21:42 localhost kernel: 1a 0f45e1a0 0f45e1b0 00008069(1a) 0f881602 8000002a
> Sep 18 09:21:42 localhost kernel: 1b 0f45e1b0 0f45e1c0 0000806d(1b) 0fcfc202 8000002a
> Sep 18 09:21:42 localhost kernel: 1c 0f45e1c0 0f45e1d0 00008071(1c) 0fcfd802 8000002a
> Sep 18 09:21:42 localhost kernel: 1d 0f45e1d0 0f45e1e0 00008075(1d) 0fcfde02 8000002a
> Sep 18 09:21:42 localhost kernel: 1e 0f45e1e0 0f45e1f0 00008079(1e) 0fcfdc02 8000002a
> Sep 18 09:21:42 localhost kernel: 1f 0f45e1f0 0f45e000 0000807d(1f) 0fcfd402 8000002a
> Sep 18 09:21:42 localhost kernel: TxListPtr=0f45e0a0 netif_queue_stopped=1
> Sep 18 09:21:42 localhost kernel: cur_tx=40(08) dirty_tx=10(0a)
> Sep 18 09:21:42 localhost kernel: cur_rx=14 dirty_rx=14
> Sep 18 09:21:42 localhost kernel: cur_task=40

from lspci (note, the pci-bridge is on the card):
> 0000:00:0f.0 PCI bridge: Intel Corp. 21152 PCI-to-PCI Bridge (prog-if 00 [Normal decode])
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64, Cache Line Size: 0x08 (32 bytes)
>         Bus: primary=00, secondary=02, subordinate=02, sec-latency=64
>         I/O behind bridge: 00009000-0000bfff
>         Memory behind bridge: efe00000-efefffff
>         Prefetchable memory behind bridge: 00000000e9b00000-00000000e9b00000
>         BridgeCtl: Parity+ SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>         Capabilities: [dc] Power Management version 2
>                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
>                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
>                 Bridge: PM- B3+
> 00: 86 80 52 b1 07 00 90 02 00 00 04 06 08 40 01 00
> 10: 00 00 00 00 00 00 00 00 00 02 02 40 91 b1 80 22
> 20: e0 ef e0 ef b1 e9 b1 e9 00 00 00 00 00 00 00 00
> 30: 00 00 00 00 dc 00 00 00 00 00 00 00 00 00 03 00
> 40: 00 00 00 02 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 3e 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 01 00 02 00
> e0: 00 00 c0 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 >
> 0000:02:04.0 Ethernet controller: D-Link System Inc DL10050 Sundance Ethernet (rev 12)
>         Subsystem: D-Link System Inc DFE-580TX
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (2500ns min, 2500ns max), Cache Line Size: 0x08 (32 bytes)
>         Interrupt: pin A routed to IRQ 10
>         Region 0: I/O ports at bc00 [size=128]
>         Expansion ROM at efef0000 [disabled] [size=64K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-
> 00: 86 11 02 10 17 00 10 02 12 00 00 02 08 40 00 00
> 10: 01 bc 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 11 12 10
> 30: 00 00 ef ef 50 00 00 00 00 00 00 00 0a 01 0a 0a
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 01 00 02 f6 00 40 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> 0000:02:05.0 Ethernet controller: D-Link System Inc DL10050 Sundance Ethernet (rev 12)
>         Subsystem: D-Link System Inc DFE-580TX
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (2500ns min, 2500ns max), Cache Line Size: 0x08 (32 bytes)
>         Interrupt: pin A routed to IRQ 12
>         Region 0: I/O ports at b800 [size=128]
>         Expansion ROM at efee0000 [disabled] [size=64K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-
> 00: 86 11 02 10 17 00 10 02 12 00 00 02 08 40 00 00
> 10: 01 b8 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 11 12 10
> 30: 00 00 ee ef 50 00 00 00 00 00 00 00 0c 01 0a 0a
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 01 00 02 f6 00 40 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 >
> 0000:02:06.0 Ethernet controller: D-Link System Inc DL10050 Sundance Ethernet (rev 12)
>         Subsystem: D-Link System Inc DFE-580TX
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (2500ns min, 2500ns max), Cache Line Size: 0x08 (32 bytes)
>         Interrupt: pin A routed to IRQ 11
>         Region 0: I/O ports at b400 [size=128]
>         Expansion ROM at efed0000 [disabled] [size=64K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-
> 00: 86 11 02 10 17 00 10 02 12 00 00 02 08 40 00 00
> 10: 01 b4 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 11 12 10
> 30: 00 00 ed ef 50 00 00 00 00 00 00 00 0b 01 0a 0a
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 01 00 02 f6 00 40 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 
> 0000:02:07.0 Ethernet controller: D-Link System Inc DL10050 Sundance Ethernet (rev 12)
>         Subsystem: D-Link System Inc DFE-580TX
>         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
>         Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
>         Latency: 64 (2500ns min, 2500ns max), Cache Line Size: 0x08 (32 bytes)
>         Interrupt: pin A routed to IRQ 9
>         Region 0: I/O ports at b000 [size=128]
>         Expansion ROM at efec0000 [disabled] [size=64K]
>         Capabilities: [50] Power Management version 2
>                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1+,D2+,D3hot+,D3cold+)
>                 Status: D0 PME-Enable- DSel=0 DScale=2 PME-
> 00: 86 11 02 10 17 00 10 02 12 00 00 02 08 40 00 00
> 10: 01 b0 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 20: 00 00 00 00 00 00 00 00 00 00 00 00 86 11 12 10
> 30: 00 00 ec ef 50 00 00 00 00 00 00 00 09 01 0a 0a
> 40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 50: 01 00 02 f6 00 40 00 00 00 00 00 00 00 00 00 00
> 60: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 70: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> 90: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> c0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> d0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> e0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
