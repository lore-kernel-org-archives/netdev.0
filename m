From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3151] New: IPSEC triggers "bad: scheduling
 while atomic!" errors.
Date: Tue, 3 Aug 2004 22:43:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040803224319.50363100.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Looks like a lock/unlock imbalance somewhere in the 2.6.7 ipsec code.


Begin forwarded message:

Date: Tue, 3 Aug 2004 13:43:57 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3151] New: IPSEC triggers "bad: scheduling while atomic!" errors.


http://bugme.osdl.org/show_bug.cgi?id=3151

           Summary: IPSEC triggers "bad: scheduling while atomic!" errors.
    Kernel Version: 2.6.6 & 2.6.7, earlier kernels untested.
            Status: NEW
          Severity: normal
             Owner: niv@us.ibm.com
         Submitter: johan.karlberg@gmail.com


Distribution: Debian unstable and testing.
Hardware Environment: K6-2 400, K6 233

Linux version 2.6.7 (root@scooby) (gcc version 3.3.4 (Debian 1:3.3.4-6)) #2 Sun
Aug 1 21:13:50 CEST 2004
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000000fffc000 (usable)
 BIOS-e820: 000000000fffc000 - 000000000ffff000 (ACPI data)
 BIOS-e820: 000000000ffff000 - 0000000010000000 (ACPI NVS)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
255MB LOWMEM available.
On node 0 totalpages: 65532
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 61436 pages, LIFO batch:14
  HighMem zone: 0 pages, LIFO batch:1
