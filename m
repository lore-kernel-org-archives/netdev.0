From: "Christoph Gysin" <christoph.gysin@fr33z3.org>
Subject: 8139too in >=2.6.26: SIOCSIFFLAGS: Device or resource busy
Date: Wed, 10 Dec 2008 11:51:29 +0100
Message-ID: <6f67b0190812100251u511d0aect4d082541977335d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.28]:25764 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735AbYLJKvb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 05:51:31 -0500
Received: by yx-out-2324.google.com with SMTP id 8so206603yxm.1
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 02:51:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have problems getting a RTL-8100C(L) network chip working under
recent kernels. I was using 2.4 kernels for a long time without any
problems. With 2.6 I experience weird behaviour:

linux-2.4
The device works, ~10MByte/s Rx/Tx

<=linux-2.6.25
The device works, although with weak performance. Rx:8MByte/s Tx:1.4MByte/s

>=linux-2.6.26
The device is recognized, but fails while doing "ifconfig eth0 up" with:
eth0: SIOCSIFFLAGS: Device or resource busy

I tried various combination of the following options, no difference:
CONFIG_8139TOO_PIO
CONFIG_8139TOO_TUNE_TWISTER
CONFIG_8139TOO_8129
CONFIG_8139_OLD_RX_RESET

I compiled 8139too with RTL8139_DEBUG 3 and ran rtl8139-diag
-mmmaaavvveef as mentioned in the driver source (output below). Now
I'm a little bit lost, I don't know how to dig deeper into this
problem. I'd really like  to move all my old systems to recent
kernels. I'd be thankful for any hints on how to continue debugging
this issue.

TIA,
Chris

$ modprobe 8139too use_io=1 debug=1
$ dmesg
8139too Fast Ethernet driver 0.9.28
eth0: RealTek RTL8139 at 0xcf0580e4, 00:03:2d:0e:8e:75, IRQ 64767     <-- !?
eth0:  Identified 8139 chip type 'RTL-8100B/8139D'

$ ./rtl8139-diag -mmmaaavvveef
rtl8139-diag.c:v2.13 2/28/2005 Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
Index #1: Found a RealTek RTL8139 adapter at 0xfc00.
RealTek chip registers at 0xfc00
 0x000: 0e2d0300 0000758e 80000000 00000000 00002000 00002000 00002000 00002000
 0x020: 0e3dc000 0e3dc600 0e3dcc00 0e3dd200 0e3e0000 01000000 0000fff0 00000000
 0x040: 74400000 00000000 bedb9e0d 00000000 008d1000 00000000 0088c510 00100000
 0x060: 1100000f 01e1782d 000145e1 00000000 00000704 000207c8 60f60c59 7b732660.
Realtek station address 00:03:2d:0e:8e:75, chip type 'rtl8139C'.
  Receiver configuration: Reception disabled
     Rx FIFO threshold 16 bytes, maximum burst 16 bytes, 8KB ring
  Transmitter disabled with normal settings, maximum burst 16 bytes.
    Tx entry #0 status 00002000 incomplete, 0 bytes.
    Tx entry #1 status 00002000 incomplete, 0 bytes.
    Tx entry #2 status 00002000 incomplete, 0 bytes.
    Tx entry #3 status 00002000 incomplete, 0 bytes.
  Flow control: Tx disabled  Rx disabled.
  The chip configuration is 0x10 0x8d, MII half-duplex mode.
  No interrupt sources are pending.
Decoded EEPROM contents:
   PCI IDs -- Vendor 0x10ec, Device 0x8139.
   PCI Subsystem IDs -- Vendor 0x10ec, Device 0x8139.
   PCI timer settings -- minimum grant 32, maximum latency 64.
  General purpose pins --  direction 0xe5  value 0x12.
  Station Address 00:03:2D:0E:8E:75.
  Configuration register 0/1 -- 0x8d / 0xc2.
 EEPROM active region checksum is 0904.
