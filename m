From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Mon, 24 Apr 2006 11:23:00 +0200
Message-ID: <BAY103-F290B963EE35123CC2E6DB8B2BE0@phx.gbl>
References: <E1FXVdb-0003Tt-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay103-f29.bay103.hotmail.com ([65.54.174.39]:29967 "EHLO
	hotmail.com") by vger.kernel.org with ESMTP id S1751199AbWDXJXC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Apr 2006 05:23:02 -0400
In-Reply-To: <E1FXVdb-0003Tt-00@gondolin.me.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Marco Berizzi <pupilla@hotmail.com> wrote:
> >
> > Is there any news about this issue?
>
>Sorry for the delay, I've been travelling.

Ciao Herbert. Nice hearing you again.

>The fact that tcpdump with "host 172.16.0.138" does not fix it tells
>us that this is related to the NAT that you're doing to the 172.16
>side of the network.
>
>Looking at your packet dump your setup is definitely suboptimal in
>that correct MTU information is not being provided to either side
>of the connection.
>
>The result is that the 10.16 end is sending fragments which have to
>be reassembled at mimosa before immediately getting refragmented on
>its way to pleiadi.
>
>So if it was my network this would be the first issue I'd try to
>address, possibly through MSS clamping.

What should I do? Mangling MSS with iptables  --set-mss ?
Altering MSS to 1440 did the trick. See:
http://marc.theaimsgroup.com/?l=linux-netdev&m=114373067423528&w=2

>However, the fact that the tcpdump causes more chunky packets to
>make it through could be an indication that there is a bug somewhere
>in our NAT/IPsec code or at least a suboptimal memory allocation
>strategy that's somehow avoided when AF_PACKET pins the skb down.
>
>So I would like your help in tracking that down before you fix your
>network properly.

Sure!

>For a start could you please send me the complete kern.log messages
>on mimosa from boot time to the point after a slow connection has
>occured.

Here is. However syslog doesn't log anything relevant when a
connection is 'freezed'.

root@Mimosa:/var/log# cat kernel
Apr 24 09:28:23 Mimosa kernel: klogd 1.4.1, log source = /proc/kmsg started.
Apr 24 09:28:23 Mimosa kernel: Linux version 2.6.16.9 (root@Mimosa) (gcc 
version 3.3.5) #1 Wed Apr 19 17:19:19 CEST 2006
Apr 24 09:28:23 Mimosa kernel: BIOS-provided physical RAM map:
Apr 24 09:28:23 Mimosa kernel:  BIOS-e820: 0000000000000000 - 
000000000009f800 (usable)
Apr 24 09:28:23 Mimosa kernel:  BIOS-e820: 000000000009f800 - 
00000000000a0000 (reserved)
Apr 24 09:28:23 Mimosa kernel:  BIOS-e820: 00000000000dc000 - 
00000000000e0000 (reserved)
Apr 24 09:28:23 Mimosa kernel:  BIOS-e820: 00000000000f0000 - 
0000000000100000 (reserved)
Apr 24 09:28:23 Mimosa kernel:  BIOS-e820: 0000000000100000 - 
000000000a000000 (usable)
Apr 24 09:28:23 Mimosa kernel:  BIOS-e820: 00000000ffff0000 - 
0000000100000000 (reserved)
Apr 24 09:28:23 Mimosa kernel: 160MB LOWMEM available.
Apr 24 09:28:23 Mimosa kernel: On node 0 totalpages: 40960
Apr 24 09:28:23 Mimosa kernel:   DMA zone: 4096 pages, LIFO batch:0
Apr 24 09:28:23 Mimosa kernel:   DMA32 zone: 0 pages, LIFO batch:0
Apr 24 09:28:23 Mimosa kernel:   Normal zone: 36864 pages, LIFO batch:7
Apr 24 09:28:23 Mimosa kernel:   HighMem zone: 0 pages, LIFO batch:0
Apr 24 09:28:23 Mimosa kernel: DMI 2.1 present.
Apr 24 09:28:23 Mimosa kernel: Allocating PCI resources starting at 10000000 
(gap: 0a000000:f5ff0000)
Apr 24 09:28:23 Mimosa kernel: Built 1 zonelists
Apr 24 09:28:23 Mimosa kernel: Kernel command line: auto BOOT_IMAGE=Linux ro 
root=301
Apr 24 09:28:23 Mimosa kernel: Local APIC disabled by BIOS -- you can enable 
it with "lapic"
Apr 24 09:28:23 Mimosa kernel: mapped APIC to ffffd000 (01141000)
Apr 24 09:28:23 Mimosa kernel: Enabling fast FPU save and restore... done.
Apr 24 09:28:23 Mimosa kernel: Initializing CPU#0
Apr 24 09:28:23 Mimosa kernel: PID hash table entries: 1024 (order: 10, 
16384 bytes)
Apr 24 09:28:23 Mimosa kernel: Detected 267.322 MHz processor.
Apr 24 09:28:23 Mimosa kernel: Using tsc for high-res timesource
Apr 24 09:28:23 Mimosa kernel: Console: colour VGA+ 80x25
Apr 24 09:28:23 Mimosa kernel: Dentry cache hash table entries: 32768 
(order: 5, 131072 bytes)
Apr 24 09:28:23 Mimosa kernel: Inode-cache hash table entries: 16384 (order: 
4, 65536 bytes)
Apr 24 09:28:23 Mimosa kernel: Memory: 159220k/163840k available (1886k 
kernel code, 4204k reserved, 481k data, 144k init, 0k highmem)
Apr 24 09:28:23 Mimosa kernel: Checking if this processor honours the WP bit 
even in supervisor mode... Ok.
Apr 24 09:28:23 Mimosa kernel: Calibrating delay using timer specific 
routine.. 535.84 BogoMIPS (lpj=1071691)
Apr 24 09:28:23 Mimosa kernel: Mount-cache hash table entries: 512
Apr 24 09:28:23 Mimosa kernel: CPU: After generic identify, caps: 0183f9ff 
00000000 00000000 00000000 00000000 00000000 00000000
Apr 24 09:28:23 Mimosa kernel: CPU: After vendor identify, caps: 0183f9ff 
00000000 00000000 00000000 00000000 00000000 00000000
Apr 24 09:28:23 Mimosa kernel: CPU: L1 I cache: 16K, L1 D cache: 16K
Apr 24 09:28:23 Mimosa kernel: CPU: After all inits, caps: 0183f9ff 00000000 
00000000 00000040 00000000 00000000 00000000
Apr 24 09:28:23 Mimosa kernel: CPU: Intel Celeron (Covington) stepping 00
Apr 24 09:28:23 Mimosa kernel: Checking 'hlt' instruction... OK.
Apr 24 09:28:23 Mimosa kernel: NET: Registered protocol family 16
Apr 24 09:28:23 Mimosa kernel: PCI: PCI BIOS revision 2.10 entry at 0xfda61, 
last bus=1
Apr 24 09:28:23 Mimosa kernel: PCI: Using configuration type 1
Apr 24 09:28:23 Mimosa kernel: PCI: Probing PCI hardware
Apr 24 09:28:23 Mimosa kernel: PCI: Probing PCI hardware (bus 00)
Apr 24 09:28:23 Mimosa kernel: PCI quirk: region 6100-613f claimed by PIIX4 
ACPI
Apr 24 09:28:23 Mimosa kernel: PCI quirk: region 5f00-5f0f claimed by PIIX4 
SMB
Apr 24 09:28:23 Mimosa kernel: Boot video device is 0000:01:00.0
Apr 24 09:28:23 Mimosa kernel: PCI: Using IRQ router PIIX/ICH [8086/7110] at 
0000:00:07.0
Apr 24 09:28:23 Mimosa kernel: PCI: Bridge: 0000:00:01.0
Apr 24 09:28:23 Mimosa kernel:   IO window: b000-bfff
Apr 24 09:28:23 Mimosa kernel:   MEM window: efe00000-efefffff
Apr 24 09:28:23 Mimosa kernel:   PREFETCH window: e5c00000-e7cfffff
Apr 24 09:28:23 Mimosa kernel: SGI XFS with no debug enabled
Apr 24 09:28:23 Mimosa kernel: Initializing Cryptographic API
Apr 24 09:28:23 Mimosa kernel: io scheduler noop registered
Apr 24 09:28:23 Mimosa kernel: io scheduler deadline registered (default)
Apr 24 09:28:23 Mimosa kernel: Limiting direct PCI/PCI transfers.
Apr 24 09:28:23 Mimosa kernel: serio: i8042 AUX port at 0x60,0x64 irq 12
Apr 24 09:28:23 Mimosa kernel: serio: i8042 KBD port at 0x60,0x64 irq 1
Apr 24 09:28:23 Mimosa kernel: Uniform Multi-Platform E-IDE driver Revision: 
7.00alpha2
Apr 24 09:28:23 Mimosa kernel: ide: Assuming 33MHz system bus speed for PIO 
modes; override with idebus=xx
Apr 24 09:28:23 Mimosa kernel: PIIX4: IDE controller at PCI slot 
0000:00:07.1
Apr 24 09:28:23 Mimosa kernel: PIIX4: chipset revision 1
Apr 24 09:28:23 Mimosa kernel: PIIX4: not 100%% native mode: will probe irqs 
later
Apr 24 09:28:23 Mimosa kernel:     ide0: BM-DMA at 0xffa0-0xffa7, BIOS 
settings: hda:DMA, hdb:pio
Apr 24 09:28:23 Mimosa kernel:     ide1: BM-DMA at 0xffa8-0xffaf, BIOS 
settings: hdc:DMA, hdd:pio
Apr 24 09:28:23 Mimosa kernel: Probing IDE interface ide0...
Apr 24 09:28:23 Mimosa kernel: hda: QUANTUM FIREBALL EX3.2A, ATA DISK drive
Apr 24 09:28:23 Mimosa kernel: ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
Apr 24 09:28:23 Mimosa kernel: Probing IDE interface ide1...
Apr 24 09:28:23 Mimosa kernel: hdc: CRD-8160B, ATAPI CD/DVD-ROM drive
Apr 24 09:28:23 Mimosa kernel: ide1 at 0x170-0x177,0x376 on irq 15
Apr 24 09:28:23 Mimosa kernel: hda: max request size: 128KiB
Apr 24 09:28:23 Mimosa kernel: hda: 6306048 sectors (3228 MB) w/418KiB 
Cache, CHS=6256/16/63, UDMA(33)
Apr 24 09:28:23 Mimosa kernel: hda: cache flushes not supported
Apr 24 09:28:23 Mimosa kernel:  hda: hda1 hda2 < hda5 hda6 hda7 hda8 hda9 >
Apr 24 09:28:23 Mimosa kernel: mice: PS/2 mouse device common for all mice
Apr 24 09:28:23 Mimosa kernel: NET: Registered protocol family 2
Apr 24 09:28:23 Mimosa kernel: input: AT Translated Set 2 keyboard as 
/class/input/input0
Apr 24 09:28:23 Mimosa kernel: IP route cache hash table entries: 2048 
(order: 1, 8192 bytes)
Apr 24 09:28:23 Mimosa kernel: TCP established hash table entries: 8192 
(order: 3, 32768 bytes)
Apr 24 09:28:23 Mimosa kernel: TCP bind hash table entries: 8192 (order: 3, 
32768 bytes)
Apr 24 09:28:23 Mimosa kernel: TCP: Hash tables configured (established 8192 
bind 8192)
Apr 24 09:28:23 Mimosa kernel: TCP reno registered
Apr 24 09:28:23 Mimosa kernel: ip_conntrack version 2.4 (1280 buckets, 10240 
max) - 232 bytes per conntrack
Apr 24 09:28:23 Mimosa kernel: ip_tables: (C) 2000-2006 Netfilter Core Team
Apr 24 09:28:23 Mimosa kernel: TCP bic registered
Apr 24 09:28:23 Mimosa kernel: Initializing IPsec netlink socket
Apr 24 09:28:23 Mimosa kernel: NET: Registered protocol family 1
Apr 24 09:28:23 Mimosa kernel: NET: Registered protocol family 17
Apr 24 09:28:23 Mimosa kernel: NET: Registered protocol family 15
Apr 24 09:28:23 Mimosa kernel: Using IPI Shortcut mode
Apr 24 09:28:23 Mimosa kernel: XFS mounting filesystem hda1
Apr 24 09:28:23 Mimosa kernel: Ending clean XFS mount for filesystem: hda1
Apr 24 09:28:23 Mimosa kernel: VFS: Mounted root (xfs filesystem) readonly.
Apr 24 09:28:23 Mimosa kernel: Freeing unused kernel memory: 144k freed
Apr 24 09:28:23 Mimosa kernel: Adding 330584k swap on /dev/hda9.  
Priority:-1 extents:1 across:330584k
Apr 24 09:28:23 Mimosa kernel: PCI: Found IRQ 10 for device 0000:00:09.0
Apr 24 09:28:23 Mimosa kernel: 3c59x: Donald Becker and others. 
www.scyld.com/network/vortex.html
Apr 24 09:28:23 Mimosa kernel: 0000:00:09.0: 3Com PCI 3c905 Boomerang 
100baseTx at 0001dc00. Vers LK1.1.19
Apr 24 09:28:23 Mimosa kernel: PCI: Found IRQ 11 for device 0000:00:0a.0
Apr 24 09:28:23 Mimosa kernel: 0000:00:0a.0: 3Com PCI 3c905 Boomerang 
100baseTx at 0001da00. Vers LK1.1.19
Apr 24 09:28:23 Mimosa kernel: PCI: Found IRQ 9 for device 0000:00:0b.0
Apr 24 09:28:23 Mimosa kernel: PCI: Sharing IRQ 9 with 0000:00:07.2
Apr 24 09:28:23 Mimosa kernel: 0000:00:0b.0: 3Com PCI 3c905 Boomerang 
100baseTx at 0001d800. Vers LK1.1.19
Apr 24 09:28:23 Mimosa kernel: ip_conntrack_pptp version 3.1 loaded
Apr 24 09:28:23 Mimosa kernel: ip_nat_pptp version 3.0 loaded
Apr 24 09:28:23 Mimosa kernel: XFS mounting filesystem hda5
Apr 24 09:28:23 Mimosa kernel: Ending clean XFS mount for filesystem: hda5
Apr 24 09:28:23 Mimosa kernel: XFS mounting filesystem hda6
Apr 24 09:28:23 Mimosa kernel: Ending clean XFS mount for filesystem: hda6
Apr 24 09:28:23 Mimosa kernel: XFS mounting filesystem hda7
Apr 24 09:28:23 Mimosa kernel: Ending clean XFS mount for filesystem: hda7
Apr 24 09:28:23 Mimosa kernel: XFS mounting filesystem hda8
Apr 24 09:28:23 Mimosa kernel: Ending clean XFS mount for filesystem: hda8
Apr 24 09:28:23 Mimosa kernel: PCI: Found IRQ 10 for device 0000:00:09.0
Apr 24 09:28:23 Mimosa kernel: PCI: Found IRQ 11 for device 0000:00:0a.0
Apr 24 09:28:23 Mimosa kernel: PCI: Found IRQ 9 for device 0000:00:0b.0
Apr 24 09:28:23 Mimosa kernel: PCI: Sharing IRQ 9 with 0000:00:07.2

>  I'd also like to see /proc/net/snmp at that point.

Here is /proc/net/snmp few minutes after a reboot:

Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams 
InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes 
ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
Ip: 1 64 2493 0 31 746 0 0 1198 1586 2 0 1 27 13 1 14 0 0
Icmp: InMsgs InErrors InDestUnreachs InTimeExcds InParmProbs InSrcQuenchs 
InRedirects InEchos InEchoReps InTimestamps InTimestampReps InAddrMasks 
InAddrMaskReps OutMsgs OutErrors OutDestUnreachs OutTimeExcds OutParmProbs 
OutSrcQuenchs OutRedirects OutEchos OutEchoReps OutTimestamps 
OutTimestampReps OutAddrMasks OutAddrMaskReps
Icmp: 1 0 0 0 0 0 0 1 0 0 0 0 0 719 0 718 0 0 0 0 0 1 0 0 0 0
Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens 
AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts
Tcp: 1 200 120000 -1 45 47 0 0 91 426 358 0 0 0
Udp: InDatagrams NoPorts InErrors OutDatagrams
Udp: 100 5 0 101

here is snmp when the connection is freezed:

Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams 
InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes 
ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
Ip: 1 64 75417 0 31 45889 0 0 36721 53933 2 0 2 182 90 2 84 0 112
Icmp: InMsgs InErrors InDestUnreachs InTimeExcds InParmProbs InSrcQuenchs 
InRedirects InEchos InEchoReps InTimestamps InTimestampReps InAddrMasks 
InAddrMaskReps OutMsgs OutErrors OutDestUnreachs OutTimeExcds OutParmProbs 
OutSrcQuenchs OutRedirects OutEchos OutEchoReps OutTimestamps 
OutTimestampReps OutAddrMasks OutAddrMaskReps
Icmp: 7 0 6 0 0 0 0 1 0 0 0 0 0 3049 0 3048 0 0 0 0 0 1 0 0 0 0
Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens 
AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts
Tcp: 1 200 120000 -1 81 82 0 18 91 3785 3648 0 0 45
Udp: InDatagrams NoPorts InErrors OutDatagrams
Udp: 197 5 0 187

and here is snmp when the sapgui client has told me that the
connections has been reset:

root@Mimosa:/var/log# cat SNMP-CONN-RESET
Ip: Forwarding DefaultTTL InReceives InHdrErrors InAddrErrors ForwDatagrams 
InUnknownProtos InDiscards InDelivers OutRequests OutDiscards OutNoRoutes 
ReasmTimeout ReasmReqds ReasmOKs ReasmFails FragOKs FragFails FragCreates
Ip: 1 64 79257 0 31 48139 0 0 38799 56650 2 0 2 182 90 2 90 0 124
Icmp: InMsgs InErrors InDestUnreachs InTimeExcds InParmProbs InSrcQuenchs 
InRedirects InEchos InEchoReps InTimestamps InTimestampReps InAddrMasks 
InAddrMaskReps OutMsgs OutErrors OutDestUnreachs OutTimeExcds OutParmProbs 
OutSrcQuenchs OutRedirects OutEchos OutEchoReps OutTimestamps 
OutTimestampReps OutAddrMasks OutAddrMaskReps
Icmp: 7 0 6 0 0 0 0 1 0 0 0 0 0 3073 0 3072 0 0 0 0 0 1 0 0 0 0
Tcp: RtoAlgorithm RtoMin RtoMax MaxConn ActiveOpens PassiveOpens 
AttemptFails EstabResets CurrEstab InSegs OutSegs RetransSegs InErrs OutRsts
Tcp: 1 200 120000 -1 81 82 0 18 91 4114 3845 1 0 45
Udp: InDatagrams NoPorts InErrors OutDatagrams
Udp: 197 5 0 187

Some other info you may need:

root@Mimosa:/var/log# ip x s
src mimosa dst checkpoint
        proto esp spi 0x58216bd1 reqid 16417 mode tunnel
        replay-window 32
        auth md5 0x22137787b56689beb2319f7abc657975
        enc des3_ede 0x4b593c1b5bc4e4b4c02d79967d982a5912ac9812de1903a6
src mimosa dst checkpoint
        proto esp spi 0x978f4fc9 reqid 16417 mode tunnel
        replay-window 32
        auth md5 0x643172106050837ce9d3eeaf9e0ff622
        enc des3_ede 0x84919cf37ec2fbd737abe55d12e1a92ed10ff3a261ef6924
src checkpoint dst mimosa
        proto esp spi 0x1cd874d8 reqid 16417 mode tunnel
        replay-window 32
        auth md5 0x7ee288d719287808b92ee2c5e4e01bbe
        enc des3_ede 0x525d1b6ed65aad5f7d2052fd66548f713327ce28c94ed0fd
src pleiadi dst mimosa
        proto esp spi 0xdca32a9c reqid 16433 mode transport
        replay-window 32
        auth sha1 0x41ffc9e8fae8811b6695629fc637315ebb076371
        enc aes 0xf27ca4f79274e15d0030e0b5940bb802
src pleiadi dst mimosa
        proto comp spi 0x00002718 reqid 16434 mode tunnel
        replay-window 0
        comp deflate 0x
src pleiadi dst mimosa
        proto esp spi 0x37f93e11 reqid 16437 mode transport
        replay-window 32
        auth sha1 0x6458e50d01a63f6bfdfe0a1741a492bc050fca5a
        enc aes 0x853b5f4a30611d0a9c653bf716cd6f0f
src pleiadi dst mimosa
        proto comp spi 0x0000ae6a reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src pleiadi dst mimosa
        proto esp spi 0x5c02ac38 reqid 16437 mode transport
        replay-window 32
        auth sha1 0xe75763df2eb2d261eca6adc1f373dabf06c5171c
        enc aes 0xc41bc0b482cc6bda335ae15ee2636743
src pleiadi dst mimosa
        proto comp spi 0x00003e90 reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src pleiadi dst mimosa
        proto esp spi 0x415ecc00 reqid 16437 mode transport
        replay-window 32
        auth sha1 0x48b5320e71a3e162599e8c6d68716e9f4bf2feee
        enc aes 0x76983f2e9106f3ee21975d09a19a6497
src pleiadi dst mimosa
        proto comp spi 0x00004a2d reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src pleiadi dst mimosa
        proto esp spi 0x563a307a reqid 16437 mode transport
        replay-window 32
        auth sha1 0x0f2705729a774b0d7054082c3bb6f3d5bb3a4f5d
        enc aes 0xf3e7c29bb77b4c2957d404ba05622e59
src pleiadi dst mimosa
        proto comp spi 0x00009a7d reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src pleiadi dst mimosa
        proto esp spi 0xab5313af reqid 16437 mode transport
        replay-window 32
        auth sha1 0x109e790581a3650db4cad4c4dbeda2af69a0b745
        enc aes 0xe470ce8d38b2434e8025befe6738d217
src pleiadi dst mimosa
        proto comp spi 0x000035e1 reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src pleiadi dst mimosa
        proto esp spi 0x4c29eff3 reqid 16437 mode transport
        replay-window 32
        auth sha1 0x7ac7f98d075a123dce9e81e112cd55128c525bbe
        enc aes 0xe55d41e08ce307fcb0addb3e430b58af
src pleiadi dst mimosa
        proto comp spi 0x00008e46 reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src pleiadi dst mimosa
        proto esp spi 0x0462260a reqid 16437 mode transport
        replay-window 32
        auth sha1 0xe0c3d0334b880f823a9a4769dbf411139a82ebbb
        enc aes 0x89e8e48aaa7cb8027cc9e3122c39c7dc
src pleiadi dst mimosa
        proto comp spi 0x0000bf03 reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src pleiadi dst mimosa
        proto (null) spi 0x50ccebfe reqid 0 mode tunnel
        replay-window 0
src checkpoint dst mimosa
        proto esp spi 0xe0c22b0c reqid 16417 mode tunnel
        replay-window 32
        auth md5 0xa90478ede92c8d1988552972feeabeb3
        enc des3_ede 0xc5befbfd6004568008b711f83d8fcd90fb0123737ba00acf
src mimosa dst pleiadi
        proto esp spi 0x5e795c12 reqid 16433 mode transport
        replay-window 32
        auth sha1 0x11ddb67e9dfb1187330c64ffaf37da254a98c9f2
        enc aes 0xe6fd0aea6b7855816c94338399491ccf
src mimosa dst pleiadi
        proto comp spi 0x0000e91c reqid 16434 mode tunnel
        replay-window 0
        comp deflate 0x
src mimosa dst pleiadi
        proto esp spi 0xe18dbbbf reqid 16437 mode transport
        replay-window 32
        auth sha1 0x2c52b29a38b1b79ef45690b8755cd2e483c6923f
        enc aes 0x660be4e4e8484417f0c051508c6909d7
src mimosa dst pleiadi
        proto comp spi 0x00007821 reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src mimosa dst pleiadi
        proto esp spi 0x18995573 reqid 16437 mode transport
        replay-window 32
        auth sha1 0xb9d144c522cb1b180dba2cb2d2a95420d1d791a3
        enc aes 0x2833ac713fad3186810b2c4f78ef1787
src mimosa dst pleiadi
        proto comp spi 0x000020b9 reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src mimosa dst pleiadi
        proto esp spi 0xb8f7f1e4 reqid 16437 mode transport
        replay-window 32
        auth sha1 0x4b4cab49bcbbf799cf88879e010c17621a759d9b
        enc aes 0xaf313a96f5748181b6672d81a1004321
src mimosa dst pleiadi
        proto comp spi 0x00002555 reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src mimosa dst pleiadi
        proto esp spi 0xbc4b5fc7 reqid 16437 mode transport
        replay-window 32
        auth sha1 0xa5b72352881350114a6f1acb322e669691c82fb3
        enc aes 0x2ee23e00685b09b66b0df72eb25a3518
src mimosa dst pleiadi
        proto comp spi 0x00006f4a reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src mimosa dst pleiadi
        proto esp spi 0xe33f92b4 reqid 16437 mode transport
        replay-window 32
        auth sha1 0xcc61874dc2519009aad5df812db28572db2d987c
        enc aes 0x9e4c947a89a4da0461af8124e1e9151c
src mimosa dst pleiadi
        proto comp spi 0x0000593d reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src mimosa dst pleiadi
        proto esp spi 0x03d8b176 reqid 16437 mode transport
        replay-window 32
        auth sha1 0x2c5a87b63b6e9526f3f38657b52cc0a0c381ccaa
        enc aes 0xdaea0fb6c321f949b54e7341d87a6cf9
src mimosa dst pleiadi
        proto comp spi 0x0000059f reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src mimosa dst pleiadi
        proto esp spi 0x1d74794c reqid 16437 mode transport
        replay-window 32
        auth sha1 0x7958d5c52d984b969e4bc06e865bf3a12609e365
        enc aes 0x864921b8a25a16da20543e630e91c84e
src mimosa dst pleiadi
        proto comp spi 0x000092aa reqid 16438 mode tunnel
        replay-window 0
        comp deflate 0x
src mimosa dst pleiadi
        proto (null) spi 0x5520231e reqid 0 mode tunnel
        replay-window 0

root@Mimosa:/var/log# iptables -vxnL
Chain INPUT (policy DROP 2356 packets, 226776 bytes)
    pkts      bytes target     prot opt in     out     source               
destination
   13680  2441479 ACCEPT     all  --  *      *       pleiadi       0.0.0.0/0
    1735    91284 ACCEPT     tcp  --  *      *       172.16.1.247         
0.0.0.0/0           tcp dpt:23
     553    41367 ACCEPT     all  --  *      *       127.0.0.1            
127.0.0.1
   23984 10034025 ACCEPT     all  --  *      *       0.0.0.0/0            
0.0.0.0/0           state RELATED,ESTABLISHED
    2480   232720 green-me   all  --  eth2   *       172.18.1.0/24        
0.0.0.0/0
       0        0 dmz-me     all  --  eth1   *       milano-dmz/27        
0.0.0.0/0
    9712   921094 red-me     all  --  eth0   *       0.0.0.0/0            
0.0.0.0/0

Chain FORWARD (policy DROP 802 packets, 151528 bytes)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 ACCEPT     all  --  eth0   *       151.25.90.31         
172.18.1.0/24
       0        0 ACCEPT     all  --  *      eth0    172.18.1.0/24        
151.25.90.31
       0        0 ACCEPT     udp  --  *      *       milano-dmz.14          
0.0.0.0/0           multiport dports 53,500,2746,18231,18232,18233,18234
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.14          
0.0.0.0/0           multiport dports 264,500,1723
       0        0 ACCEPT     ah   --  *      *       0.0.0.0/0            
milano-dmz.14
       0        0 ACCEPT     ah   --  *      *       milano-dmz.14          
0.0.0.0/0
       0        0 ACCEPT     esp  --  *      *       0.0.0.0/0            
milano-dmz.14
       0        0 ACCEPT     esp  --  *      *       milano-dmz.14          
0.0.0.0/0
       0        0 ACCEPT     47   --  *      *       0.0.0.0/0            
milano-dmz.14
       0        0 ACCEPT     47   --  *      *       milano-dmz.14          
0.0.0.0/0
       0        0 ACCEPT     udp  --  *      *       milano-dmz.13          
0.0.0.0/0           multiport dports 53,500,2746,18231,18232,18233,18234
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.13          
0.0.0.0/0           multiport dports 264,500,1723
       0        0 ACCEPT     ah   --  *      *       0.0.0.0/0            
milano-dmz.13
       0        0 ACCEPT     ah   --  *      *       milano-dmz.13          
0.0.0.0/0
       0        0 ACCEPT     esp  --  *      *       0.0.0.0/0            
milano-dmz.13
       0        0 ACCEPT     esp  --  *      *       milano-dmz.13          
0.0.0.0/0
       0        0 ACCEPT     47   --  *      *       0.0.0.0/0            
milano-dmz.13
       0        0 ACCEPT     47   --  *      *       milano-dmz.13          
0.0.0.0/0
       0        0 ACCEPT     udp  --  *      *       milano-dmz.12          
0.0.0.0/0           multiport dports 53,500,2746,18231,18232,18233,18234
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.12          
0.0.0.0/0           multiport dports 264,500,1723
       0        0 ACCEPT     ah   --  *      *       0.0.0.0/0            
milano-dmz.12
       0        0 ACCEPT     ah   --  *      *       milano-dmz.12          
0.0.0.0/0
       0        0 ACCEPT     esp  --  *      *       0.0.0.0/0            
milano-dmz.12
       0        0 ACCEPT     esp  --  *      *       milano-dmz.12          
0.0.0.0/0
       0        0 ACCEPT     47   --  *      *       0.0.0.0/0            
milano-dmz.12
       0        0 ACCEPT     47   --  *      *       milano-dmz.12          
0.0.0.0/0
       0        0 ACCEPT     udp  --  *      *       milano-dmz.11          
0.0.0.0/0           multiport dports 53,500,2746,18231,18232,18233,18234
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.11          
0.0.0.0/0           multiport dports 264,500,1723
       0        0 ACCEPT     ah   --  *      *       0.0.0.0/0            
milano-dmz.11
       0        0 ACCEPT     ah   --  *      *       milano-dmz.11          
0.0.0.0/0
       0        0 ACCEPT     esp  --  *      *       0.0.0.0/0            
milano-dmz.11
       0        0 ACCEPT     esp  --  *      *       milano-dmz.11          
0.0.0.0/0
       0        0 ACCEPT     47   --  *      *       0.0.0.0/0            
milano-dmz.11
       0        0 ACCEPT     47   --  *      *       milano-dmz.11          
0.0.0.0/0
       0        0 ACCEPT     udp  --  *      *       milano-dmz.10          
0.0.0.0/0           multiport dports 53,500,2746,18231,18232,18233,18234
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.10          
0.0.0.0/0           multiport dports 264,500,1723
       0        0 ACCEPT     ah   --  *      *       0.0.0.0/0            
milano-dmz.10
       0        0 ACCEPT     ah   --  *      *       milano-dmz.10          
0.0.0.0/0
       0        0 ACCEPT     esp  --  *      *       0.0.0.0/0            
milano-dmz.10
       0        0 ACCEPT     esp  --  *      *       milano-dmz.10          
0.0.0.0/0
       0        0 ACCEPT     47   --  *      *       0.0.0.0/0            
milano-dmz.10
       0        0 ACCEPT     47   --  *      *       milano-dmz.10          
0.0.0.0/0
       0        0 ACCEPT     all  --  *      *       napoli-phone/27     
10.0.0.0/8
    2339   431385 ACCEPT     all  --  *      *       172.16.0.0/12        
10.0.0.0/8
       0        0 ACCEPT     tcp  --  *      *       172.18.1.0/24        
83.103.72.197       multiport dports 20,21
       0        0 ACCEPT     tcp  --  *      *       172.18.1.0/24        
193.221.113.0/24    multiport dports 554,1755
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
151.9.17.169        multiport dports 20,21
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
213.26.116.140      multiport dports 20,21
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
81.112.114.154      multiport dports 20,21
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
212.131.138.194     multiport dports 20,21
   49571 27662418 ACCEPT     all  --  *      *       0.0.0.0/0            
0.0.0.0/0           state RELATED,ESTABLISHED
     244    35765 ACCEPT     all  --  *      *       172.18.1.0/24        
172.16.0.0/23
     371    53064 ACCEPT     all  --  *      *       172.16.0.0/23        
172.18.1.0/24
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
192.168.0.0/24
       0        0 ACCEPT     all  --  *      *       192.168.0.0/24       
172.18.1.0/24
     214    17191 ACCEPT     all  --  *      *       172.18.1.0/24        
172.23.0.0/23
     333    22798 ACCEPT     all  --  *      *       172.23.0.0/23        
172.18.1.0/24
      36     3780 ACCEPT     all  --  *      *       172.18.1.0/24        
172.25.1.0/24
       0        0 ACCEPT     all  --  *      *       172.25.1.0/24        
172.18.1.0/24
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
172.25.5.0/24
       0        0 ACCEPT     all  --  *      *       172.25.5.0/24        
172.18.1.0/24
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
172.25.255.0/24
       0        0 ACCEPT     all  --  *      *       172.25.255.0/24      
172.18.1.0/24
      50     8179 ACCEPT     all  --  *      *       172.18.1.0/24        
172.17.1.0/24
      46     5878 ACCEPT     all  --  *      *       172.17.1.0/24        
172.18.1.0/24
      15     3855 ACCEPT     all  --  *      *       172.18.1.0/24        
172.22.1.0/24
       0        0 ACCEPT     all  --  *      *       172.22.1.0/24        
172.18.1.0/24
      18     4013 ACCEPT     all  --  *      *       172.18.1.0/24        
172.21.1.0/24
       3      158 ACCEPT     all  --  *      *       172.21.1.0/24        
172.18.1.0/24
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
napoli-phone/27
      30     5195 ACCEPT     all  --  *      *       napoli-phone/27     
172.18.1.0/24
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
192.168.77.0/24
       0        0 ACCEPT     all  --  *      *       192.168.77.0/24      
172.18.1.0/24
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
172.23.2.0/23
       0        0 ACCEPT     all  --  *      *       172.23.2.0/23        
172.18.1.0/24
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
172.23.4.0/23
       0        0 ACCEPT     all  --  *      *       172.23.4.0/23        
172.18.1.0/24
    3319   273661 green-red  all  --  eth2   eth0    172.18.1.0/24        
0.0.0.0/0
       0        0 green-dmz  all  --  eth2   eth1    172.18.1.0/24        
milano-dmz/27
      15      995 dmz-red    all  --  eth1   eth0    milano-dmz/27        
0.0.0.0/0
       0        0 dmz-green  all  --  eth1   eth2    milano-dmz/27        
172.18.1.0/24
     482   136099 syn-flood-dmz  all  --  eth0   eth1    0.0.0.0/0           
  milano-dmz/27
     541    26369 syn-flood-green  all  --  eth0   eth2    0.0.0.0/0         
    172.18.1.0/24

Chain OUTPUT (policy DROP 2 packets, 138 bytes)
    pkts      bytes target     prot opt in     out     source               
destination
     553    41367 ACCEPT     all  --  *      *       127.0.0.1            
127.0.0.1
   42536 27618087 ACCEPT     all  --  *      *       0.0.0.0/0            
0.0.0.0/0           state RELATED,ESTABLISHED
      43     2540 me-green   all  --  *      eth2    0.0.0.0/0            
172.18.1.0/24
       5      372 me-dmz     all  --  *      eth1    0.0.0.0/0            
milano-dmz/27
     169    14658 me-red     all  --  *      eth0    0.0.0.0/0            
0.0.0.0/0

Chain dmz-green (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.28          
172.18.1.13         multiport dports 20,21,25,389
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.28          
172.18.1.208        tcp dpt:80
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.28          
172.18.1.219        tcp dpt:80
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.28          
172.18.1.211        tcp dpt:80
       0        0 ACCEPT     tcp  --  *      *       milano-dmz.28          
172.18.1.210        tcp dpt:2311
       0        0 REJECT     all  --  *      *       0.0.0.0/0            
0.0.0.0/0           reject-with icmp-host-unreachable

Chain dmz-me (1 references)
    pkts      bytes target     prot opt in     out     source               
destination

Chain dmz-red (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 icmp-me    icmp --  *      *       0.0.0.0/0            
0.0.0.0/0
       1       60 ACCEPT     tcp  --  *      *       milano-dmz.28          
0.0.0.0/0           multiport dports 20,21,80
       5      220 ACCEPT     all  --  *      *       milano-dmz/27        
venezia-dmz/27
       0        0 ACCEPT     all  --  *      *       milano-dmz/27        
firenze-dmz/28
       0        0 ACCEPT     all  --  *      *       milano-dmz/27        
roma-dmz/27
       0        0 ACCEPT     all  --  *      *       milano-dmz/27        
napoli-dmz/28
       0        0 ACCEPT     all  --  *      *       milano-dmz/27        
napoli-phone/27
       0        0 ACCEPT     all  --  *      *       milano-dmz/27        
bologna-dmz/27
       0        0 ACCEPT     all  --  *      *       milano-dmz/27        
piacenza-dmz/27
       0        0 ACCEPT     all  --  *      *       milano-dmz/27        
genova-dmz/27
       0        0 ACCEPT     all  --  *      *       milano-dmz/27        
sbt-dmz/28
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
0.0.0.0/0           multiport dports 25,53,123
       9      715 ACCEPT     udp  --  *      *       0.0.0.0/0            
0.0.0.0/0           multiport dports 53,123

Chain green-dmz (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 ACCEPT     all  --  *      *       172.18.1.13          
milano-dmz.28
       0        0 DROP       tcp  --  *      *       0.0.0.0/0            
0.0.0.0/0           tcp dpt:23
       0        0 ACCEPT     all  --  *      *       0.0.0.0/0            
0.0.0.0/0

Chain green-me (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 icmp-me    icmp --  *      *       0.0.0.0/0            
0.0.0.0/0
       0        0 ACCEPT     tcp  --  *      *       172.18.1.13          
0.0.0.0/0           tcp dpt:23
       0        0 ACCEPT     icmp --  *      *       172.18.1.30          
0.0.0.0/0           icmp type 8
     156     8880 ACCEPT     tcp  --  *      *       0.0.0.0/0            
0.0.0.0/0           tcp dpt:7777

Chain green-red (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 ACCEPT     tcp  --  *      *       172.18.1.233         
0.0.0.0/0           tcp dpt:1863
       0        0 ACCEPT     tcp  --  *      *       172.18.1.232         
0.0.0.0/0           tcp dpt:1863
       0        0 ACCEPT     tcp  --  *      *       172.18.1.230         
0.0.0.0/0           tcp dpt:1863
       0        0 ACCEPT     tcp  --  *      *       172.18.1.204         
0.0.0.0/0           tcp dpt:1863
       0        0 ACCEPT     tcp  --  *      *       172.18.1.190         
0.0.0.0/0           multiport dports 25,110
       0        0 ACCEPT     tcp  --  *      *       172.18.1.194         
0.0.0.0/0           multiport dports 25,110
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
172.16.0.0/12
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
venezia-dmz/27
       0        0 ACCEPT     tcp  --  *      *       172.18.1.0/24        
0.0.0.0/0           multiport dports 
23,922,1494,1503,1720,3200,3299,3300,3389,5040,5631,5632,5900,8999,10000
       0        0 ACCEPT     tcp  --  *      *       172.18.1.0/24        
0.0.0.0/0           multiport dports 3201,6667,3390,22,1723
       0        0 ACCEPT     udp  --  *      *       172.18.1.0/24        
0.0.0.0/0           multiport dports 500,1025,4500,5631,5632,10000
       0        0 ACCEPT     all  --  *      *       172.18.1.0/24        
firenze-dmz.123
       0        0 ACCEPT     tcp  --  *      *       172.18.1.208         
0.0.0.0/0           multiport dports 25
    3319   273661 REJECT     all  --  *      *       0.0.0.0/0            
0.0.0.0/0           reject-with icmp-host-unreachable

Chain icmp-me (5 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 ACCEPT     icmp --  *      *       0.0.0.0/0            
0.0.0.0/0

Chain me-dmz (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
0.0.0.0/0           tcp dpt:53
       5      372 ACCEPT     udp  --  *      *       0.0.0.0/0            
0.0.0.0/0           udp dpt:53

Chain me-green (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 icmp-me    icmp --  *      *       0.0.0.0/0            
0.0.0.0/0
      43     2540 ACCEPT     tcp  --  *      *       0.0.0.0/0            
172.18.1.13         tcp dpt:139

Chain me-red (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 icmp-me    icmp --  *      *       0.0.0.0/0            
0.0.0.0/0
      39     5928 ACCEPT     esp  --  *      *       0.0.0.0/0            
0.0.0.0/0
      10     1512 ACCEPT     udp  --  *      *       0.0.0.0/0            
0.0.0.0/0           multiport dports 500,4500
     118     7080 ACCEPT     tcp  --  *      *       0.0.0.0/0           
!172.16.0.0/12       multiport dports 20,21,80,123,443,8000,81
       0        0 ACCEPT     udp  --  *      *       0.0.0.0/0           
!172.16.0.0/12       multiport dports 123

Chain red-dmz (4 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 DROP       tcp  --  *      *       172.16.0.0/12        
0.0.0.0/0           tcp dpt:23
       0        0 ACCEPT     all  --  *      *       172.16.0.0/12        
0.0.0.0/0
       4      200 ACCEPT     all  --  *      *       venezia-dmz/27    
milano-dmz/27
       0        0 ACCEPT     all  --  *      *       firenze-dmz/28     
milano-dmz/27
       0        0 ACCEPT     all  --  *      *       roma-dmz/27     
milano-dmz/27
       0        0 ACCEPT     all  --  *      *       napoli-dmz/28     
milano-dmz/27
       0        0 ACCEPT     all  --  *      *       napoli-phone/27     
milano-dmz/27
       0        0 ACCEPT     all  --  *      *       bologna-dmz/27     
milano-dmz/27
       0        0 ACCEPT     all  --  *      *       piacenza-dmz/27     
milano-dmz/27
       0        0 ACCEPT     all  --  *      *       genova-dmz/27       
milano-dmz/27
       0        0 ACCEPT     all  --  *      *       sbt-dmz/28      
milano-dmz/27
       2      128 ACCEPT     tcp  --  *      *       0.0.0.0/0            
milano-dmz.28         multiport dports 20,21,80
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
0.0.0.0/0           multiport dports 53
       1       64 ACCEPT     udp  --  *      *       0.0.0.0/0            
0.0.0.0/0           multiport dports 53

Chain red-green (4 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 ACCEPT     all  --  *      *       172.16.0.0/12        
0.0.0.0/0
       0        0 ACCEPT     tcp  --  *      *       venezia-dmz.240       
172.18.1.13         multiport dports 135,139,1252,1262
      19      912 ACCEPT     tcp  --  *      *       0.0.0.0/0            
172.18.1.13         multiport dports 110,143
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
172.18.1.15         multiport dports 3200,3220
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
172.18.1.216        multiport dports 20,21
     192     9492 ACCEPT     tcp  --  *      *       0.0.0.0/0            
172.18.1.221        multiport dports 80
       0        0 ACCEPT     tcp  --  *      *       0.0.0.0/0            
172.18.1.218        multiport dports 3389
       3      144 ACCEPT     tcp  --  *      *       0.0.0.0/0            
172.18.1.208        multiport dports 25,443
       0        0 ACCEPT     tcp  --  *      *       80.205.159.108       
172.18.1.17         multiport dports 3200,5900
       0        0 ACCEPT     tcp  --  *      *       85.36.47.39          
172.18.1.15         multiport dports 3200,5900

Chain red-me (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 icmp-me    icmp --  *      *       0.0.0.0/0            
0.0.0.0/0
       5      744 ACCEPT     esp  --  *      *       0.0.0.0/0            
0.0.0.0/0
    9647   910930 ACCEPT     4    --  *      *       0.0.0.0/0            
0.0.0.0/0
      28     6484 ACCEPT     udp  --  *      *       0.0.0.0/0            
0.0.0.0/0           multiport dports 500,4500

Chain syn-flood-dmz (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 red-dmz    all  --  *      *       172.16.0.0/12        
0.0.0.0/0
     178     9120 red-dmz    tcp  --  *      *       0.0.0.0/0            
0.0.0.0/0           tcp flags:0x17/0x02 limit: avg 20/min burst 5
       6      249 red-dmz    tcp  --  *      *       0.0.0.0/0            
0.0.0.0/0           tcp flags:0x17/0x04 limit: avg 20/min burst 5
     160   119930 red-dmz    udp  --  *      *       0.0.0.0/0            
0.0.0.0/0

Chain syn-flood-green (1 references)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 red-green  all  --  *      *       172.16.0.0/12        
0.0.0.0/0
     214    10548 red-green  tcp  --  *      *       0.0.0.0/0            
0.0.0.0/0           tcp flags:0x17/0x02 limit: avg 20/min burst 5
       0        0 red-green  tcp  --  *      *       0.0.0.0/0            
0.0.0.0/0           tcp flags:0x17/0x04 limit: avg 20/min burst 5
       1      269 red-green  udp  --  *      *       0.0.0.0/0            
0.0.0.0/0


root@Mimosa:/var/log# iptables -vxnL -t nat
Chain PREROUTING (policy ACCEPT 8465 packets, 879102 bytes)
    pkts      bytes target     prot opt in     out     source               
destination
      19      912 DNAT       tcp  --  eth0   *       0.0.0.0/0            
milano-dmz.24         multiport dports 110,143 to:172.18.1.13
       0        0 DNAT       tcp  --  eth0   *       80.205.159.108       
milano-dmz.22         multiport dports 3200,5900 to:172.18.1.17
       0        0 DNAT       tcp  --  eth0   *       0.0.0.0/0            
milano-dmz.22         multiport dports 3200,5900,3220 to:172.18.1.15
       0        0 DNAT       tcp  --  eth0   *       0.0.0.0/0            
milano-dmz.20         multiport dports 20,21 to:172.18.1.216
     520    25140 DNAT       tcp  --  eth0   *       0.0.0.0/0            
milano-dmz.20         multiport dports 80 to:172.18.1.221
       0        0 DNAT       tcp  --  eth0   *       0.0.0.0/0            
milano-dmz.20         multiport dports 3389 to:172.18.1.218
       3      144 DNAT       tcp  --  eth0   *       0.0.0.0/0            
milano-dmz.20         multiport dports 25,443 to:172.18.1.208

Chain POSTROUTING (policy ACCEPT 1142 packets, 111012 bytes)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 SNAT       tcp  --  *      *       172.18.1.0/24        
83.103.72.197       multiport dports 20,21 to:www-adsl
       0        0 SNAT       tcp  --  *      *       172.18.1.0/24        
193.221.113.0/24    multiport dports 554,1755 to:www-adsl
       0        0 SNAT       tcp  --  *      *       0.0.0.0/0            
151.9.17.169        multiport dports 20,21 to:mimosa
       0        0 SNAT       tcp  --  *      *       0.0.0.0/0            
213.26.116.140      multiport dports 20,21 to:mimosa
       0        0 SNAT       tcp  --  *      *       0.0.0.0/0            
81.112.114.154      multiport dports 20,21 to:mimosa
       0        0 SNAT       tcp  --  *      *       0.0.0.0/0            
212.131.138.194     multiport dports 20,21 to:mimosa
       0        0 SNAT       udp  --  *      eth0    mimosa         
!172.16.0.0/12       multiport dports 123 to:www-adsl
     129     7740 SNAT       tcp  --  *      eth0    mimosa         
!172.16.0.0/12       multiport dports 20,21,80,123,443,8000,81 to:www-adsl
     521    61401 ACCEPT     all  --  *      *       0.0.0.0/0            
0.0.0.0/0           policy match dir out pol ipsec
       0        0 SNAT       tcp  --  *      eth0    172.18.1.0/24        
0.0.0.0/0           multiport dports 
23,922,1494,1503,1720,3200,3299,3300,3389,5040,5631,5632,5900,8999,10000 
to:mimosa
       0        0 SNAT       tcp  --  *      eth0    172.18.1.0/24        
0.0.0.0/0           multiport dports 3201,6667,3390,22,1723 to:mimosa
       0        0 SNAT       udp  --  *      eth0    172.18.1.0/24        
0.0.0.0/0           multiport dports 500,1025,4500,5631,5632,10000 to:mimosa
       0        0 SNAT       all  --  *      eth0    172.18.1.0/24        
firenze-dmz.123       to:mimosa
       0        0 SNAT       tcp  --  *      eth0    172.18.1.194         
0.0.0.0/0           multiport dports 25,110 to:mimosa
       0        0 SNAT       tcp  --  *      eth0    172.18.1.190         
0.0.0.0/0           multiport dports 25,110 to:mimosa
       0        0 SNAT       tcp  --  *      eth0    172.18.1.204        
!172.16.0.0/12       tcp dpt:1863 to:mimosa
       0        0 SNAT       tcp  --  *      eth0    172.18.1.230        
!172.16.0.0/12       tcp dpt:1863 to:mimosa
       0        0 SNAT       tcp  --  *      eth0    172.18.1.232        
!172.16.0.0/12       tcp dpt:1863 to:mimosa
       0        0 SNAT       tcp  --  *      eth0    172.18.1.233        
!172.16.0.0/12       tcp dpt:1863 to:mimosa
     101     5410 SNAT       all  --  *      *       172.16.0.0/12        
10.0.0.0/8          to:172.29.128.1
       0        0 SNAT       all  --  *      *       napoli-phone/27     
10.0.0.0/8          to:172.29.128.1

Chain OUTPUT (policy ACCEPT 249 packets, 17046 bytes)
    pkts      bytes target     prot opt in     out     source               
destination

root@Mimosa:/etc/rc.d# iptables -vxnL -t mangle
Chain PREROUTING (policy ACCEPT 123652 packets, 46803472 bytes)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 MARK       tcp  --  *      *       172.18.1.0/24        
83.103.72.197       multiport dports 20,21 MARK set 0x1
       0        0 MARK       tcp  --  *      *       172.18.1.0/24        
193.221.113.0/24    multiport dports 554,1755 MARK set 0x1

Chain INPUT (policy ACCEPT 59131 packets, 15751259 bytes)
    pkts      bytes target     prot opt in     out     source               
destination

Chain FORWARD (policy ACCEPT 63794 packets, 30980927 bytes)
    pkts      bytes target     prot opt in     out     source               
destination

Chain OUTPUT (policy ACCEPT 49608 packets, 29946646 bytes)
    pkts      bytes target     prot opt in     out     source               
destination
       0        0 MARK       udp  --  *      *       0.0.0.0/0           
!172.16.0.0/12       multiport dports 123 MARK set 0x1
    4714   462744 MARK       tcp  --  *      *       0.0.0.0/0           
!172.16.0.0/12       multiport dports 20,21,80,123,443,8000,81 MARK set 0x1

Chain POSTROUTING (policy ACCEPT 106140 packets, 59828842 bytes)
    pkts      bytes target     prot opt in     out     source               
destination

root@Mimosa:/etc/rc.d# ip r s
151.25.90.31 dev eth0  scope link
mimosa-gateway dev eth0  scope link
www-adsl-net/29 dev eth0  proto kernel  scope link  src www-adsl
napoli-phone/27 via mimosa-gateway dev eth0
milano-dmz/27 dev eth1  scope link
172.22.1.0/24 via mimosa-gateway dev eth0  src 172.18.1.254
172.18.1.0/24 dev eth2  proto kernel  scope link  src 172.18.1.254
172.25.5.0/24 via mimosa-gateway dev eth0
172.25.1.0/24 via mimosa-gateway dev eth0
172.21.1.0/24 via mimosa-gateway dev eth0
172.17.1.0/24 via mimosa-gateway dev eth0
172.23.4.0/23 via mimosa-gateway dev eth0
172.23.2.0/23 via mimosa-gateway dev eth0
172.23.0.0/23 via mimosa-gateway dev eth0
172.16.0.0/23 via mimosa-gateway dev eth0
10.0.0.0/8 via mimosa-gateway dev eth0  src 172.29.128.1
127.0.0.0/8 dev lo  scope link
default via mimosa-gateway dev eth0  metric 1

This is also my .config

root@Mimosa:/usr/src/linux# cat .config
#
# Automatically generated make config: don't edit
# Linux kernel version: 2.6.16.9
# Wed Apr 19 15:51:04 2006
#
CONFIG_X86_32=y
CONFIG_SEMAPHORE_SLEEPERS=y
CONFIG_X86=y
CONFIG_MMU=y
CONFIG_GENERIC_ISA_DMA=y
CONFIG_GENERIC_IOMAP=y
CONFIG_ARCH_MAY_HAVE_PC_FDC=y
CONFIG_DMI=y

#
# Code maturity level options
#
# CONFIG_EXPERIMENTAL is not set
CONFIG_BROKEN_ON_SMP=y
CONFIG_INIT_ENV_ARG_LIMIT=32

#
# General setup
#
CONFIG_LOCALVERSION=""
# CONFIG_LOCALVERSION_AUTO is not set
CONFIG_SWAP=y
CONFIG_SYSVIPC=y
CONFIG_BSD_PROCESS_ACCT=y
# CONFIG_BSD_PROCESS_ACCT_V3 is not set
CONFIG_SYSCTL=y
# CONFIG_AUDIT is not set
# CONFIG_IKCONFIG is not set
CONFIG_INITRAMFS_SOURCE=""
CONFIG_UID16=y
CONFIG_VM86=y
# CONFIG_EMBEDDED is not set
CONFIG_KALLSYMS=y
# CONFIG_KALLSYMS_EXTRA_PASS is not set
CONFIG_HOTPLUG=y
CONFIG_PRINTK=y
CONFIG_BUG=y
CONFIG_ELF_CORE=y
CONFIG_BASE_FULL=y
CONFIG_FUTEX=y
CONFIG_EPOLL=y
CONFIG_SHMEM=y
CONFIG_CC_ALIGN_FUNCTIONS=0
CONFIG_CC_ALIGN_LABELS=0
CONFIG_CC_ALIGN_LOOPS=0
CONFIG_CC_ALIGN_JUMPS=0
CONFIG_SLAB=y
# CONFIG_TINY_SHMEM is not set
CONFIG_BASE_SMALL=0
# CONFIG_SLOB is not set

#
# Loadable module support
#
CONFIG_MODULES=y
CONFIG_MODULE_UNLOAD=y
CONFIG_OBSOLETE_MODPARM=y
# CONFIG_MODVERSIONS is not set
# CONFIG_MODULE_SRCVERSION_ALL is not set
# CONFIG_KMOD is not set

#
# Block layer
#
# CONFIG_LBD is not set

#
# IO Schedulers
#
CONFIG_IOSCHED_NOOP=y
# CONFIG_IOSCHED_AS is not set
CONFIG_IOSCHED_DEADLINE=y
# CONFIG_IOSCHED_CFQ is not set
# CONFIG_DEFAULT_AS is not set
CONFIG_DEFAULT_DEADLINE=y
# CONFIG_DEFAULT_CFQ is not set
# CONFIG_DEFAULT_NOOP is not set
CONFIG_DEFAULT_IOSCHED="deadline"

#
# Processor type and features
#
CONFIG_X86_PC=y
# CONFIG_X86_ELAN is not set
# CONFIG_X86_VOYAGER is not set
# CONFIG_X86_NUMAQ is not set
# CONFIG_X86_SUMMIT is not set
# CONFIG_X86_BIGSMP is not set
# CONFIG_X86_VISWS is not set
# CONFIG_X86_GENERICARCH is not set
# CONFIG_X86_ES7000 is not set
# CONFIG_M386 is not set
# CONFIG_M486 is not set
# CONFIG_M586 is not set
# CONFIG_M586TSC is not set
# CONFIG_M586MMX is not set
# CONFIG_M686 is not set
CONFIG_MPENTIUMII=y
# CONFIG_MPENTIUMIII is not set
# CONFIG_MPENTIUMM is not set
# CONFIG_MPENTIUM4 is not set
# CONFIG_MK6 is not set
# CONFIG_MK7 is not set
# CONFIG_MK8 is not set
# CONFIG_MCRUSOE is not set
# CONFIG_MEFFICEON is not set
# CONFIG_MWINCHIPC6 is not set
# CONFIG_MWINCHIP2 is not set
# CONFIG_MWINCHIP3D is not set
# CONFIG_MGEODEGX1 is not set
# CONFIG_MGEODE_LX is not set
# CONFIG_MCYRIXIII is not set
# CONFIG_MVIAC3_2 is not set
# CONFIG_X86_GENERIC is not set
CONFIG_X86_CMPXCHG=y
CONFIG_X86_XADD=y
CONFIG_X86_L1_CACHE_SHIFT=5
CONFIG_RWSEM_XCHGADD_ALGORITHM=y
CONFIG_GENERIC_CALIBRATE_DELAY=y
CONFIG_X86_WP_WORKS_OK=y
CONFIG_X86_INVLPG=y
CONFIG_X86_BSWAP=y
CONFIG_X86_POPAD_OK=y
CONFIG_X86_CMPXCHG64=y
CONFIG_X86_GOOD_APIC=y
CONFIG_X86_INTEL_USERCOPY=y
CONFIG_X86_USE_PPRO_CHECKSUM=y
CONFIG_X86_TSC=y
# CONFIG_HPET_TIMER is not set
# CONFIG_SMP is not set
CONFIG_PREEMPT_NONE=y
# CONFIG_PREEMPT_VOLUNTARY is not set
# CONFIG_PREEMPT is not set
CONFIG_X86_UP_APIC=y
CONFIG_X86_UP_IOAPIC=y
CONFIG_X86_LOCAL_APIC=y
CONFIG_X86_IO_APIC=y
# CONFIG_X86_MCE is not set
# CONFIG_TOSHIBA is not set
# CONFIG_I8K is not set
# CONFIG_X86_REBOOTFIXUPS is not set
# CONFIG_MICROCODE is not set
# CONFIG_X86_MSR is not set
# CONFIG_X86_CPUID is not set

#
# Firmware Drivers
#
# CONFIG_DELL_RBU is not set
# CONFIG_DCDBAS is not set
CONFIG_NOHIGHMEM=y
# CONFIG_HIGHMEM4G is not set
# CONFIG_HIGHMEM64G is not set
CONFIG_PAGE_OFFSET=0xC0000000
CONFIG_FLATMEM=y
CONFIG_FLAT_NODE_MEM_MAP=y
# CONFIG_SPARSEMEM_STATIC is not set
CONFIG_SPLIT_PTLOCK_CPUS=4
# CONFIG_MATH_EMULATION is not set
# CONFIG_MTRR is not set
CONFIG_SECCOMP=y
# CONFIG_HZ_100 is not set
CONFIG_HZ_250=y
# CONFIG_HZ_1000 is not set
CONFIG_HZ=250
CONFIG_PHYSICAL_START=0x100000
CONFIG_DOUBLEFAULT=y

#
# Power management options (ACPI, APM)
#
# CONFIG_PM is not set

#
# ACPI (Advanced Configuration and Power Interface) Support
#
# CONFIG_ACPI is not set

#
# CPU Frequency scaling
#
# CONFIG_CPU_FREQ is not set

#
# Bus options (PCI, PCMCIA, EISA, MCA, ISA)
#
CONFIG_PCI=y
# CONFIG_PCI_GOBIOS is not set
# CONFIG_PCI_GOMMCONFIG is not set
# CONFIG_PCI_GODIRECT is not set
CONFIG_PCI_GOANY=y
CONFIG_PCI_BIOS=y
CONFIG_PCI_DIRECT=y
# CONFIG_PCIEPORTBUS is not set
# CONFIG_PCI_MSI is not set
# CONFIG_PCI_LEGACY_PROC is not set
CONFIG_ISA_DMA_API=y
# CONFIG_ISA is not set
# CONFIG_MCA is not set
# CONFIG_SCx200 is not set

#
# PCCARD (PCMCIA/CardBus) support
#
# CONFIG_PCCARD is not set

#
# PCI Hotplug Support
#

#
# Executable file formats
#
CONFIG_BINFMT_ELF=y
# CONFIG_BINFMT_AOUT is not set
# CONFIG_BINFMT_MISC is not set

#
# Networking
#
CONFIG_NET=y

#
# Networking options
#
# CONFIG_NETDEBUG is not set
CONFIG_PACKET=y
# CONFIG_PACKET_MMAP is not set
CONFIG_UNIX=y
CONFIG_XFRM=y
CONFIG_XFRM_USER=y
CONFIG_NET_KEY=y
CONFIG_INET=y
# CONFIG_IP_MULTICAST is not set
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_ASK_IP_FIB_HASH=y
# CONFIG_IP_FIB_TRIE is not set
CONFIG_IP_FIB_HASH=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_FWMARK=y
CONFIG_IP_ROUTE_MULTIPATH=y
# CONFIG_IP_ROUTE_MULTIPATH_CACHED is not set
CONFIG_IP_ROUTE_VERBOSE=y
# CONFIG_IP_PNP is not set
# CONFIG_NET_IPIP is not set
# CONFIG_NET_IPGRE is not set
CONFIG_SYN_COOKIES=y
# CONFIG_INET_AH is not set
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_TUNNEL=y
CONFIG_INET_DIAG=y
CONFIG_INET_TCP_DIAG=y
# CONFIG_TCP_CONG_ADVANCED is not set
CONFIG_TCP_CONG_BIC=y

#
# IP: Virtual Server Configuration
#
# CONFIG_IP_VS is not set
# CONFIG_IPV6 is not set
CONFIG_NETFILTER=y
# CONFIG_NETFILTER_DEBUG is not set

#
# Core Netfilter Configuration
#
CONFIG_NETFILTER_NETLINK=m
CONFIG_NETFILTER_NETLINK_QUEUE=m
CONFIG_NETFILTER_NETLINK_LOG=m
CONFIG_NETFILTER_XTABLES=y
CONFIG_NETFILTER_XT_TARGET_CLASSIFY=y
CONFIG_NETFILTER_XT_TARGET_CONNMARK=y
CONFIG_NETFILTER_XT_TARGET_MARK=y
CONFIG_NETFILTER_XT_TARGET_NFQUEUE=y
CONFIG_NETFILTER_XT_TARGET_NOTRACK=y
CONFIG_NETFILTER_XT_MATCH_COMMENT=y
CONFIG_NETFILTER_XT_MATCH_CONNBYTES=y
CONFIG_NETFILTER_XT_MATCH_CONNMARK=y
CONFIG_NETFILTER_XT_MATCH_CONNTRACK=y
CONFIG_NETFILTER_XT_MATCH_DCCP=y
CONFIG_NETFILTER_XT_MATCH_HELPER=y
CONFIG_NETFILTER_XT_MATCH_LENGTH=y
CONFIG_NETFILTER_XT_MATCH_LIMIT=y
CONFIG_NETFILTER_XT_MATCH_MAC=y
CONFIG_NETFILTER_XT_MATCH_MARK=y
CONFIG_NETFILTER_XT_MATCH_PKTTYPE=y
CONFIG_NETFILTER_XT_MATCH_REALM=y
CONFIG_NETFILTER_XT_MATCH_SCTP=y
CONFIG_NETFILTER_XT_MATCH_STATE=y
CONFIG_NETFILTER_XT_MATCH_STRING=y
CONFIG_NETFILTER_XT_MATCH_TCPMSS=y

#
# IP: Netfilter Configuration
#
CONFIG_IP_NF_CONNTRACK=y
CONFIG_IP_NF_CT_ACCT=y
CONFIG_IP_NF_CONNTRACK_MARK=y
CONFIG_IP_NF_FTP=m
# CONFIG_IP_NF_IRC is not set
CONFIG_IP_NF_TFTP=m
# CONFIG_IP_NF_AMANDA is not set
CONFIG_IP_NF_PPTP=m
# CONFIG_IP_NF_QUEUE is not set
CONFIG_IP_NF_IPTABLES=y
CONFIG_IP_NF_MATCH_IPRANGE=y
CONFIG_IP_NF_MATCH_MULTIPORT=y
CONFIG_IP_NF_MATCH_TOS=y
# CONFIG_IP_NF_MATCH_RECENT is not set
CONFIG_IP_NF_MATCH_ECN=y
CONFIG_IP_NF_MATCH_DSCP=y
CONFIG_IP_NF_MATCH_AH_ESP=y
CONFIG_IP_NF_MATCH_TTL=y
CONFIG_IP_NF_MATCH_OWNER=y
CONFIG_IP_NF_MATCH_ADDRTYPE=y
CONFIG_IP_NF_MATCH_HASHLIMIT=y
CONFIG_IP_NF_MATCH_POLICY=y
CONFIG_IP_NF_FILTER=y
CONFIG_IP_NF_TARGET_REJECT=y
CONFIG_IP_NF_TARGET_LOG=y
# CONFIG_IP_NF_TARGET_ULOG is not set
CONFIG_IP_NF_TARGET_TCPMSS=y
CONFIG_IP_NF_NAT=y
CONFIG_IP_NF_NAT_NEEDED=y
CONFIG_IP_NF_TARGET_MASQUERADE=y
CONFIG_IP_NF_TARGET_REDIRECT=y
CONFIG_IP_NF_TARGET_NETMAP=y
CONFIG_IP_NF_TARGET_SAME=y
CONFIG_IP_NF_NAT_FTP=m
CONFIG_IP_NF_NAT_TFTP=m
CONFIG_IP_NF_NAT_PPTP=m
CONFIG_IP_NF_MANGLE=y
CONFIG_IP_NF_TARGET_TOS=y
CONFIG_IP_NF_TARGET_ECN=y
CONFIG_IP_NF_TARGET_DSCP=y
CONFIG_IP_NF_TARGET_TTL=y
CONFIG_IP_NF_RAW=y
CONFIG_IP_NF_ARPTABLES=m
CONFIG_IP_NF_ARPFILTER=m
CONFIG_IP_NF_ARP_MANGLE=m
# CONFIG_BRIDGE is not set
# CONFIG_VLAN_8021Q is not set
# CONFIG_DECNET is not set
# CONFIG_LLC2 is not set
# CONFIG_IPX is not set
# CONFIG_ATALK is not set

#
# QoS and/or fair queueing
#
# CONFIG_NET_SCHED is not set
CONFIG_NET_CLS_ROUTE=y

#
# Network testing
#
# CONFIG_NET_PKTGEN is not set
# CONFIG_HAMRADIO is not set
# CONFIG_IRDA is not set
# CONFIG_BT is not set
# CONFIG_IEEE80211 is not set

#
# Device Drivers
#

#
# Generic Driver Options
#
CONFIG_STANDALONE=y
# CONFIG_PREVENT_FIRMWARE_BUILD is not set
# CONFIG_FW_LOADER is not set

#
# Connector - unified userspace <-> kernelspace linker
#
# CONFIG_CONNECTOR is not set

#
# Memory Technology Devices (MTD)
#
# CONFIG_MTD is not set

#
# Parallel port support
#
# CONFIG_PARPORT is not set

#
# Plug and Play support
#

#
# Block devices
#
CONFIG_BLK_DEV_FD=m
# CONFIG_BLK_CPQ_DA is not set
# CONFIG_BLK_CPQ_CISS_DA is not set
# CONFIG_BLK_DEV_DAC960 is not set
# CONFIG_BLK_DEV_COW_COMMON is not set
# CONFIG_BLK_DEV_LOOP is not set
# CONFIG_BLK_DEV_NBD is not set
# CONFIG_BLK_DEV_SX8 is not set
# CONFIG_BLK_DEV_RAM is not set
CONFIG_BLK_DEV_RAM_COUNT=16
# CONFIG_CDROM_PKTCDVD is not set
# CONFIG_ATA_OVER_ETH is not set

#
# ATA/ATAPI/MFM/RLL support
#
CONFIG_IDE=y
CONFIG_BLK_DEV_IDE=y

#
# Please see Documentation/ide.txt for help/info on IDE drives
#
# CONFIG_BLK_DEV_IDE_SATA is not set
# CONFIG_BLK_DEV_HD_IDE is not set
CONFIG_BLK_DEV_IDEDISK=y
# CONFIG_IDEDISK_MULTI_MODE is not set
CONFIG_BLK_DEV_IDECD=m
# CONFIG_BLK_DEV_IDEFLOPPY is not set
# CONFIG_IDE_TASK_IOCTL is not set

#
# IDE chipset support/bugfixes
#
# CONFIG_IDE_GENERIC is not set
# CONFIG_BLK_DEV_CMD640 is not set
CONFIG_BLK_DEV_IDEPCI=y
CONFIG_IDEPCI_SHARE_IRQ=y
# CONFIG_BLK_DEV_OFFBOARD is not set
# CONFIG_BLK_DEV_GENERIC is not set
# CONFIG_BLK_DEV_RZ1000 is not set
CONFIG_BLK_DEV_IDEDMA_PCI=y
# CONFIG_BLK_DEV_IDEDMA_FORCED is not set
CONFIG_IDEDMA_PCI_AUTO=y
CONFIG_IDEDMA_ONLYDISK=y
# CONFIG_BLK_DEV_AEC62XX is not set
# CONFIG_BLK_DEV_ALI15X3 is not set
# CONFIG_BLK_DEV_AMD74XX is not set
# CONFIG_BLK_DEV_ATIIXP is not set
# CONFIG_BLK_DEV_CMD64X is not set
# CONFIG_BLK_DEV_TRIFLEX is not set
# CONFIG_BLK_DEV_CY82C693 is not set
# CONFIG_BLK_DEV_CS5530 is not set
# CONFIG_BLK_DEV_CS5535 is not set
# CONFIG_BLK_DEV_HPT34X is not set
# CONFIG_BLK_DEV_HPT366 is not set
# CONFIG_BLK_DEV_SC1200 is not set
CONFIG_BLK_DEV_PIIX=y
# CONFIG_BLK_DEV_IT821X is not set
# CONFIG_BLK_DEV_NS87415 is not set
# CONFIG_BLK_DEV_PDC202XX_OLD is not set
# CONFIG_BLK_DEV_PDC202XX_NEW is not set
# CONFIG_BLK_DEV_SVWKS is not set
# CONFIG_BLK_DEV_SIIMAGE is not set
# CONFIG_BLK_DEV_SIS5513 is not set
# CONFIG_BLK_DEV_SLC90E66 is not set
# CONFIG_BLK_DEV_TRM290 is not set
# CONFIG_BLK_DEV_VIA82CXXX is not set
# CONFIG_IDE_ARM is not set
CONFIG_BLK_DEV_IDEDMA=y
# CONFIG_IDEDMA_IVB is not set
CONFIG_IDEDMA_AUTO=y
# CONFIG_BLK_DEV_HD is not set

#
# SCSI device support
#
# CONFIG_RAID_ATTRS is not set
# CONFIG_SCSI is not set

#
# Multi-device support (RAID and LVM)
#
# CONFIG_MD is not set

#
# Fusion MPT device support
#
# CONFIG_FUSION is not set

#
# IEEE 1394 (FireWire) support
#
# CONFIG_IEEE1394 is not set

#
# I2O device support
#
# CONFIG_I2O is not set

#
# Network device support
#
CONFIG_NETDEVICES=y
CONFIG_DUMMY=m
# CONFIG_BONDING is not set
# CONFIG_EQUALIZER is not set
# CONFIG_TUN is not set

#
# ARCnet devices
#
# CONFIG_ARCNET is not set

#
# PHY device support
#
# CONFIG_PHYLIB is not set

#
# Ethernet (10 or 100Mbit)
#
CONFIG_NET_ETHERNET=y
CONFIG_MII=m
# CONFIG_HAPPYMEAL is not set
# CONFIG_SUNGEM is not set
# CONFIG_CASSINI is not set
CONFIG_NET_VENDOR_3COM=y
CONFIG_VORTEX=m
CONFIG_TYPHOON=m

#
# Tulip family network device support
#
# CONFIG_NET_TULIP is not set
# CONFIG_HP100 is not set
CONFIG_NET_PCI=y
# CONFIG_PCNET32 is not set
# CONFIG_AMD8111_ETH is not set
# CONFIG_ADAPTEC_STARFIRE is not set
# CONFIG_DGRS is not set
CONFIG_EEPRO100=m
CONFIG_E100=m
# CONFIG_FEALNX is not set
# CONFIG_NATSEMI is not set
# CONFIG_NE2K_PCI is not set
# CONFIG_8139TOO is not set
# CONFIG_SIS900 is not set
# CONFIG_EPIC100 is not set
# CONFIG_SUNDANCE is not set
# CONFIG_TLAN is not set
# CONFIG_VIA_RHINE is not set

#
# Ethernet (1000 Mbit)
#
# CONFIG_ACENIC is not set
# CONFIG_DL2K is not set
# CONFIG_E1000 is not set
# CONFIG_NS83820 is not set
# CONFIG_HAMACHI is not set
# CONFIG_R8169 is not set
# CONFIG_SIS190 is not set
# CONFIG_SKGE is not set
# CONFIG_SK98LIN is not set
# CONFIG_VIA_VELOCITY is not set
# CONFIG_TIGON3 is not set
# CONFIG_BNX2 is not set

#
# Ethernet (10000 Mbit)
#
# CONFIG_CHELSIO_T1 is not set
# CONFIG_IXGB is not set
# CONFIG_S2IO is not set

#
# Token Ring devices
#
# CONFIG_TR is not set

#
# Wireless LAN (non-hamradio)
#
# CONFIG_NET_RADIO is not set

#
# Wan interfaces
#
# CONFIG_WAN is not set
# CONFIG_FDDI is not set
# CONFIG_PPP is not set
# CONFIG_SLIP is not set
# CONFIG_NETPOLL is not set
# CONFIG_NET_POLL_CONTROLLER is not set

#
# ISDN subsystem
#
# CONFIG_ISDN is not set

#
# Telephony Support
#
# CONFIG_PHONE is not set

#
# Input device support
#
CONFIG_INPUT=y

#
# Userland interfaces
#
CONFIG_INPUT_MOUSEDEV=y
# CONFIG_INPUT_MOUSEDEV_PSAUX is not set
CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024
CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768
# CONFIG_INPUT_JOYDEV is not set
# CONFIG_INPUT_TSDEV is not set
# CONFIG_INPUT_EVDEV is not set
# CONFIG_INPUT_EVBUG is not set

#
# Input Device Drivers
#
CONFIG_INPUT_KEYBOARD=y
CONFIG_KEYBOARD_ATKBD=y
# CONFIG_KEYBOARD_SUNKBD is not set
# CONFIG_KEYBOARD_LKKBD is not set
# CONFIG_KEYBOARD_XTKBD is not set
# CONFIG_KEYBOARD_NEWTON is not set
# CONFIG_INPUT_MOUSE is not set
# CONFIG_INPUT_JOYSTICK is not set
# CONFIG_INPUT_TOUCHSCREEN is not set
# CONFIG_INPUT_MISC is not set

#
# Hardware I/O ports
#
CONFIG_SERIO=y
CONFIG_SERIO_I8042=y
# CONFIG_SERIO_SERPORT is not set
# CONFIG_SERIO_CT82C710 is not set
# CONFIG_SERIO_PCIPS2 is not set
CONFIG_SERIO_LIBPS2=y
# CONFIG_SERIO_RAW is not set
# CONFIG_GAMEPORT is not set

#
# Character devices
#
CONFIG_VT=y
CONFIG_VT_CONSOLE=y
CONFIG_HW_CONSOLE=y
# CONFIG_SERIAL_NONSTANDARD is not set

#
# Serial drivers
#
# CONFIG_SERIAL_8250 is not set

#
# Non-8250 serial port support
#
# CONFIG_SERIAL_JSM is not set
CONFIG_UNIX98_PTYS=y
# CONFIG_LEGACY_PTYS is not set

#
# IPMI
#
# CONFIG_IPMI_HANDLER is not set

#
# Watchdog Cards
#
# CONFIG_WATCHDOG is not set
# CONFIG_HW_RANDOM is not set
# CONFIG_NVRAM is not set
# CONFIG_RTC is not set
# CONFIG_GEN_RTC is not set
# CONFIG_DTLK is not set
# CONFIG_R3964 is not set
# CONFIG_APPLICOM is not set

#
# Ftape, the floppy tape device driver
#
# CONFIG_FTAPE is not set
# CONFIG_AGP is not set
# CONFIG_DRM is not set
# CONFIG_MWAVE is not set
# CONFIG_CS5535_GPIO is not set
# CONFIG_RAW_DRIVER is not set
# CONFIG_HANGCHECK_TIMER is not set

#
# TPM devices
#

#
# I2C support
#
# CONFIG_I2C is not set

#
# SPI support
#
# CONFIG_SPI is not set
# CONFIG_SPI_MASTER is not set

#
# Dallas's 1-wire bus
#
# CONFIG_W1 is not set

#
# Hardware Monitoring support
#
# CONFIG_HWMON is not set
# CONFIG_HWMON_VID is not set

#
# Misc devices
#

#
# Multimedia Capabilities Port drivers
#

#
# Multimedia devices
#
# CONFIG_VIDEO_DEV is not set

#
# Digital Video Broadcasting Devices
#
# CONFIG_DVB is not set

#
# Graphics support
#
# CONFIG_FB is not set
# CONFIG_VIDEO_SELECT is not set

#
# Console display driver support
#
CONFIG_VGA_CONSOLE=y
CONFIG_DUMMY_CONSOLE=y

#
# Sound
#
# CONFIG_SOUND is not set

#
# USB support
#
CONFIG_USB_ARCH_HAS_HCD=y
CONFIG_USB_ARCH_HAS_OHCI=y
# CONFIG_USB is not set

#
# NOTE: USB_STORAGE enables SCSI, and 'SCSI disk support'
#

#
# USB Gadget Support
#
# CONFIG_USB_GADGET is not set

#
# MMC/SD Card support
#
# CONFIG_MMC is not set

#
# InfiniBand support
#
# CONFIG_INFINIBAND is not set

#
# EDAC - error detection and reporting (RAS) (EXPERIMENTAL)
#

#
# File systems
#
CONFIG_EXT2_FS=m
# CONFIG_EXT2_FS_XATTR is not set
# CONFIG_EXT2_FS_XIP is not set
# CONFIG_EXT3_FS is not set
# CONFIG_REISERFS_FS is not set
# CONFIG_JFS_FS is not set
# CONFIG_FS_POSIX_ACL is not set
CONFIG_XFS_FS=y
# CONFIG_XFS_QUOTA is not set
# CONFIG_XFS_SECURITY is not set
# CONFIG_XFS_POSIX_ACL is not set
# CONFIG_MINIX_FS is not set
# CONFIG_ROMFS_FS is not set
CONFIG_INOTIFY=y
# CONFIG_QUOTA is not set
CONFIG_DNOTIFY=y
# CONFIG_AUTOFS_FS is not set
# CONFIG_AUTOFS4_FS is not set
# CONFIG_FUSE_FS is not set

#
# CD-ROM/DVD Filesystems
#
CONFIG_ISO9660_FS=m
CONFIG_JOLIET=y
# CONFIG_ZISOFS is not set
# CONFIG_UDF_FS is not set

#
# DOS/FAT/NT Filesystems
#
CONFIG_FAT_FS=m
CONFIG_MSDOS_FS=m
CONFIG_VFAT_FS=m
CONFIG_FAT_DEFAULT_CODEPAGE=437
CONFIG_FAT_DEFAULT_IOCHARSET="iso8859-1"
# CONFIG_NTFS_FS is not set

#
# Pseudo filesystems
#
CONFIG_PROC_FS=y
CONFIG_PROC_KCORE=y
CONFIG_SYSFS=y
# CONFIG_TMPFS is not set
# CONFIG_HUGETLBFS is not set
# CONFIG_HUGETLB_PAGE is not set
CONFIG_RAMFS=y
# CONFIG_RELAYFS_FS is not set

#
# Miscellaneous filesystems
#
# CONFIG_HFSPLUS_FS is not set
# CONFIG_CRAMFS is not set
# CONFIG_VXFS_FS is not set
# CONFIG_HPFS_FS is not set
# CONFIG_QNX4FS_FS is not set
# CONFIG_SYSV_FS is not set
# CONFIG_UFS_FS is not set

#
# Network File Systems
#
# CONFIG_NFS_FS is not set
# CONFIG_NFSD is not set
# CONFIG_SMB_FS is not set
# CONFIG_CIFS is not set
# CONFIG_NCP_FS is not set
# CONFIG_CODA_FS is not set

#
# Partition Types
#
# CONFIG_PARTITION_ADVANCED is not set
CONFIG_MSDOS_PARTITION=y

#
# Native Language Support
#
CONFIG_NLS=m
CONFIG_NLS_DEFAULT="iso8859-1"
CONFIG_NLS_CODEPAGE_437=m
# CONFIG_NLS_CODEPAGE_737 is not set
# CONFIG_NLS_CODEPAGE_775 is not set
CONFIG_NLS_CODEPAGE_850=m
# CONFIG_NLS_CODEPAGE_852 is not set
# CONFIG_NLS_CODEPAGE_855 is not set
# CONFIG_NLS_CODEPAGE_857 is not set
# CONFIG_NLS_CODEPAGE_860 is not set
# CONFIG_NLS_CODEPAGE_861 is not set
# CONFIG_NLS_CODEPAGE_862 is not set
# CONFIG_NLS_CODEPAGE_863 is not set
# CONFIG_NLS_CODEPAGE_864 is not set
# CONFIG_NLS_CODEPAGE_865 is not set
# CONFIG_NLS_CODEPAGE_866 is not set
# CONFIG_NLS_CODEPAGE_869 is not set
# CONFIG_NLS_CODEPAGE_936 is not set
# CONFIG_NLS_CODEPAGE_950 is not set
# CONFIG_NLS_CODEPAGE_932 is not set
# CONFIG_NLS_CODEPAGE_949 is not set
# CONFIG_NLS_CODEPAGE_874 is not set
# CONFIG_NLS_ISO8859_8 is not set
# CONFIG_NLS_CODEPAGE_1250 is not set
# CONFIG_NLS_CODEPAGE_1251 is not set
# CONFIG_NLS_ASCII is not set
CONFIG_NLS_ISO8859_1=m
# CONFIG_NLS_ISO8859_2 is not set
# CONFIG_NLS_ISO8859_3 is not set
# CONFIG_NLS_ISO8859_4 is not set
# CONFIG_NLS_ISO8859_5 is not set
# CONFIG_NLS_ISO8859_6 is not set
# CONFIG_NLS_ISO8859_7 is not set
# CONFIG_NLS_ISO8859_9 is not set
# CONFIG_NLS_ISO8859_13 is not set
# CONFIG_NLS_ISO8859_14 is not set
CONFIG_NLS_ISO8859_15=m
# CONFIG_NLS_KOI8_R is not set
# CONFIG_NLS_KOI8_U is not set
# CONFIG_NLS_UTF8 is not set

#
# Kernel hacking
#
# CONFIG_PRINTK_TIME is not set
# CONFIG_MAGIC_SYSRQ is not set
# CONFIG_DEBUG_KERNEL is not set
CONFIG_LOG_BUF_SHIFT=14
CONFIG_DEBUG_BUGVERBOSE=y
CONFIG_EARLY_PRINTK=y
CONFIG_X86_FIND_SMP_CONFIG=y
CONFIG_X86_MPPARSE=y

#
# Security options
#
# CONFIG_KEYS is not set
# CONFIG_SECURITY is not set

#
# Cryptographic options
#
CONFIG_CRYPTO=y
CONFIG_CRYPTO_HMAC=y
# CONFIG_CRYPTO_NULL is not set
# CONFIG_CRYPTO_MD4 is not set
CONFIG_CRYPTO_MD5=y
CONFIG_CRYPTO_SHA1=y
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
# CONFIG_CRYPTO_WP512 is not set
# CONFIG_CRYPTO_TGR192 is not set
CONFIG_CRYPTO_DES=y
CONFIG_CRYPTO_BLOWFISH=m
CONFIG_CRYPTO_TWOFISH=m
CONFIG_CRYPTO_SERPENT=m
# CONFIG_CRYPTO_AES is not set
CONFIG_CRYPTO_AES_586=y
# CONFIG_CRYPTO_CAST5 is not set
# CONFIG_CRYPTO_CAST6 is not set
# CONFIG_CRYPTO_TEA is not set
# CONFIG_CRYPTO_ARC4 is not set
# CONFIG_CRYPTO_KHAZAD is not set
# CONFIG_CRYPTO_ANUBIS is not set
CONFIG_CRYPTO_DEFLATE=y
# CONFIG_CRYPTO_MICHAEL_MIC is not set
# CONFIG_CRYPTO_CRC32C is not set
# CONFIG_CRYPTO_TEST is not set

#
# Hardware crypto devices
#
# CONFIG_CRYPTO_DEV_PADLOCK is not set

#
# Library routines
#
CONFIG_CRC_CCITT=m
CONFIG_CRC16=m
CONFIG_CRC32=m
CONFIG_LIBCRC32C=m
CONFIG_ZLIB_INFLATE=y
CONFIG_ZLIB_DEFLATE=y
CONFIG_TEXTSEARCH=y
CONFIG_TEXTSEARCH_KMP=y
CONFIG_TEXTSEARCH_BM=y
CONFIG_TEXTSEARCH_FSM=y
CONFIG_GENERIC_HARDIRQS=y
CONFIG_GENERIC_IRQ_PROBE=y
CONFIG_X86_BIOS_REBOOT=y
CONFIG_KTIME_SCALAR=y


