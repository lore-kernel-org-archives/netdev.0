From: "Boris B. Zhmurov" <bb@kernelpanic.ru>
Subject: Re: [e1000 debug] KERNEL: assertion (!sk_forward_alloc) failed...
Date: Thu, 30 Mar 2006 12:39:37 +0400
Message-ID: <442B9949.40509@kernelpanic.ru>
References: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000004050601010005050401"
Cc: nipsy@bitgnome.net, jrlundgren@gmail.com, cat@zip.com.au,
	djani22@dynamicweb.hu, yoseph.basri@gmail.com, mykleb@no.ibm.com,
	olel@ans.pl, michal@feix.cz, chris@scorpion.nl,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>, davem@davemloft.net,
	E1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-admin@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
In-Reply-To: <C925F8B43D79CC49ACD0601FB68FF50C07461F59@orsmsx408>
Sender: e1000-devel-admin@lists.sourceforge.net
Errors-To: e1000-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=e1000-devel>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000004050601010005050401
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello, Brandeburg, Jesse.

On 30.03.2006 06:53 you said the following:

> Hi all, I've identified you as people who have at some point in the past
> emailed one of the Linux lists with problems with e1000 and
> sk_forward_alloc.  It seems to be fairly widespread, but only seems to
> have appeared with recent kernel changes (after 2.6.12...)
> 
> What I need from you is a reproducible test, and some information.  I
> have never been able to reproduce this, and I'm trying to isolate the
> problem a bit.  What motherboards are you using?  What seems to cause
> this problem?  Are you all using iptables?  Are you all routing? From
> the reports I assume none of you are using an 82571/2/3 (pci express)
> 
> As far as I know e1000 has the same requirement as tg3 and some others
> where we have to modify the header of the skb in the case of transmits
> using TSO.  I don't see anywhere else that the driver modifies the skb.
> Tomorrow I'll generate a patch to try a more paranoid copying of the
> skb, I hope some of you can test.


Jesse, I'd like to try your patches to help get rid of this annoying 
problem. I want to say, that this problem 100% reproucible on my 
hard-loading webserver based on RHEL4 with kernels 2.6.9 (rhel4 
original) - 2.6.15.7 (i.e. all releases from 2.6.9 to 2.6.15.7 affected).

  I have an asus 1unit server with double P4@2.8Ghz processors with 
enabled HyperThreading and 3Gb RAM, but with 1Gb RAM I have the same 
problem, thus it's not a RAM issue. This is really high load server, 
serving about 1000-1500 http requests per second plus about 500-1000 ftp 
requests per second.

  dmesg, lspci -vv, iptables -nL and ip route show in attached files. 
Wating for your instructions.


P.S. I use two e1000 adapters at the same time with advanced routing 
like this:

[root@msk4 ~]# cat /etc/rc.local |grep ip
# This script will be executed *after* all the other init scripts.
/sbin/ip rule add from 83.102.130.174 table NEW
/sbin/ip route add default via 83.102.130.173 dev eth0 table NEW



And also I have some hardcored sysctl options like this:

net.core.somaxconn=1024
net.ipv4.tcp_timestamps=0
net.ipv4.tcp_max_tw_buckets=720000
net.core.rmem_default=215040
net.core.rmem_max=262144
net.core.wmem_default=215040
net.core.wmem_max=262144
net.core.optmem_max=81920
net.core.netdev_max_backlog=8192
net.ipv4.neigh.default.gc_thresh1=512
net.ipv4.neigh.default.gc_thresh2=2048
net.ipv4.neigh.default.gc_thresh3=4096
net.ipv4.neigh.default.unres_qlen=64
net.ipv4.neigh.default.proxy_qlen=256
net.ipv4.tcp_rmem = 4096 131072 262144
net.ipv4.tcp_wmem = 4096 131072 262144
net.ipv4.tcp_keepalive_time=1800
net.ipv4.tcp_sack=0
net.ipv4.tcp_fin_timeout=30
net.ipv4.tcp_window_scaling=0
net.ipv4.tcp_keepalive_probes=3
kernel.sem=250 32000 100 128



-- 
Boris B. Zhmurov
mailto: bb@kernelpanic.ru
"wget http://kernelpanic.ru/bb_public_key.pgp -O - | gpg --import"


--------------000004050601010005050401
Content-Type: text/plain;
 name="dmesg"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="dmesg"