EEPROM contents (64 words):
 0x00:  8129 10ec 8139 10ec 8139 4020 e512 0300
 0x08:  0e2d 758e 8d10 f7c2 8801 43b9 b0f2 071a
 0x10:  df43 8a36 df43 8a36 43b9 b0f2 1111 1111
 0x18:  0000 0000 0000 0000 0000 0000 0000 3000
 0x20:  0000 0000 0000 0000 0000 0000 0000 0000
      ...
 The RTL8139 does not use a MII transceiver.
 It does have internal MII-compatible registers:
   Basic mode control register   0x1100.
   Basic mode status register    0x782d.
   Autonegotiation Advertisement 0x01e1.
   Link Partner Ability register 0x45e1.
   Autonegotiation expansion     0x0001.
   Disconnects                   0x0000.
   False carrier sense counter   0x0000.
   NWay test register            0x0704.
   Receive frame error count     0x0000.
libmii.c:v2.11 2/28/2005  Donald Becker (becker@scyld.com)
 http://www.scyld.com/diag/index.html
 MII PHY #32 transceiver registers:
   1100 782d 0000 0000 01e1 45e1 0001 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000.
 Basic mode control register 0x1100: Auto-negotiation enabled.
 Basic mode status register 0x782d ... 782d.
   Link status: established.
   Capable of  100baseTx-FD 100baseTx 10baseT-FD 10baseT.
   Able to perform Auto-negotiation, negotiation complete.
 This transceiver has no vendor identification.
 I'm advertising 01e1: 100baseTx-FD 100baseTx 10baseT-FD 10baseT
   Advertising no additional info pages.
   IEEE 802.3 CSMA/CD protocol.
 Link partner capability is 45e1: Flow-control 100baseTx-FD 100baseTx
10baseT-FD 10baseT.
   Negotiation  completed.



$ lspci -s 00:10.0 -vv
00:10.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
RTL-8139/8139C/8139C+ (rev 10)
       Subsystem: Realtek Semiconductor Co., Ltd. RT8139
       Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
Stepping- SERR- FastB2B- DisINTx-
       Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
<TAbort- <MAbort- >SERR- <PERR+ INTx-
       Latency: 32 (8000ns min, 16000ns max)
       Interrupt: pin A routed to IRQ 15
       Region 0: I/O ports at fc00 [size=256]
       Region 1: Memory at effff000 (32-bit, non-prefetchable) [size=256]
       Capabilities: [50] Power Management version 2
               Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
PME(D0-,D1+,D2+,D3hot+,D3cold+)
               Status: D0 PME-Enable- DSel=0 DScale=0 PME-
       Kernel driver in use: 8139too

$ ethtool -d eth0
RealTek RTL-8100B/8139D registers:
------------------------------
0x00: MAC Address                      00:03:2d:0e:8e:75
0x08: Multicast Address Filter     0x80000000 0x00000000
0x10: Transmit Status Desc 0                  0x0008a072
0x14: Transmit Status Desc 1                  0x0008a072
0x18: Transmit Status Desc 2                  0x0008a072
0x1C: Transmit Status Desc 3                  0x0008a072
0x20: Transmit Start Addr  0                  0x0e3b8000
0x24: Transmit Start Addr  1                  0x0e3b8600
0x28: Transmit Start Addr  2                  0x0e3b8c00
0x2C: Transmit Start Addr  3                  0x0e3b9200
0x30: Rx buffer addr (C mode)                 0x0e3d0000
0x34: Early Rx Byte Count                              0
0x36: Early Rx Status                               0x0a
     ERxGood ERxOverWrite
0x37: Command                                       0x0d
     Rx on, Tx on
0x38: Current Address of Packet Read (C mode)     0x40d8
0x3A: Current Rx buffer address (C mode)          0x40e8
0x3C: Interrupt Mask                              0xc07f
     SERR TimeOut RxFIFO LinkChg RxNoBuf TxErr TxOK RxErr RxOK
0x3E: Interrupt Status                            0x0000