DMI 2.0 present.
Built 1 zonelists
Kernel command line: auto BOOT_IMAGE=Linux ro root=302 acpi=off
No local APIC present or hardware disabled
Initializing CPU#0
PID hash table entries: 1024 (order 10: 8192 bytes)
Detected 400.859 MHz processor.
Using tsc for high-res timesource
Console: colour VGA+ 80x25
Memory: 256672k/262128k available (1446k kernel code, 4732k reserved, 757k data,
208k init, 0k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay loop... 792.57 BogoMIPS
Security Scaffold v1.0.0 initialized
Dentry cache hash table entries: 32768 (order: 5, 131072 bytes)
Inode-cache hash table entries: 16384 (order: 4, 65536 bytes)
Mount-cache hash table entries: 512 (order: 0, 4096 bytes)
CPU:     After generic identify, caps: 008021bf 808029bf 00000000 00000000
CPU:     After vendor identify, caps: 008021bf 808029bf 00000000 00000000
CPU: L1 I Cache: 32K (32 bytes/line), D cache 32K (32 bytes/line)
CPU:     After all inits, caps: 008021bf 808029bf 00000000 00000002
CPU: AMD-K6(tm) 3D processor stepping 0c
Checking 'hlt' instruction... OK.
Checking for popad bug... OK.
NET: Registered protocol family 16
EISA bus registered
PCI: PCI BIOS revision 2.10 entry at 0xf0720, last bus=1
PCI: Using configuration type 1
mtrr: v2.0 (20020519)
ACPI: Subsystem revision 20040326
ACPI: Interpreter disabled.
Linux Plug and Play Support v0.97 (c) Adam Belay
PnPBIOS: Scanning system for PnP BIOS support...
PnPBIOS: Found PnP BIOS installation structure at 0xc00fd220
PnPBIOS: PnP BIOS version 1.0, entry 0xf0000:0xd250, dseg 0xf0000
PnPBIOS: Resource structure does not contain an end tag.
PnPBIOS: build_devlist: Node number 0x0 is out of sequence following node 0x0.
Aborting.
PnPBIOS: 1 node reported by PnP BIOS; 1 recorded by driver
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI: Using ALI IRQ Router
PCI: Using IRQ router ALI [10b9/1533] at 0000:00:07.0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
devfs: 2004-01-31 Richard Gooch (rgooch@atnf.csiro.au)
devfs: boot_options: 0x0
Initializing Cryptographic API
Activating ISA DMA hang workarounds.
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
Serial: 8250/16550 driver $Revision: 1.90 $ 54 ports, IRQ sharing enabled
RAMDISK driver initialized: 16 RAM disks of 8192K size 1024 blocksize
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
ALI15X3: IDE controller at PCI slot 0000:00:0f.0
ALI15X3: chipset revision 193
ALI15X3: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xd400-0xd407, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0xd408-0xd40f, BIOS settings: hdc:pio, hdd:pio
hda: ST360021A, ATA DISK drive
hdb: ST380021A, ATA DISK drive
Using anticipatory io scheduler
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
hdc: ST3120023A, ATA DISK drive
hdd: ST3120024A, ATA DISK drive
ide1 at 0x170-0x177,0x376 on irq 15
hda: max request size: 128KiB
hda: 117231408 sectors (60022 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(33)
 /dev/ide/host0/bus0/target0/lun0: p1 p2 p3 p4
hdb: max request size: 128KiB
hdb: 156301488 sectors (80026 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(33)
 /dev/ide/host0/bus0/target1/lun0: p1
hdc: max request size: 128KiB
hdc: 234441648 sectors (120034 MB) w/2048KiB Cache, CHS=65535/16/63, UDMA(33)
 /dev/ide/host0/bus1/target0/lun0: p1
hdd: max request size: 128KiB
hdd: 234441648 sectors (120034 MB) w/8192KiB Cache, CHS=65535/16/63, UDMA(33)
 /dev/ide/host0/bus1/target1/lun0: p1
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
input: AT Translated Set 2 keyboard on isa0060/serio0
EISA: Probing bus 0 at eisa0
NET: Registered protocol family 2
IP: routing cache hash table of 2048 buckets, 16Kbytes
TCP: Hash tables configured (established 16384 bind 32768)
NET: Registered protocol family 8
NET: Registered protocol family 20
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
VFS: Mounted root (ext3 filesystem) readonly.
Freeing unused kernel memory: 208k freed
NET: Registered protocol family 1
Adding 996020k swap on /dev/hda4.  Priority:-1 extents:1
EXT3 FS on hda2, internal journal
Real Time Clock Driver v1.12
device-mapper: 4.1.0-ioctl (2003-12-10) initialised: dm@uk.sistina.com
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hda3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hdb1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hdc1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on hdd1, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Linux agpgart interface v0.100 (c) Dave Jones
agpgart: Detected ALi M1541 chipset
agpgart: Maximum main memory to use for agp memory: 203M
agpgart: AGP aperture is 64M @ 0xe0000000
cpci_hotplug: CompactPCI Hot Plug Core version: 0.2
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
pciehp: acpi_pciehprm:get_device PCI ROOT HID fail=0x1001
shpchp: acpi_shpchprm:get_device PCI ROOT HID fail=0x1001
PCI: Found IRQ 10 for device 0000:00:0d.0
3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
0000:00:0d.0: 3Com PCI 3c905 Boomerang 100baseTx at 0xd800. Vers LK1.1.19
PCI: Setting latency timer of device 0000:00:0d.0 to 64
eth0: Dropping NETIF_F_SG since no checksum feature.
usbcore: registered new driver usbfs
usbcore: registered new driver hub
ohci_hcd: 2004 Feb 02 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
ohci_hcd: block sizes: ed 64 td 64
USB Universal Host Controller Interface driver v2.2
ttyS0: LSR safety check engaged!
ttyS0: LSR safety check engaged!
ttyS1: LSR safety check engaged!
ttyS1: LSR safety check engaged!
NET: Registered protocol family 10
Disabled Privacy Extensions on device c02f0580(lo)
IPv6 over IPv4 tunneling driver

processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 5
model           : 8
model name      : AMD-K6(tm) 3D processor
stepping        : 12
cpu MHz         : 400.859
cache size      : 64 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr mce cx8 pge mmx syscall 3dnow k6_mtrr
bogomips        : 792.57

Software Environment:

options.l2tp.lns:

ipcp-accept-local
ipcp-accept-remote
ms-dns  192.168.0.1
#ms-wins 10.1.96.3
auth
crtscts
idle 1800
mtu 1400
mru 1400
defaultroute
nodetach 
debug
lock
proxyarp
connect-delay 5000

racoon.conf:

#
# Simple racoon.conf
# 
#
# Please look in /usr/share/doc/racoon/examples for
# the example that comes with the source.
#
# Please read racoon.conf(5) for details, and also
# read setkey(8).
#
# Also read the Linux IPSEC Howto up at 
# http://www.ipsec-howto.org/t1.html 
#

path pre_shared_key "/etc/racoon/psk.txt";
path certificate "/etc/racoon/certs";

log debug2;

listen {
        isakmp 192.168.0.2;
        strict_address;
}

remote anonymous {
        exchange_mode main;
        doi ipsec_doi;
        situation identity_only;
        generate_policy on;
 
	verify_cert off;

        my_identifier asn1dn;
        peers_identifier asn1dn;
        verify_identifier on;
        certificate_type x509 "scooby_cert.pem" "scooby_key.pem";
 
        proposal {
                encryption_algorithm 3des;
                hash_algorithm sha1;
                authentication_method rsasig;
                dh_group modp1024;
        }
}

sainfo anonymous {
        lifetime time 28800 sec;
        encryption_algorithm 3des ;
        authentication_algorithm hmac_md5;
        compression_algorithm deflate ;
}

portion of syslog preceeding the problem, and including the first of the error
message. messages and trace seems to be identical and repeating indefinitly.:

Aug  3 21:55:43 scooby pppd[3975]: sent [LCP EchoReq id=0x70 magic=0x3e763ee9]
Aug  3 21:55:43 scooby pppd[3975]: rcvd [LCP EchoRep id=0x70 magic=0x8da75c9]
Aug  3 21:56:13 scooby pppd[3975]: sent [LCP EchoReq id=0x71 magic=0x3e763ee9]
Aug  3 21:56:13 scooby pppd[3975]: rcvd [LCP EchoRep id=0x71 magic=0x8da75c9]
Aug  3 21:56:41 scooby l2tpd[1194]: check_control: control, cid = 0, Ns = 4, Nr
= 59 
Aug  3 21:56:43 scooby pppd[3975]: sent [LCP EchoReq id=0x72 magic=0x3e763ee9]
Aug  3 21:56:43 scooby pppd[3975]: rcvd [LCP EchoRep id=0x72 magic=0x8da75c9]
Aug  3 21:57:13 scooby pppd[3975]: sent [LCP EchoReq id=0x73 magic=0x3e763ee9]
Aug  3 21:57:13 scooby pppd[3975]: rcvd [LCP EchoRep id=0x73 magic=0x8da75c9]
Aug  3 21:57:41 scooby l2tpd[1194]: check_control: control, cid = 0, Ns = 4, Nr
= 60 
Aug  3 21:57:43 scooby pppd[3975]: sent [LCP EchoReq id=0x74 magic=0x3e763ee9]
Aug  3 21:57:43 scooby pppd[3975]: rcvd [LCP EchoRep id=0x74 magic=0x8da75c9]
Aug  3 21:58:13 scooby pppd[3975]: sent [LCP EchoReq id=0x75 magic=0x3e763ee9]
Aug  3 21:58:13 scooby pppd[3975]: rcvd [LCP EchoRep id=0x75 magic=0x8da75c9]
Aug  3 21:58:41 scooby l2tpd[1194]: check_control: control, cid = 0, Ns = 4, Nr
= 61 
Aug  3 21:58:43 scooby pppd[3975]: sent [LCP EchoReq id=0x76 magic=0x3e763ee9]
Aug  3 21:58:43 scooby pppd[3975]: rcvd [LCP EchoRep id=0x76 magic=0x8da75c9]
Aug  3 21:59:13 scooby pppd[3975]: sent [LCP EchoReq id=0x77 magic=0x3e763ee9]
Aug  3 21:59:13 scooby racoon: DEBUG: === 
Aug  3 21:59:13 scooby racoon: DEBUG: 1116 bytes message received from
192.168.0.100[500] to 192.168.0.2[500] 
Aug  3 21:59:13 scooby racoon: DEBUG:  e439faa2 df4fcd2d 6f7069be 243c45c7
08102001 d48272e2 0000045c 7bbec0a2 280a7f91 c7d45818 29e7efa1 f5edb562 25e2d94d
035809d3 531a5dc4 a5788256 1fa9bd30 4caa0e06 4da593f9 b8cfa9f4 571ee579 40682f9c
fd676bbf 694c63a1 16e55cb6 64d6d491 1080f6fd 7ac0103f ce9dd9c1 27838b58 4a77ee04
e1ebd209 b386c792 9f5a405c 324ade2f ea9361b5 5e59c63b 7a835a2a 3e43860d 905d6c7e
f59bbb9b 3926967b d153ffc2 e8f44a48 60dc16fa f1082e22 2f8f1e84 027a387d 16657978
147f3e76 e3c7cf5e 23265899 d7f7d43b 8f44ca43 7e451d4c 4f7f81fe 26aa518f 7f60b88f
2aecd19a 24fd9724 1a88c259 0497c0a7 bbf50cd5 1608ae47 fcdfe38e eb80c706 271664fc
07e43e47 2efde0d2 231359bf 7a924935 c0022be9 90824d55 fea279bc 14957031 db26a92e
bfe71395 59ce5d44 37c13bbb dbec384d 06cb9741 3eed1116 ce582060 48360835 5ff9b961
a1db5978 bbc0649a 62241d36 f53ba9b9 23217d0f 6f4aea50 b4fccec2 da4da175 b75dbd8f
f5dd5ba3 700869be a8c49a5d dc7452c6 9952c1d4 7605a19b 940ecd50 d217d398 4673a9af
7e70f403 90c743bc ee2754b2 2a6cc5b4 fd809cb1 ab569fce 14fe1
Aug  3 21:59:13 scooby racoon: DEBUG: compute IV for phase2 
Aug  3 21:59:13 scooby racoon: DEBUG: phase1 last IV: 
Aug  3 21:59:13 scooby racoon: DEBUG:  d589b86f 956f2b07 d48272e2 
Aug  3 21:59:13 scooby racoon: DEBUG: hash(sha1) 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: phase2 IV computed: 
Aug  3 21:59:13 scooby racoon: DEBUG:  c975fe48 1f39bbb6 
Aug  3 21:59:13 scooby racoon: DEBUG: === 
Aug  3 21:59:13 scooby racoon: INFO: respond new phase 2 negotiation:
192.168.0.2[0]<=>192.168.0.100[0] 
Aug  3 21:59:13 scooby racoon: DEBUG: begin decryption. 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: IV was saved for next processing: 
Aug  3 21:59:13 scooby racoon: DEBUG:  fb5332b8 6d9c5cbf 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: with key: 
Aug  3 21:59:13 scooby racoon: DEBUG:  e0814bd6 704b9d63 54bf6496 64f8abdb
b5e41d57 e08d61d9 
Aug  3 21:59:13 scooby racoon: DEBUG: decrypted payload by IV: 
Aug  3 21:59:13 scooby racoon: DEBUG:  fb5332b8 6d9c5cbf 
Aug  3 21:59:13 scooby racoon: DEBUG: decrypted payload, but not trimed. 
Aug  3 21:59:13 scooby racoon: DEBUG:  01000018 416fc129 f6e56e35 38696b7f
077c02b3 99fb3621 0a0003f4 00000001 00000001 0200005c 01030402 c072ec18 03000028
01030000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002 80050001
00000028 02030000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002
80050002 02000034 02020401 c072ec18 00000028 01030000 80010001 00020004 00000e10
80010002 00020004 0003d090 80040002 80050002 02000030 02030401 7fc0da59 00000024
01030000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002 02000034
03020401 c072ec18 00000028 01020000 80010001 00020004 00000e10 80010002 00020004
0003d090 80040002 80050001 02000030 03030401 7fc0da59 00000024 01030000 80010001
00020004 00000e10 80010002 00020004 0003d090 80040002 02000034 04020401 c072ec18
00000028 01030000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002
80050002 02000034 04030401 7fc0da59 00000028 01030000 80010001 00020004 00000e10
80010002 00020004 0003d090 80040002 80050002 02000034 05020
Aug  3 21:59:13 scooby racoon: DEBUG: padding len=1 
Aug  3 21:59:13 scooby racoon: DEBUG: skip to trim padding. 
Aug  3 21:59:13 scooby racoon: DEBUG: decrypted. 
Aug  3 21:59:13 scooby pppd[3975]: rcvd [LCP EchoRep id=0x77 magic=0x8da75c9]
Aug  3 21:59:13 scooby racoon: DEBUG:  e439faa2 df4fcd2d 6f7069be 243c45c7
08102001 d48272e2 0000045c 01000018 416fc129 f6e56e35 38696b7f 077c02b3 99fb3621
0a0003f4 00000001 00000001 0200005c 01030402 c072ec18 03000028 01030000 80010001
00020004 00000e10 80010002 00020004 0003d090 80040002 80050001 00000028 02030000
80010001 00020004 00000e10 80010002 00020004 0003d090 80040002 80050002 02000034
02020401 c072ec18 00000028 01030000 80010001 00020004 00000e10 80010002 00020004
0003d090 80040002 80050002 02000030 02030401 7fc0da59 00000024 01030000 80010001
00020004 00000e10 80010002 00020004 0003d090 80040002 02000034 03020401 c072ec18
00000028 01020000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002
80050001 02000030 03030401 7fc0da59 00000024 01030000 80010001 00020004 00000e10
80010002 00020004 0003d090 80040002 02000034 04020401 c072ec18 00000028 01030000
80010001 00020004 00000e10 80010002 00020004 0003d090 80040002 80050002 02000034
04030401 7fc0da59 00000028 01030000 80010001 00020004 00000
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=8(hash) 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=1(sa) 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=10(nonce) 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=5(id) 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=5(id) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: received IDci2:
Aug  3 21:59:13 scooby racoon: DEBUG:  011106a5 c0a80064 
Aug  3 21:59:13 scooby racoon: DEBUG: received IDcr2:
Aug  3 21:59:13 scooby racoon: DEBUG:  01110000 c0a80002 
Aug  3 21:59:13 scooby racoon: DEBUG: HASH(1) validate:
Aug  3 21:59:13 scooby racoon: DEBUG:  416fc129 f6e56e35 38696b7f 077c02b3 99fb3621 
Aug  3 21:59:13 scooby racoon: DEBUG: HASH with: 
Aug  3 21:59:13 scooby racoon: DEBUG:  d48272e2 0a0003f4 00000001 00000001
0200005c 01030402 c072ec18 03000028 01030000 80010001 00020004 00000e10 80010002
00020004 0003d090 80040002 80050001 00000028 02030000 80010001 00020004 00000e10
80010002 00020004 0003d090 80040002 80050002 02000034 02020401 c072ec18 00000028
01030000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002 80050002
02000030 02030401 7fc0da59 00000024 01030000 80010001 00020004 00000e10 80010002
00020004 0003d090 80040002 02000034 03020401 c072ec18 00000028 01020000 80010001
00020004 00000e10 80010002 00020004 0003d090 80040002 80050001 02000030 03030401
7fc0da59 00000024 01030000 80010001 00020004 00000e10 80010002 00020004 0003d090
80040002 02000034 04020401 c072ec18 00000028 01030000 80010001 00020004 00000e10
80010002 00020004 0003d090 80040002 80050002 02000034 04030401 7fc0da59 00000028
01030000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002 80050002
02000034 05020401 c072ec18 00000028 01020000 80010001 00020
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_sha1) 
Aug  3 21:59:13 scooby racoon: DEBUG: HASH computed: 
Aug  3 21:59:13 scooby racoon: DEBUG:  416fc129 f6e56e35 38696b7f 077c02b3 99fb3621 
Aug  3 21:59:13 scooby racoon: DEBUG: anonymous sainfo selected. 
Aug  3 21:59:13 scooby racoon: DEBUG: get sa info: anonymous 
Aug  3 21:59:13 scooby racoon: DEBUG: get a src address from ID payload
192.168.0.100[1701] prefixlen=32 ul_proto=17 
Aug  3 21:59:13 scooby racoon: DEBUG: get dst address from ID payload
192.168.0.2[0] prefixlen=32 ul_proto=17 
Aug  3 21:59:13 scooby racoon: DEBUG: sub:0xbffff8e0: 192.168.0.100/32[1701]
192.168.0.2/32[0] proto=udp dir=in 
Aug  3 21:59:13 scooby racoon: DEBUG: db: 0x80aa020: 192.168.0.100/32[1701]
192.168.0.2/32[0] proto=udp dir=in 
Aug  3 21:59:13 scooby racoon: DEBUG: 0xbffff8e0 masked with /32:
192.168.0.100[1701] 
Aug  3 21:59:13 scooby racoon: DEBUG: 0x80aa020 masked with /32:
192.168.0.100[1701] 
Aug  3 21:59:13 scooby racoon: DEBUG: 0xbffff8e0 masked with /32: 192.168.0.2[0] 
Aug  3 21:59:13 scooby racoon: DEBUG: 0x80aa020 masked with /32: 192.168.0.2[0] 
Aug  3 21:59:13 scooby racoon: DEBUG: sub:0xbffff8e0: 192.168.0.2/32[0]
192.168.0.100/32[1701] proto=udp dir=out 
Aug  3 21:59:13 scooby racoon: DEBUG: db: 0x80aa020: 192.168.0.100/32[1701]
192.168.0.2/32[0] proto=udp dir=in 
Aug  3 21:59:13 scooby racoon: DEBUG: sub:0xbffff8e0: 192.168.0.2/32[0]
192.168.0.100/32[1701] proto=udp dir=out 
Aug  3 21:59:13 scooby racoon: DEBUG: db: 0x80aa258: 192.168.0.2/32[0]
192.168.0.100/32[1701] proto=udp dir=out 
Aug  3 21:59:13 scooby racoon: DEBUG: 0xbffff8e0 masked with /32: 192.168.0.2[0] 
Aug  3 21:59:13 scooby racoon: DEBUG: 0x80aa258 masked with /32: 192.168.0.2[0] 
Aug  3 21:59:13 scooby racoon: DEBUG: 0xbffff8e0 masked with /32:
192.168.0.100[1701] 
Aug  3 21:59:13 scooby racoon: DEBUG: 0x80aa258 masked with /32:
192.168.0.100[1701] 
Aug  3 21:59:13 scooby racoon: DEBUG: suitable SP found:192.168.0.2/32[0]
192.168.0.100/32[1701] proto=udp dir=out 
Aug  3 21:59:13 scooby racoon: DEBUG:  (proto_id=ESP spisize=4 spi=00000000
spi_p=00000000 encmode=Transport reqid=0:0) 
Aug  3 21:59:13 scooby racoon: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-md5) 
Aug  3 21:59:13 scooby racoon: DEBUG: total SA len=1008 
Aug  3 21:59:13 scooby racoon: DEBUG:  00000001 00000001 0200005c 01030402
c072ec18 03000028 01030000 80010001 00020004 00000e10 80010002 00020004 0003d090
80040002 80050001 00000028 02030000 80010001 00020004 00000e10 80010002 00020004
0003d090 80040002 80050002 02000034 02020401 c072ec18 00000028 01030000 80010001
00020004 00000e10 80010002 00020004 0003d090 80040002 80050002 02000030 02030401
7fc0da59 00000024 01030000 80010001 00020004 00000e10 80010002 00020004 0003d090
80040002 02000034 03020401 c072ec18 00000028 01020000 80010001 00020004 00000e10
80010002 00020004 0003d090 80040002 80050001 02000030 03030401 7fc0da59 00000024
01030000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002 02000034
04020401 c072ec18 00000028 01030000 80010001 00020004 00000e10 80010002 00020004
0003d090 80040002 80050002 02000034 04030401 7fc0da59 00000028 01030000 80010001
00020004 00000e10 80010002 00020004 0003d090 80040002 80050002 02000034 05020401
c072ec18 00000028 01020000 80010001 00020004 00000e10 80010
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=2(prop) 
Aug  3 21:59:13 scooby last message repeated 17 times
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #1 len=92 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #2 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-sha 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #2 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-sha 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #2 len=48 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=36 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #3 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #3 len=48 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=36 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #4 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-sha 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #4 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-sha 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #5 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #5 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #6 len=92 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #2 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-sha 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #7 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-sha 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #7 len=48 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=36 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #8 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #8 len=48 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=36 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #9 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-sha 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #9 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-sha 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #10 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #10 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 1: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80abf18: next=(nil) tnext=0x80a9858 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80a9858: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #1: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 2: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80a77e0: next=0x80a5bd0 tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80a5bd0: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #2: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 3: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80a8688: next=0x80a8478 tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80a8478: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #3: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 4: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80a8490: next=0x80a63d0 tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80a63d0: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #4: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 5: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80a63e8: next=0x80a8f50 tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80a8f50: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #5: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 6: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80a8f68: next=(nil) tnext=0x80a9890 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80a9890: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #6: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 7: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80a98a8: next=0x80a98c0 tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80a98c0: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #7: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 8: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80ac080: next=0x80ac098 tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80ac098: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #8: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 9: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80ac0b0: next=0x80abf70 tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80abf70: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #9: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 10: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80abf88: next=0x80abfa0 tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80abfa0: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #10: 2 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: begin compare proposals. 
Aug  3 21:59:13 scooby racoon: DEBUG: pair[1]: 0x80abf18 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80abf18: next=(nil) tnext=0x80a9858 
Aug  3 21:59:13 scooby racoon: DEBUG:   0x80a9858: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: prop#=1 prot-id=ESP spi-size=4 #trns=2
trns#=1 trns-id=3DES 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: prop#=1 prot-id=ESP spi-size=4 #trns=2
trns#=2 trns-id=3DES 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-sha 
Aug  3 21:59:13 scooby racoon: DEBUG: peer's single bundle: 
Aug  3 21:59:13 scooby racoon: DEBUG:  (proto_id=ESP spisize=4 spi=c072ec18
spi_p=00000000 encmode=Transport reqid=0:0) 
Aug  3 21:59:13 scooby racoon: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-md5) 
Aug  3 21:59:13 scooby racoon: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-sha) 
Aug  3 21:59:13 scooby racoon: DEBUG: my single bundle: 
Aug  3 21:59:13 scooby racoon: DEBUG:  (proto_id=ESP spisize=4 spi=00000000
spi_p=00000000 encmode=Transport reqid=0:0) 
Aug  3 21:59:13 scooby racoon: DEBUG:   (trns_id=3DES encklen=0 authtype=hmac-md5) 
Aug  3 21:59:13 scooby racoon: DEBUG: matched 
Aug  3 21:59:13 scooby racoon: DEBUG: === 
Aug  3 21:59:13 scooby racoon: DEBUG: call pfkey_send_getspi 
Aug  3 21:59:13 scooby racoon: DEBUG: pfkey GETSPI sent: ESP/Transport
192.168.0.100->192.168.0.2  
Aug  3 21:59:13 scooby racoon: DEBUG: pfkey getspi sent. 
Aug  3 21:59:13 scooby racoon: DEBUG: get pfkey GETSPI message 
Aug  3 21:59:13 scooby racoon: DEBUG2:  02010003 18000000 57032238 6e0f0000
02000100 0e66db7c 00000000 00000000 04000300 00000000 00000000 00000000 1e000000
00000000 00000000 00000000 04000400 00000000 00000000 00000000 00000000 00000000
00000000 00000000 04000200 00000000 00000000 00000000 91ee0f41 00000000 00000000
00000000 03000500 00200000 02000000 c0a80064 00000000 00000000 03000600 00200000
02000000 c0a80002 00000000 00000000 02001300 01000000 00000000 00000000 
Aug  3 21:59:13 scooby racoon: DEBUG: pfkey GETSPI succeeded: ESP/Transport
192.168.0.100->192.168.0.2 spi=241621884(0xe66db7c) 
Aug  3 21:59:13 scooby racoon: DEBUG: total SA len=60 
Aug  3 21:59:13 scooby racoon: DEBUG:  00000001 00000001 00000034 01030401
00000000 00000028 01030000 80010001 00020004 00000e10 80010002 00020004 0003d090
80040002 80050001 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=2(prop) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #1 len=52 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=3(trns) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: transform #1 len=40 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000, lorv=seconds 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Type, flag=0x8000,
lorv=kilobytes 
Aug  3 21:59:13 scooby racoon: DEBUG: type=SA Life Duration, flag=0x0000, lorv=4 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Encryption Mode, flag=0x8000,
lorv=Transport 
Aug  3 21:59:13 scooby racoon: DEBUG: type=Authentication Algorithm,
flag=0x8000, lorv=hmac-md5 
Aug  3 21:59:13 scooby racoon: DEBUG: pair 1: 
Aug  3 21:59:13 scooby racoon: DEBUG:  0x80a77e0: next=(nil) tnext=(nil) 
Aug  3 21:59:13 scooby racoon: DEBUG: proposal #1: 1 transform 
Aug  3 21:59:13 scooby racoon: DEBUG: add payload of len 60, next type 10 
Aug  3 21:59:13 scooby racoon: DEBUG: add payload of len 16, next type 5 
Aug  3 21:59:13 scooby racoon: DEBUG: add payload of len 8, next type 5 
Aug  3 21:59:13 scooby racoon: DEBUG: add payload of len 8, next type 0 
Aug  3 21:59:13 scooby racoon: DEBUG: HASH with: 
Aug  3 21:59:13 scooby racoon: DEBUG:  d48272e2 3ea5d7bf 02b62d71 b37efd97
30013a15 020cfc8c 0a000040 00000001 00000001 00000034 01030401 0e66db7c 00000028
01030000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002 80050001
05000014 d26aff15 3d0b02f5 67c81d7f a4fc003e 0500000c 011106a5 c0a80064 0000000c
01110000 c0a80002 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_sha1) 
Aug  3 21:59:13 scooby racoon: DEBUG: HASH computed: 
Aug  3 21:59:13 scooby racoon: DEBUG:  05a385f9 7d0d36c4 e5b74449 7fed7dfa 70415905 
Aug  3 21:59:13 scooby racoon: DEBUG: add payload of len 20, next type 1 
Aug  3 21:59:13 scooby racoon: DEBUG: begin encryption. 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: pad length = 4 
Aug  3 21:59:13 scooby racoon: DEBUG:  01000018 05a385f9 7d0d36c4 e5b74449
7fed7dfa 70415905 0a000040 00000001 00000001 00000034 01030401 0e66db7c 00000028
01030000 80010001 00020004 00000e10 80010002 00020004 0003d090 80040002 80050001
05000014 d26aff15 3d0b02f5 67c81d7f a4fc003e 0500000c 011106a5 c0a80064 0000000c
01110000 c0a80002 62c4d403 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: with key: 
Aug  3 21:59:13 scooby racoon: DEBUG:  e0814bd6 704b9d63 54bf6496 64f8abdb
b5e41d57 e08d61d9 
Aug  3 21:59:13 scooby racoon: DEBUG: encrypted payload by IV: 
Aug  3 21:59:13 scooby racoon: DEBUG:  02132a91 a14258ce 
Aug  3 21:59:13 scooby racoon: DEBUG: save IV for next: 
Aug  3 21:59:13 scooby racoon: DEBUG:  02132a91 a14258ce 
Aug  3 21:59:13 scooby racoon: DEBUG: encrypted. 
Aug  3 21:59:13 scooby racoon: DEBUG: 164 bytes from 192.168.0.2[500] to
192.168.0.100[500] 
Aug  3 21:59:13 scooby racoon: DEBUG: sockname 192.168.0.2[500] 
Aug  3 21:59:13 scooby racoon: DEBUG: send packet from 192.168.0.2[500] 
Aug  3 21:59:13 scooby racoon: DEBUG: send packet to 192.168.0.100[500] 
Aug  3 21:59:13 scooby racoon: DEBUG: src4 192.168.0.2[500] 
Aug  3 21:59:13 scooby racoon: DEBUG: dst4 192.168.0.100[500] 
Aug  3 21:59:13 scooby racoon: DEBUG: 1 times of 164 bytes message will be sent
to 192.168.0.2[500] 
Aug  3 21:59:13 scooby racoon: DEBUG:  e439faa2 df4fcd2d 6f7069be 243c45c7
08102001 d48272e2 000000a4 bb97981a 572e0599 8d18a65f 8436564b 4288fad8 c46126d3
f31eae1f f152d8d4 99b888cb c4bc1cdb 0601e679 cb4c5007 949b0461 106b3000 1b64661f
cb7fd72f 8e1c6628 4b79ab0e 2dc7f80f 8ac126b4 4af20066 fcd13a14 29461c26 757feb7d
0c4712ee f45d2415 4d4b870b 5f22cd4c 11badbb0 0250889e b0cdb938 9517caad 02132a91
a14258ce 
Aug  3 21:59:13 scooby racoon: DEBUG: resend phase2 packet
e439faa2df4fcd2d:6f7069be243c45c7:0000d482 
Aug  3 21:59:13 scooby racoon: DEBUG: === 
Aug  3 21:59:13 scooby racoon: DEBUG: 52 bytes message received from
192.168.0.100[500] to 192.168.0.2[500] 
Aug  3 21:59:13 scooby racoon: DEBUG:  e439faa2 df4fcd2d 6f7069be 243c45c7
08102001 d48272e2 00000034 b1c1d0ee 3169ba37 fbfbaed2 6f47f81a a507e835 fb9bffb6 
Aug  3 21:59:13 scooby racoon: DEBUG: begin decryption. 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: IV was saved for next processing: 
Aug  3 21:59:13 scooby racoon: DEBUG:  a507e835 fb9bffb6 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: with key: 
Aug  3 21:59:13 scooby racoon: DEBUG:  e0814bd6 704b9d63 54bf6496 64f8abdb
b5e41d57 e08d61d9 
Aug  3 21:59:13 scooby racoon: DEBUG: decrypted payload by IV: 
Aug  3 21:59:13 scooby racoon: DEBUG:  a507e835 fb9bffb6 
Aug  3 21:59:13 scooby racoon: DEBUG: decrypted payload, but not trimed. 
Aug  3 21:59:13 scooby racoon: DEBUG:  00000018 b33064f9 a01ad7f1 d06a8614
7b1f4381 95af180f 
Aug  3 21:59:13 scooby racoon: DEBUG: padding len=16 
Aug  3 21:59:13 scooby racoon: DEBUG: skip to trim padding. 
Aug  3 21:59:13 scooby racoon: DEBUG: decrypted. 
Aug  3 21:59:13 scooby racoon: DEBUG:  e439faa2 df4fcd2d 6f7069be 243c45c7
08102001 d48272e2 00000034 00000018 b33064f9 a01ad7f1 d06a8614 7b1f4381 95af180f 
Aug  3 21:59:13 scooby racoon: DEBUG: begin. 
Aug  3 21:59:13 scooby racoon: DEBUG: seen nptype=8(hash) 
Aug  3 21:59:13 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:13 scooby racoon: DEBUG: HASH(3) validate:
Aug  3 21:59:13 scooby racoon: DEBUG:  b33064f9 a01ad7f1 d06a8614 7b1f4381 95af180f 
Aug  3 21:59:13 scooby racoon: DEBUG: HASH with:  
Aug  3 21:59:13 scooby racoon: DEBUG:  00d48272 e23ea5d7 bf02b62d 71b37efd
9730013a 15020cfc 8cd26aff 153d0b02 f567c81d 7fa4fc00 3e 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_sha1) 
Aug  3 21:59:13 scooby racoon: DEBUG: HASH computed: 
Aug  3 21:59:13 scooby racoon: DEBUG:  b33064f9 a01ad7f1 d06a8614 7b1f4381 95af180f 
Aug  3 21:59:13 scooby racoon: DEBUG: === 
Aug  3 21:59:13 scooby racoon: DEBUG: KEYMAT compute with 
Aug  3 21:59:13 scooby racoon: DEBUG:  030e66db 7c3ea5d7 bf02b62d 71b37efd
9730013a 15020cfc 8cd26aff 153d0b02 f567c81d 7fa4fc00 3e 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_sha1) 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_md5) 
Aug  3 21:59:13 scooby racoon: DEBUG: encklen=192 authklen=128 
Aug  3 21:59:13 scooby racoon: DEBUG: generating 640 bits of key (dupkeymat=4) 
Aug  3 21:59:13 scooby racoon: DEBUG: generating K1...K4 for KEYMAT. 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_sha1) 
Aug  3 21:59:13 scooby last message repeated 2 times
Aug  3 21:59:13 scooby racoon: DEBUG:  44fe759a 613f2253 f07f473f b69bd9a0
636e32e3 7bab6b95 05d2e75c 32fc8f2a 079f2ee2 7dfd1a97 409c333b 53295a34 2b0cfb11
d987fbac caddcd52 9025d3b5 3fe17e0c 8b3218ff 19e83f37 a10feb81 
Aug  3 21:59:13 scooby racoon: DEBUG: KEYMAT compute with 
Aug  3 21:59:13 scooby racoon: DEBUG:  03c072ec 183ea5d7 bf02b62d 71b37efd
9730013a 15020cfc 8cd26aff 153d0b02 f567c81d 7fa4fc00 3e 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_sha1) 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_md5) 
Aug  3 21:59:13 scooby racoon: DEBUG: encklen=192 authklen=128 
Aug  3 21:59:13 scooby racoon: DEBUG: generating 640 bits of key (dupkeymat=4) 
Aug  3 21:59:13 scooby racoon: DEBUG: generating K1...K4 for KEYMAT. 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_sha1) 
Aug  3 21:59:13 scooby last message repeated 2 times
Aug  3 21:59:13 scooby racoon: DEBUG:  0c152d12 073ffb51 cad0263b b1153c91
37785e6a c2284721 f1f131d7 b2623e0e 779628b7 cef91303 e384cded 03335cce 8d198749
07acb210 d98810ed 7266b191 4dbbe9aa f5be72f1 6e5f6e3b 10cd8f41 
Aug  3 21:59:13 scooby racoon: DEBUG: KEYMAT computed. 
Aug  3 21:59:13 scooby racoon: DEBUG: call pk_sendupdate 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_md5) 
Aug  3 21:59:13 scooby racoon: DEBUG: call pfkey_send_update_nat 
Aug  3 21:59:13 scooby racoon: DEBUG: pfkey update sent. 
Aug  3 21:59:13 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:13 scooby racoon: DEBUG: hmac(hmac_md5) 
Aug  3 21:59:13 scooby racoon: DEBUG: call pfkey_send_add_nat 
Aug  3 21:59:14 scooby racoon: DEBUG: pfkey add sent. 
Aug  3 21:59:14 scooby racoon: DEBUG: === 
Aug  3 21:59:14 scooby racoon: DEBUG: 68 bytes message received from
192.168.0.100[500] to 192.168.0.2[500] 
Aug  3 21:59:14 scooby racoon: DEBUG:  e439faa2 df4fcd2d 6f7069be 243c45c7
08100501 524480bd 00000044 204abdb1 76d81c76 cef865ed e4062372 2b7a6678 76e6a3e7
5f1db06a 5605f5e8 4d0baf02 1c67fefc 
Aug  3 21:59:14 scooby racoon: DEBUG: receive Information. 
Aug  3 21:59:14 scooby racoon: DEBUG: compute IV for phase2 
Aug  3 21:59:14 scooby racoon: DEBUG: phase1 last IV: 
Aug  3 21:59:14 scooby racoon: DEBUG:  d589b86f 956f2b07 524480bd 
Aug  3 21:59:14 scooby racoon: DEBUG: hash(sha1) 
Aug  3 21:59:14 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:14 scooby racoon: DEBUG: phase2 IV computed: 
Aug  3 21:59:14 scooby racoon: DEBUG:  e26970dd b85e38d4 
Aug  3 21:59:14 scooby racoon: DEBUG: begin decryption. 
Aug  3 21:59:14 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:14 scooby racoon: DEBUG: IV was saved for next processing: 
Aug  3 21:59:14 scooby racoon: DEBUG:  4d0baf02 1c67fefc 
Aug  3 21:59:14 scooby racoon: DEBUG: encription(3des) 
Aug  3 21:59:14 scooby racoon: DEBUG: with key: 
Aug  3 21:59:14 scooby racoon: DEBUG:  e0814bd6 704b9d63 54bf6496 64f8abdb
b5e41d57 e08d61d9 
Aug  3 21:59:14 scooby racoon: DEBUG: decrypted payload by IV: 
Aug  3 21:59:14 scooby racoon: DEBUG:  4d0baf02 1c67fefc 
Aug  3 21:59:14 scooby racoon: DEBUG: decrypted payload, but not trimed. 
Aug  3 21:59:14 scooby racoon: DEBUG:  0c000018 25e0d47f 66545c70 ef1396c8
a53f2dbd 79b5364b 00000010 00000001 03040001 55b1fcde 
Aug  3 21:59:14 scooby racoon: DEBUG: padding len=223 
Aug  3 21:59:14 scooby racoon: DEBUG: skip to trim padding. 
Aug  3 21:59:14 scooby racoon: DEBUG: decrypted. 
Aug  3 21:59:14 scooby racoon: DEBUG:  e439faa2 df4fcd2d 6f7069be 243c45c7
08100501 524480bd 00000044 0c000018 25e0d47f 66545c70 ef1396c8 a53f2dbd 79b5364b
00000010 00000001 03040001 55b1fcde 
Aug  3 21:59:14 scooby racoon: DEBUG: HASH with: 
Aug  3 21:59:14 scooby racoon: DEBUG:  524480bd 00000010 00000001 03040001 55b1fcde 
Aug  3 21:59:14 scooby racoon: DEBUG: hmac(hmac_sha1) 
Aug  3 21:59:14 scooby racoon: DEBUG: HASH computed: 
Aug  3 21:59:14 scooby racoon: DEBUG:  25e0d47f 66545c70 ef1396c8 a53f2dbd 79b5364b 
Aug  3 21:59:14 scooby racoon: DEBUG: hash validated. 
Aug  3 21:59:14 scooby racoon: DEBUG: begin. 
Aug  3 21:59:14 scooby racoon: DEBUG: seen nptype=8(hash) 
Aug  3 21:59:14 scooby racoon: DEBUG: seen nptype=12(delete) 
Aug  3 21:59:14 scooby racoon: DEBUG: succeed. 
Aug  3 21:59:14 scooby racoon: DEBUG: call pfkey_send_dump 
Aug  3 21:59:14 scooby racoon: DEBUG: check spi(packet)=1437727966
spi(db)=3228757016. 
Aug  3 21:59:14 scooby racoon: DEBUG: check spi(packet)=1437727966
spi(db)=1437727966. 
Aug  3 21:59:14 scooby racoon: INFO: purged IPsec-SA proto_id=ESP spi=1437727966. 
Aug  3 21:59:14 scooby racoon: DEBUG: purged SAs. 
Aug  3 21:59:14 scooby racoon: DEBUG: get pfkey UPDATE message 
Aug  3 21:59:14 scooby racoon: DEBUG2:  02020003 1b000000 57032238 6e0f0000
02000100 0e66db7c 04010203 00000000 04000300 00000000 00000000 00000000 100e0000
00000000 00000000 00000000 04000400 00000000 00000000 00000000 400b0000 00000000
00000000 00000000 04000200 00000000 00000000 00000000 91ee0f41 00000000 00000000
00000000 03000500 00200000 02000000 c0a80064 00000000 00000000 03000600 00200000
02000000 c0a80002 00000000 00000000 03000700 ff000000 02000000 00000000 00000000
00000000 02001300 01000000 00000000 00000000 
Aug  3 21:59:14 scooby racoon: DEBUG: pfkey UPDATE succeeded: ESP/Transport
192.168.0.100->192.168.0.2 spi=241621884(0xe66db7c) 
Aug  3 21:59:14 scooby racoon: INFO: IPsec-SA established: ESP/Transport
192.168.0.100->192.168.0.2 spi=241621884(0xe66db7c) 
Aug  3 21:59:14 scooby racoon: DEBUG: === 
Aug  3 21:59:14 scooby racoon: DEBUG: get pfkey ADD message 
Aug  3 21:59:14 scooby racoon: DEBUG2:  02030003 1b000000 57032238 6e0f0000
02000100 c072ec18 04010203 00000000 04000300 00000000 00000000 00000000 100e0000
00000000 00000000 00000000 04000400 00000000 00000000 00000000 400b0000 00000000
00000000 00000000 04000200 00000000 00000000 00000000 92ee0f41 00000000 00000000
00000000 03000500 00200000 02000000 c0a80002 00000000 00000000 03000600 00200000
02000000 c0a80064 00000000 00000000 03000700 ff000000 02000000 00000000 00000000
00000000 02001300 01000000 00000000 00000000 
Aug  3 21:59:14 scooby racoon: INFO: IPsec-SA established: ESP/Transport
192.168.0.2->192.168.0.100 spi=3228757016(0xc072ec18) 
Aug  3 21:59:14 scooby racoon: DEBUG: === 
Aug  3 21:59:14 scooby racoon: DEBUG: get pfkey DELETE message 
Aug  3 21:59:14 scooby racoon: DEBUG2:  02040003 0a000000 00000000 6e0f0000
02000100 55b1fcde 00000000 00000000 03000500 ff200000 02000000 c0a80002 00000000
00000000 03000600 ff200000 02000000 c0a80064 00000000 00000000 
Aug  3 21:59:14 scooby racoon: DEBUG: DELETE message is not interesting because
the message was originated by me. 
Aug  3 21:59:40 scooby racoon: DEBUG: get pfkey EXPIRE message 
Aug  3 21:59:40 scooby racoon: DEBUG2:  02080003 17000000 00000000 00000000
02000100 081bb4e6 04030203 00000000 04000300 00000000 00000000 00000000 100e0000
00000000 00000000 00000000 04000200 e9010000 2a880100 00000000 9ce00f41 00000000
9de00f41 00000000 03000500 00200000 02000000 c0a80064 00000000 00000000 03000600
00200000 02000000 c0a80002 00000000 00000000 03000700 ff000000 02000000 00000000
00000000 00000000 02001300 01000000 00000000 00000000 
Aug  3 21:59:40 scooby racoon: INFO: IPsec-SA expired: ESP/Transport
192.168.0.100->192.168.0.2 spi=136033510(0x81bb4e6) 
Aug  3 21:59:40 scooby racoon: DEBUG: no such a SA found: ESP/Transport
192.168.0.100->192.168.0.2 spi=136033510(0x81bb4e6) 
Aug  3 21:59:41 scooby l2tpd[1194]: check_control: control, cid = 0, Ns = 4, Nr
= 62 
Aug  3 21:59:41 scooby kernel: bad: scheduling while atomic!
Aug  3 21:59:41 scooby kernel:  [schedule+60/1002] schedule+0x3c/0x3ea
Aug  3 21:59:41 scooby kernel:  [default_idle+0/38] default_idle+0x0/0x26
Aug  3 21:59:41 scooby kernel:  [cpu_idle+48/50] cpu_idle+0x30/0x32
Aug  3 21:59:41 scooby kernel:  [start_kernel+388/392] start_kernel+0x184/0x188
Aug  3 21:59:41 scooby kernel: 
Aug  3 21:59:41 scooby kernel: bad: scheduling while atomic!
Aug  3 21:59:41 scooby kernel:  [schedule+60/1002] schedule+0x3c/0x3ea
Aug  3 21:59:41 scooby kernel:  [default_idle+0/38] default_idle+0x0/0x26
Aug  3 21:59:41 scooby kernel:  [cpu_idle+48/50] cpu_idle+0x30/0x32
Aug  3 21:59:41 scooby kernel:  [start_kernel+388/392] start_kernel+0x184/0x188
Aug  3 21:59:41 scooby kernel:

Problem Description:

If I connect one of my l2tp over ipsec (ipsec in transport mode) clients (Up to
date Windows XP, using x509 auth), connection works, but after some time passes
(anything from minutes to hours, doesn't appear to be affected by traffic amount
through the tunnel)

Steps to reproduce:

Simply start the XP vpn connection and wait.

Feel free to contact me for additional information.

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