Linux version 2.6.15-7.0.bbel4smp (zhmurov@builds.kernelpanic.ru) (gcc version 3.4.5 20051201 (Red Hat 3.4.5-2)) #1 SMP Tue Mar 28 14:52:13 MSD 2006
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 00000000000a0000 (usable)
 BIOS-e820: 00000000000f0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 00000000bfffb000 (usable)
 BIOS-e820: 00000000bfffb000 - 00000000bffff000 (ACPI data)
 BIOS-e820: 00000000bffff000 - 00000000c0000000 (ACPI NVS)
 BIOS-e820: 00000000fec00000 - 00000000fec01000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000ffff0000 - 0000000100000000 (reserved)
2175MB HIGHMEM available.
896MB LOWMEM available.
found SMP MP-table at 000f0830
On node 0 totalpages: 786427
  DMA zone: 4096 pages, LIFO batch:0
  DMA32 zone: 0 pages, LIFO batch:0
  Normal zone: 225280 pages, LIFO batch:31
  HighMem zone: 557051 pages, LIFO batch:31
DMI 2.3 present.
Using APIC driver default
ACPI: RSDP (v000 ASUS                                  ) @ 0x000f55a0
ACPI: RSDT (v001 ASUS   PR-DLSR  0x42302e31 MSFT 0x31313031) @ 0xbfffb000
ACPI: FADT (v001 ASUS   PR-DLSR  0x42302e31 MSFT 0x31313031) @ 0xbfffb145
ACPI: BOOT (v001 ASUS   PR-DLSR  0x42302e31 MSFT 0x31313031) @ 0xbfffb034
ACPI: SPCR (v001 ASUS   PR-DLSR  0x42302e31 MSFT 0x31313031) @ 0xbfffb05c
ACPI: MADT (v001 ASUS   PR-DLSR  0x42302e31 MSFT 0x31313031) @ 0xbfffb0a9
ACPI: DSDT (v001   ASUS PR-DLSR  0x00001000 MSFT 0x0100000b) @ 0x00000000
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x00] enabled)
Processor #0 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x02] lapic_id[0x06] enabled)
Processor #6 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x01] enabled)
Processor #1 15:2 APIC version 20
ACPI: LAPIC (acpi_id[0x03] lapic_id[0x07] enabled)
Processor #7 15:2 APIC version 20
ACPI: LAPIC_NMI (acpi_id[0x00] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x02] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] high edge lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x03] high edge lint[0x1])
ACPI: IOAPIC (id[0x02] address[0xfec00000] gsi_base[0])
IOAPIC[0]: apic_id 2, version 17, address 0xfec00000, GSI 0-15
ACPI: IOAPIC (id[0x03] address[0xfec01000] gsi_base[16])
IOAPIC[1]: apic_id 3, version 17, address 0xfec01000, GSI 16-31
ACPI: IOAPIC (id[0x04] address[0xfec02000] gsi_base[32])
IOAPIC[2]: apic_id 4, version 17, address 0xfec02000, GSI 32-47
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl edge)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 low level)
ACPI: IRQ0 used by override.
ACPI: IRQ2 used by override.
ACPI: IRQ9 used by override.
Enabling APIC mode:  Flat.  Using 3 I/O APICs
Using ACPI (MADT) for SMP configuration information
Allocating PCI resources starting at c4000000 (gap: c0000000:3ec00000)
Built 1 zonelists
Kernel command line: ro root=LABEL=/
mapped APIC to ffffd000 (fee00000)
mapped IOAPIC to ffffc000 (fec00000)
mapped IOAPIC to ffffb000 (fec01000)
mapped IOAPIC to ffffa000 (fec02000)
Initializing CPU#0
CPU 0 irqstacks, hard=c0391000 soft=c0371000
PID hash table entries: 4096 (order: 12, 65536 bytes)
Detected 2790.958 MHz processor.
Using tsc for high-res timesource
Console: colour VGA+ 80x25
Dentry cache hash table entries: 131072 (order: 7, 524288 bytes)
Inode-cache hash table entries: 65536 (order: 6, 262144 bytes)
Memory: 3114260k/3145708k available (1599k kernel code, 30168k reserved, 685k data, 188k init, 2228204k highmem)
Checking if this processor honours the WP bit even in supervisor mode... Ok.
Calibrating delay using timer specific routine.. 5589.74 BogoMIPS (lpj=27948717)
Mount-cache hash table entries: 512
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebfbff 00000000 00000000 00000080 00004400 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU0: Intel P4/Xeon Extended MCE MSRs (12) available
CPU0: Thermal monitoring enabled
mtrr: v2.0 (20020519)
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
CPU0: Intel(R) Xeon(TM) CPU 2.80GHz stepping 05
Booting processor 1/1 eip 2000
CPU 1 irqstacks, hard=c0392000 soft=c0372000
Initializing CPU#1
Calibrating delay using timer specific routine.. 5581.58 BogoMIPS (lpj=27907945)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: Physical Processor ID: 0
CPU: After all inits, caps: bfebfbff 00000000 00000000 00000080 00004400 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#1.
CPU1: Intel P4/Xeon Extended MCE MSRs (12) available
CPU1: Thermal monitoring enabled
CPU1: Intel(R) Xeon(TM) CPU 2.80GHz stepping 05
Booting processor 2/6 eip 2000
CPU 2 irqstacks, hard=c0393000 soft=c0373000
Initializing CPU#2
Calibrating delay using timer specific routine.. 5581.69 BogoMIPS (lpj=27908471)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: Physical Processor ID: 3
CPU: After all inits, caps: bfebfbff 00000000 00000000 00000080 00004400 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#2.
CPU2: Intel P4/Xeon Extended MCE MSRs (12) available
CPU2: Thermal monitoring enabled
CPU2: Intel(R) Xeon(TM) CPU 2.80GHz stepping 05
Booting processor 3/7 eip 2000
CPU 3 irqstacks, hard=c0394000 soft=c0374000
Initializing CPU#3
Calibrating delay using timer specific routine.. 5581.78 BogoMIPS (lpj=27908908)
CPU: After generic identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000
CPU: After vendor identify, caps: bfebfbff 00000000 00000000 00000000 00004400 00000000 00000000
CPU: Trace cache: 12K uops, L1 D cache: 8K
CPU: L2 cache: 512K
CPU: Physical Processor ID: 3
CPU: After all inits, caps: bfebfbff 00000000 00000000 00000080 00004400 00000000 00000000
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#3.
CPU3: Intel P4/Xeon Extended MCE MSRs (12) available
CPU3: Thermal monitoring enabled
CPU3: Intel(R) Xeon(TM) CPU 2.80GHz stepping 05
Total of 4 processors activated (22334.80 BogoMIPS).
ENABLING IO-APIC IRQs
..TIMER: vector=0x31 apic1=0 pin1=2 apic2=-1 pin2=-1
..MP-BIOS bug: 8254 timer not connected to IO-APIC
...trying to set up timer (IRQ0) through the 8259A ...  failed.
...trying to set up timer as Virtual Wire IRQ... works.
checking TSC synchronization across 4 CPUs: passed.
Brought up 4 CPUs
checking if image is initramfs... it is
Freeing initrd memory: 656k freed
NET: Registered protocol family 16
ACPI: bus type pci registered
PCI: PCI BIOS revision 2.10 entry at 0xf18e0, last bus=2
PCI: Using configuration type 1
ACPI: Subsystem revision 20050902
ACPI: Interpreter enabled
ACPI: Using IOAPIC for interrupt routing
ACPI: PCI Interrupt Link [LNKA] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKB] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0
ACPI: PCI Interrupt Link [LNKC] (IRQs 3 4 5 6 7 9 10 11 *12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKE] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKF] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKG] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKH] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKI] (IRQs 3 *4 5 6 7 9 10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKJ] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKK] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKL] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0
ACPI: PCI Interrupt Link [LNKM] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKN] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKO] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKP] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKQ] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKR] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKS] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKT] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKU] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKV] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKW] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKX] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKY] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNKZ] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK0] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK1] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK2] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK3] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK4] (IRQs 3 4 5 6 7 9 10 11 12 14 15) *0, disabled.
ACPI: PCI Interrupt Link [LNK5] (IRQs 5 10 11 12 14 15) *0
ACPI: PCI Root Bridge [PCI0] (0000:00)
PCI: Probing PCI hardware (bus 00)
ACPI: _BBN and _CRS returns different value for \_SB_.PCI1. Select _CRS
ACPI: _BBN and _CRS returns different value for \_SB_.PCI2. Select _CRS
Boot video device is 0000:00:03.0
PCI: Ignoring BAR0-3 of IDE controller 0000:00:0f.1
ACPI: PCI Interrupt Routing Table [\_SB_.PCI0._PRT]
ACPI: PCI _CRS 1 overrides _BBN 0
ACPI: PCI Root Bridge [PCI1] (0000:01)
PCI: Probing PCI hardware (bus 01)
ACPI: _BBN and _CRS returns different value for \_SB_.PCI1. Select _CRS
ACPI: _BBN and _CRS returns different value for \_SB_.PCI2. Select _CRS
ACPI: PCI Interrupt Routing Table [\_SB_.PCI1._PRT]
ACPI: PCI _CRS 2 overrides _BBN 0
ACPI: PCI Root Bridge [PCI2] (0000:02)
PCI: Probing PCI hardware (bus 02)
ACPI: _BBN and _CRS returns different value for \_SB_.PCI1. Select _CRS
ACPI: _BBN and _CRS returns different value for \_SB_.PCI2. Select _CRS
ACPI: PCI Interrupt Routing Table [\_SB_.PCI2._PRT]
usbcore: registered new driver usbfs
usbcore: registered new driver hub
PCI: Using ACPI for IRQ routing
PCI: If a device doesn't work, try "pci=routeirq".  If it helps, post a report
Simple Boot Flag at 0x3a set to 0x80
highmem bounce pool size: 64 pages
Total HugeTLB memory allocated, 0
VFS: Disk quotas dquot_6.5.1
Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
Initializing Cryptographic API
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered
io scheduler cfq registered
Linux agpgart interface v0.101 (c) Dave Jones
serio: i8042 AUX port at 0x60,0x64 irq 12
serio: i8042 KBD port at 0x60,0x64 irq 1
Serial: 8250/16550 driver $Revision: 1.90 $ 4 ports, IRQ sharing disabled
RAMDISK driver initialized: 16 RAM disks of 16384K size 1024 blocksize
Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
SvrWks CSB5: IDE controller at PCI slot 0000:00:0f.1
SvrWks CSB5: chipset revision 147
SvrWks CSB5: not 100% native mode: will probe irqs later
    ide0: BM-DMA at 0xa800-0xa807, BIOS settings: hda:pio, hdb:pio
    ide1: BM-DMA at 0xa808-0xa80f, BIOS settings: hdc:pio, hdd:pio