0x40: Tx Configuration                        0x77400680
0x44: Rx Configuration                        0x0000f78e
0x48: Timer count                             0x0874473d
0x4C: Missed packet counter                     0x000000
0x50: EEPROM Command                                0x00
0x51: Config 0                                      0x10
0x52: Config 1                                      0x8d
0x54: Timer interrupt                         0x00000000
0x58: Media status                                  0x10
0x59: Config 3                                      0xc5
0x5A: Config 4                                      0x88
0x5C: Multiple Interrupt Select                   0x0000
0x5E: PCI revision id                               0x10
0x60: Transmit Status of All Desc (C mode)        0xf00f
0x62: MII Basic Mode Control Register             0x1100
0x64: MII Basic Mode Status Register              0x782d
0x66: MII Autonegotiation Advertising             0x01e1
0x68: MII Link Partner Ability                    0x45e1
0x6A: MII Expansion                               0x0001
0x6C: MII Disconnect counter                      0x0000
0x6E: MII False carrier sense counter             0x0000
0x70: MII Nway test                               0x0704
0x72: MII RX_ER counter                           0x0000
0x74: MII CS configuration                        0x07c0
0x78: PHY parameter 1                         0x60f60c59
0x7C: Twister parameter                       0x7b732660
0x80: PHY parameter 2                               0x1a
0x84: PM CRC for wakeup frame 0                     0x01
0x85: PM CRC for wakeup frame 1                     0x00
0x86: PM CRC for wakeup frame 2                     0x0a
0x87: PM CRC for wakeup frame 3                     0x80
0x88: PM CRC for wakeup frame 4                     0x00
0x89: PM CRC for wakeup frame 5                     0x00
0x8A: PM CRC for wakeup frame 6                     0x00
0x8B: PM CRC for wakeup frame 7                     0x00
0x8C: PM wakeup frame 0            0x00000020 0x01140040
0x94: PM wakeup frame 1            0x00000002 0x00800000
0x9C: PM wakeup frame 2            0x00000080 0x08024100
0xA4: PM wakeup frame 3            0x20000002 0x04000000
0xAC: PM wakeup frame 4            0x00000002 0x00000210
0xB4: PM wakeup frame 5            0x00008a10 0x09000100
0xBC: PM wakeup frame 6            0x00002000 0x00000010
0xC4: PM wakeup frame 7            0x84000300 0x00000000
0xCC: PM LSB CRC for wakeup frame 0                 0x00
0xCD: PM LSB CRC for wakeup frame 1                 0x01
0xCE: PM LSB CRC for wakeup frame 2                 0x00
0xCF: PM LSB CRC for wakeup frame 3                 0x81
0xD0: PM LSB CRC for wakeup frame 4                 0x08
0xD1: PM LSB CRC for wakeup frame 5                 0x00
0xD2: PM LSB CRC for wakeup frame 6                 0x00
0xD3: PM LSB CRC for wakeup frame 7                 0x00
0xD8: Config 5                                      0x07


throughput on 2.6.25:

$ netio -t 10.0.0.12
TCP connection established.
Packet size  1k bytes:  11520 KByte/s Tx,  11458 KByte/s Rx.
Packet size  2k bytes:  11518 KByte/s Tx,  4686 KByte/s Rx.
Packet size  4k bytes:  6428 KByte/s Tx,  1383 KByte/s Rx.
Packet size  8k bytes:  6194 KByte/s Tx,  1393 KByte/s Rx.
Packet size 16k bytes:  4370 KByte/s Tx,  1392 KByte/s Rx.
Packet size 32k bytes:  3188 KByte/s Tx,  1391 KByte/s Rx.

$ netio -u 10.0.0.12
UDP connection established.
Packet size  1k bytes:  8870 KByte/s (22%) Tx,  999 KByte/s (0%) Rx.
Packet size  2k bytes:  8958 KByte/s (22%) Tx,  999 KByte/s (0%) Rx.
Packet size  4k bytes:  8314 KByte/s (29%) Tx,  1331 KByte/s (0%) Rx.
Packet size  8k bytes:  7278 KByte/s (37%) Tx,  1331 KByte/s (0%) Rx.
Packet size 16k bytes:  5232 KByte/s (55%) Tx,  1329 KByte/s (0%) Rx.
Packet size 32k bytes:  1151 KByte/s (90%) Tx,  1384 KByte/s (0%) Rx.

-- 
echo mailto: NOSPAM !#$.'<*>'|sed 's. ..'|tr "<*> !#:2" org@fr33z3