Probing IDE interface ide0...
Probing IDE interface ide1...
Probing IDE interface ide0...
Probing IDE interface ide1...
mice: PS/2 mouse device common for all mice
md: md driver 0.90.3 MAX_MD_DEVS=256, MD_SB_DISKS=27
md: bitmap version 4.39
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 7, 524288 bytes)
TCP established hash table entries: 524288 (order: 10, 4194304 bytes)
TCP bind hash table entries: 65536 (order: 7, 524288 bytes)
TCP: Hash tables configured (established 524288 bind 65536)
TCP reno registered
TCP bic registered
Initializing IPsec netlink socket
NET: Registered protocol family 1
NET: Registered protocol family 17
Starting balanced_irq
Using IPI Shortcut mode
Freeing unused kernel memory: 188k freed
SCSI subsystem initialized
megaraid cmm: 2.20.2.6 (Release Date: Mon Mar 7 00:01:03 EST 2005)
megaraid: 2.20.4.6 (Release Date: Mon Mar 07 12:27:22 EST 2005)
megaraid: probe new device 0x1000:0x1960:0x1000:0xa520: bus 1:slot 3:func 0
ACPI: PCI Interrupt 0000:01:03.0[A] -> GSI 27 (level, low) -> IRQ 16
megaraid: fw version:[1Z26] bios version:[G112]
scsi0 : LSI Logic MegaRAID driver
scsi[0]: scanning scsi channel 0 [Phy 0] for non-raid devices
  Vendor: SDR       Model: GEM318            Rev: 0   
  Type:   Processor                          ANSI SCSI revision: 02
scsi[0]: scanning scsi channel 1 [Phy 1] for non-raid devices
scsi[0]: scanning scsi channel 2 [virtual] for logical drives
  Vendor: MegaRAID  Model: LD0 RAID5 70090R  Rev: 1Z26
  Type:   Direct-Access                      ANSI SCSI revision: 02
SCSI device sda: 143544320 512-byte hdwr sectors (73495 MB)
sda: asking for cache data failed
sda: assuming drive cache: write through
SCSI device sda: 143544320 512-byte hdwr sectors (73495 MB)
sda: asking for cache data failed
sda: assuming drive cache: write through
 sda: sda1 sda2 sda3 sda4 < sda5 >
sd 0:2:0:0: Attached scsi disk sda
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
 0:0:11:0: Attached scsi generic sg0 type 3
sd 0:2:0:0: Attached scsi generic sg1 type 0
Floppy drive(s): fd0 is 1.44M
FDC 0 is a National Semiconductor PC87306
Intel(R) PRO/1000 Network Driver - version 6.1.16-k2-NAPI
Copyright (c) 1999-2005 Intel Corporation.
ACPI: PCI Interrupt 0000:00:02.0[A] -> GSI 18 (level, low) -> IRQ 17
e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network Connection
ACPI: PCI Interrupt 0000:01:02.0[A] -> GSI 24 (level, low) -> IRQ 18
e1000: eth1: e1000_probe: Intel(R) PRO/1000 Network Connection
piix4_smbus 0000:00:0f.0: Found 0000:00:0f.0 device
piix4_smbus 0000:00:0f.0: Unusual config register value
piix4_smbus 0000:00:0f.0: Try using fix_hstcfg=1 if you experience problems
piix4_smbus 0000:00:0f.0: Illegal Interrupt configuration (or code out of date)!
ohci_hcd: 2005 April 22 USB 1.1 'Open' Host Controller (OHCI) Driver (PCI)
ACPI: PCI Interrupt Link [LNK5] BIOS reported IRQ 0, using IRQ 11
ACPI: PCI Interrupt Link [LNK5] enabled at IRQ 11
ACPI: PCI Interrupt 0000:00:0f.2[A] -> Link [LNK5] -> GSI 11 (level, low) -> IRQ 11
ohci_hcd 0000:00:0f.2: OHCI Host Controller
ohci_hcd 0000:00:0f.2: new USB bus registered, assigned bus number 1
ohci_hcd 0000:00:0f.2: irq 11, io mem 0xf5000000
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 4 ports detected
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
ACPI: Power Button (FF) [PWRF]
ACPI: Power Button (CM) [PWRB]
ibm_acpi: ec object not found
EXT3 FS on sda1, internal journal
device-mapper: 4.4.0-ioctl (2005-01-12) initialised: dm-devel@redhat.com
program dmraid is using a deprecated SCSI ioctl, please convert it to SG_IO
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda3, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
kjournald starting.  Commit interval 5 seconds
EXT3 FS on sda5, internal journal
EXT3-fs: mounted filesystem with ordered data mode.
Adding 1052248k swap on /dev/sda2.  Priority:-1 extents:1 across:1052248k
ip_tables: (C) 2000-2002 Netfilter core team
ip_conntrack version 2.4 (8192 buckets, 65536 max) - 212 bytes per conntrack
e1000: eth0: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex
e1000: eth1: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex
e1000: eth1: e1000_watchdog_task: NIC Link is Up 100 Mbps Full Duplex
loop: loaded (max 8 devices)
TCP: Treason uncloaked! Peer 80.72.16.78:50766/80 shrinks window 2092777962:2092777963. Repaired.
TCP: Treason uncloaked! Peer 80.72.16.78:50769/80 shrinks window 2096690385:2096690386. Repaired.
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/core/stream.c (279)
KERNEL: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)

--------------000004050601010005050401
Content-Type: text/plain;
 name="ip_route_show"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ip_route_show"

83.102.130.172/30 dev eth0  proto kernel  scope link  src 83.102.130.174 
83.102.130.176/30 dev eth1  proto kernel  scope link  src 83.102.130.178 
169.254.0.0/16 dev eth1  scope link 
default via 83.102.130.177 dev eth1 

--------------000004050601010005050401
Content-Type: text/plain;
 name="iptables"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="iptables"

Chain INPUT (policy DROP)
target     prot opt source               destination         
DROP       all  --  212.176.84.130       0.0.0.0/0           
ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           limit: avg 100/sec burst 5 
ACCEPT     udp  --  0.0.0.0/0            0.0.0.0/0           
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           
DROP       all  --  127.0.0.1            0.0.0.0/0           
DROP       all  --  0.0.0.0/0            127.0.0.1           
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:22 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:25 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:80 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:3690 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpt:5432 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           multiport dports 20,21 
ACCEPT     tcp  --  0.0.0.0/0            0.0.0.0/0           tcp dpts:64000:65500 
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state ESTABLISHED 

Chain FORWARD (policy DROP)
target     prot opt source               destination         

Chain OUTPUT (policy DROP)
target     prot opt source               destination         
DROP       all  --  0.0.0.0/0            212.176.84.130      
ACCEPT     icmp --  0.0.0.0/0            0.0.0.0/0           limit: avg 100/sec burst 5 
ACCEPT     udp  --  0.0.0.0/0            0.0.0.0/0           
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state ESTABLISHED 
ACCEPT     all  --  0.0.0.0/0            0.0.0.0/0           state NEW 

--------------000004050601010005050401
Content-Type: text/plain;
 name="lspci_vv"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lspci_vv"

00:00.0 Host bridge: Broadcom CMIC-LE Host Bridge (GC-LE chipset) (rev 33)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:00.1 Host bridge: Broadcom CMIC-LE Host Bridge (GC-LE chipset)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:00.2 Host bridge: Broadcom CMIC-LE Host Bridge (GC-LE chipset)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:02.0 Ethernet controller: Intel Corporation 82540EM Gigabit Ethernet Controller (rev 02)
	Subsystem: Intel Corporation 82540EM Gigabit Ethernet Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (63750ns min), Cache Line Size 08
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at f7000000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at d800 [size=64]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=0 OST=0
		Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=2, DMOST=0, DMCRS=1, RSCEM-
	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000

00:03.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27) (prog-if 00 [VGA])
	Subsystem: ATI Technologies Inc Rage XL
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (2000ns min), Cache Line Size 08
	Interrupt: pin A routed to IRQ 10
	Region 0: Memory at f6000000 (32-bit, non-prefetchable) [size=16M]
	Region 1: I/O ports at d400 [size=256]
	Region 2: Memory at f5800000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at febe0000 [disabled] [size=128K]
	Capabilities: [5c] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:0f.0 ISA bridge: Broadcom CSB5 South Bridge (rev 93)
	Subsystem: Broadcom CSB5 South Bridge
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 32

00:0f.1 IDE interface: Broadcom CSB5 IDE Controller (rev 93) (prog-if 8a [Master SecP PriP])
	Subsystem: Broadcom CSB5 IDE Controller
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, Cache Line Size 08
	Region 0: I/O ports at <ignored>
	Region 1: I/O ports at <ignored>
	Region 2: I/O ports at <ignored>
	Region 3: I/O ports at <ignored>
	Region 4: I/O ports at a800 [size=16]

00:0f.2 USB Controller: Broadcom OSB4/CSB5 OHCI USB Controller (rev 05) (prog-if 10 [OHCI])
	Subsystem: Broadcom OSB4/CSB5 OHCI USB Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (20000ns max), Cache Line Size 08
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at f5000000 (32-bit, non-prefetchable) [size=4K]

00:0f.3 Host bridge: Broadcom CSB5 LPC bridge
	Subsystem: Broadcom: Unknown device 0230
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:11.0 Host bridge: Broadcom CIOB-X2 PCI-X I/O Bridge (rev 05)
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr+ DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Capabilities: [60] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=0 OST=4
		Status: Bus=0 Dev=0 Func=0 64bit+ 133MHz+ SCD- USC-, DC=bridge, DMMRBC=0, DMOST=4, DMCRS=0, RSCEM-

00:11.2 Host bridge: Broadcom CIOB-X2 PCI-X I/O Bridge (rev 05)
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr+ DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Capabilities: [60] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=0 OST=4
		Status: Bus=0 Dev=0 Func=0 64bit+ 133MHz+ SCD- USC-, DC=bridge, DMMRBC=0, DMOST=4, DMCRS=0, RSCEM-

01:02.0 Ethernet controller: Intel Corporation 82544GC Gigabit Ethernet Controller (LOM) (rev 02)
	Subsystem: Intel Corporation 82544GC Based Network Connection
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (63750ns min), Cache Line Size 08
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at f4800000 (32-bit, non-prefetchable) [size=128K]
	Region 1: Memory at f4000000 (32-bit, non-prefetchable) [size=128K]
	Region 2: I/O ports at a400 [size=32]
	Expansion ROM at feae0000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=0 OST=0
		Status: Bus=0 Dev=0 Func=0 64bit+ 133MHz+ SCD- USC-, DC=simple, DMMRBC=2, DMOST=0, DMCRS=1, RSCEM-
	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000

01:03.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID (rev 01)
	Subsystem: LSI Logic / Symbios Logic MegaRAID ZCR SCSI 320-0 Controller
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 32, Cache Line Size 08
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f8000000 (32-bit, prefetchable) [size=64M]
	[virtual] Expansion ROM at c4000000 [disabled] [size=32K]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-


--------------000004050601010005050401--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
