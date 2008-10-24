From: David Miller <davem@davemloft.net>
Subject: Re: PROBLEM: too much RX drop packets on kernel 2.6.26 and 2.6.27.x
Date: Fri, 24 Oct 2008 02:05:34 -0700 (PDT)
Message-ID: <20081024.020534.193703548.davem@davemloft.net>
References: <11610630312.20081024130007@nx.uz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: lost@nx.uz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45219
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750778AbYJXJF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 05:05:57 -0400
In-Reply-To: <11610630312.20081024130007@nx.uz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Terleev Roman <lost@nx.uz>
Date: Fri, 24 Oct 2008 13:00:07 +0500

netdev is the correct place to report networking bugs, added to
the CC:

> hello, linux-kernel.
> 
> [1.] One line summary of the problem:
> too much RX drop packets
> 
> [2.] Full description of the problem/report:
> "Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit
> Ethernet controller" - network is up and working, but too much more drop
> packets:
> 
> working int:
> #ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:1F:D0:5C:1A:5A  
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:7323 errors:0 dropped:7564458177891 overruns:0 frame:0
>           TX packets:8388 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:688493 (672.3 KiB)  TX bytes:5088993 (4.8 MiB)
>           Interrupt:251 Base address:0x4000 
> 
> not active int and network cable unplug:
> #ifconfig eth1
> eth1      Link encap:Ethernet  HWaddr 00:1F:D0:80:06:5E  
>           BROADCAST MULTICAST  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>           Interrupt:250 Base address:0x6000
> 
> then i add ip on eth1:
> [root@wax ~]# ifconfig eth1 40.40.40.1/24 up
> [root@wax ~]# ifconfig eth1
> eth1      Link encap:Ethernet  HWaddr 00:1F:D0:80:06:5E  
>           inet addr:40.40.40.1  Bcast:40.40.40.255  Mask:255.255.255.0
>           UP BROADCAST MULTICAST  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:485645351 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>           Interrupt:250 Base address:0x6000 
> p.s. network cable unplug!!!
> 
> p.p.s. i found old PCI ether card realtek RTL-8129 and compile modules.
> ether working fine and drop packets is "0":
> [root@wax ~]# ifconfig eth2 50.50.50.1/24 up
> [root@wax ~]# ifconfig eth2
> eth2      Link encap:Ethernet  HWaddr 00:00:00:00:00:00  
>           inet addr:50.50.50.1  Bcast:50.50.50.255  Mask:255.255.255.0
>           BROADCAST MULTICAST  MTU:1500  Metric:1
>           RX packets:0 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000 
>           RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
>           Interrupt:5 Base address:0xd000
> 
> if i use default kernel: 2.6.25-14.fc9.x86_64 - link up, but any
> packets reject.
>           
> [3.] Keywords (i.e., modules, networking, kernel):
> modules
> 
> [4.] Kernel version (from):
> #cat /proc/version
> Linux version 2.6.27.3 (root@wax.infonet.uz) (gcc version 4.3.0 20080428 (Red Hat 4.3.0-8) (GCC) ) #6 SMP Thu Oct 23 19:39:33 UZT 2008
> 
> 
> [5.] Output of Oops.. message (if applicable) with symbolic information 
>      resolved (see Documentation/oops-tracing.txt)
> no information
> 
> [6.] A small shell script or example program which triggers the
>      problem (if possible)
> no information
> 
> [7.] Environment
> no information
> 
> [7.1.] Software (add the output of the ver_linux script here)
> ./ver_linux
> If some fields are empty or look unusual you may have an old version.
> Compare to the current minimal requirements in Documentation/Changes.
>  
> Linux wax.infonet.uz 2.6.27.3 #6 SMP Thu Oct 23 19:39:33 UZT 2008 x86_64 x86_64 x86_64 GNU/Linux
> 
> Gnu C                  4.3.0
> Gnu make               3.81
> binutils               2.18.50.0.6
> util-linux             2.13.1
> mount                  2.13.1
> module-init-tools      3.4
> e2fsprogs              1.40.8
> reiserfsprogs          3.6.19
> pcmciautils            014
> quota-tools            3.15.
> PPP                    2.4.4
> isdn4k-utils           3.9
> Linux C Library        2.8
> Dynamic linker (ldd)   2.8
> Procps                 3.2.7
> Net-tools              1.60
> Kbd                    1.12
> Sh-utils               6.10
> udev                   120
> wireless-tools         29
> Modules Loaded 8021q reiserfs loop dm_multipath i2c_i801 pata_jmicron
> rtc_cmos intel_agp rtc_core pcspkr 8139too i2c_core sg button rtc_lib
> r8169 mii dm_snapshot dm_zero dm_mirror dm_log dm_mod ata_piix
> ata_generic pata_acpi libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd
> ohci_hcd ehci_hcd
> 
> [7.2.] Processor information (from /proc/cpuinfo):
> cat /proc/cpuinfo
> processor       : 0
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Core(TM)2 Quad CPU    Q9400  @ 2.66GHz
> stepping        : 10
> cpu MHz         : 2666.344
> cache size      : 3072 KB
> physical id     : 0
> siblings        : 4
> core id         : 0
> cpu cores       : 4
> apicid          : 0
> initial apicid  : 0
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 13
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good nopl pni monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr sse4_1 lahf_lm
> bogomips        : 5332.68
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 48 bits virtual
> power management:
> 
> processor       : 1
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Core(TM)2 Quad CPU    Q9400  @ 2.66GHz
> stepping        : 10
> cpu MHz         : 2666.344
> cache size      : 3072 KB
> physical id     : 0
> siblings        : 4
> core id         : 1
> cpu cores       : 4
> apicid          : 1
> initial apicid  : 1
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 13
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good nopl pni monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr sse4_1 lahf_lm
> bogomips        : 5332.52
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 48 bits virtual
> power management:
> 
> processor       : 2
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Core(TM)2 Quad CPU    Q9400  @ 2.66GHz
> stepping        : 10
> cpu MHz         : 2666.344
> cache size      : 3072 KB
> physical id     : 0
> siblings        : 4
> core id         : 3
> cpu cores       : 4
> apicid          : 3
> initial apicid  : 3
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 13
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good nopl pni monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr sse4_1 lahf_lm
> bogomips        : 5332.54
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 48 bits virtual
> power management:
> 
> processor       : 3
> vendor_id       : GenuineIntel
> cpu family      : 6
> model           : 23
> model name      : Intel(R) Core(TM)2 Quad CPU    Q9400  @ 2.66GHz
> stepping        : 10
> cpu MHz         : 2666.344
> cache size      : 3072 KB
> physical id     : 0
> siblings        : 4
> core id         : 2
> cpu cores       : 4
> apicid          : 2
> initial apicid  : 2
> fpu             : yes
> fpu_exception   : yes
> cpuid level     : 13
> wp              : yes
> flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx lm constant_tsc arch_perfmon pebs bts rep_good nopl pni monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr sse4_1 lahf_lm
> bogomips        : 5332.54
> clflush size    : 64
> cache_alignment : 64
> address sizes   : 36 bits physical, 48 bits virtual
> power management:
> 
> [7.3.] Module information (from /proc/modules):
> cat /proc/modules
> 8021q 24080 0 - Live 0xffffffffa0172000
> reiserfs 227544 1 - Live 0xffffffffa0139000
> loop 18572 0 - Live 0xffffffffa0133000
> dm_multipath 18840 0 - Live 0xffffffffa012d000
> i2c_i801 13724 0 - Live 0xffffffffa0128000
> pata_jmicron 8064 0 - Live 0xffffffffa0125000
> rtc_cmos 14776 0 - Live 0xffffffffa0120000
> intel_agp 32112 0 - Live 0xffffffffa0117000
> rtc_core 20148 1 rtc_cmos, Live 0xffffffffa0111000
> pcspkr 6912 0 - Live 0xffffffffa010c000
> 8139too 29184 0 - Live 0xffffffffa0101000
> i2c_core 25248 1 i2c_i801, Live 0xffffffffa00f7000
> sg 36176 0 - Live 0xffffffffa00ed000
> button 11680 0 - Live 0xffffffffa00e7000
> rtc_lib 6912 1 rtc_core, Live 0xffffffffa00e4000
> r8169 32388 0 - Live 0xffffffffa00db000
> mii 8960 1 8139too, Live 0xffffffffa00d7000
> dm_snapshot 20552 0 - Live 0xffffffffa00d0000
> dm_zero 6144 0 - Live 0xffffffffa00cd000
> dm_mirror 21376 0 - Live 0xffffffffa00c6000
> dm_log 13572 1 dm_mirror, Live 0xffffffffa00c1000
> dm_mod 56928 10 dm_multipath,dm_snapshot,dm_zero,dm_mirror,dm_log, Live 0xffffffffa00b2000
> ata_piix 24324 6 - Live 0xffffffffa00ab000
> ata_generic 9860 0 - Live 0xffffffffa00a7000
> pata_acpi 8960 0 - Live 0xffffffffa00a3000
> libata 155040 4 pata_jmicron,ata_piix,ata_generic,pata_acpi, Live 0xffffffffa007c000
> sd_mod 30632 7 - Live 0xffffffffa0073000
> scsi_mod 149336 3 sg,libata,sd_mod, Live 0xffffffffa004d000
> ext3 125712 5 - Live 0xffffffffa002d000
> jbd 50984 1 ext3, Live 0xffffffffa001f000
> mbcache 12164 1 ext3, Live 0xffffffffa001b000
> uhci_hcd 26400 0 - Live 0xffffffffa0013000
> ohci_hcd 27292 0 - Live 0xffffffffa000b000
> ehci_hcd 37900 0 - Live 0xffffffffa0000000
> 
> [7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
> cat /proc/ioports
> 0000-001f : dma1
> 0020-0021 : pic1
> 0040-0043 : timer0
> 0050-0053 : timer1
> 0060-0060 : keyboard
> 0064-0064 : keyboard
> 0070-0073 : rtc0
> 0080-008f : dma page reg
> 00a0-00a1 : pic2
> 00c0-00df : dma2
> 00f0-00ff : fpu
> 0170-0177 : 0000:00:1f.2
>   0170-0177 : ata_piix
> 01f0-01f7 : 0000:00:1f.2
>   01f0-01f7 : ata_piix
> 0290-029f : pnp 00:01
>   0290-0294 : pnp 00:01
> 0376-0376 : 0000:00:1f.2
>   0376-0376 : ata_piix
> 03c0-03df : vga+
> 03f6-03f6 : 0000:00:1f.2
>   03f6-03f6 : ata_piix
> 03f8-03ff : serial
> 0400-04bf : pnp 00:09
>   0400-0403 : ACPI PM1a_EVT_BLK
>   0404-0405 : ACPI PM1a_CNT_BLK
>   0408-040b : ACPI PM_TMR
>   0410-0415 : ACPI CPU throttle
>   0420-042f : ACPI GPE0_BLK
> 04d0-04d1 : pnp 00:01
> 0500-051f : 0000:00:1f.3
>   0500-051f : i801_smbus
> 0800-087f : pnp 00:01
> 0880-088f : pnp 00:01
> 0cf8-0cff : PCI conf1
> a000-afff : PCI Bus 0000:02
>   a000-a007 : 0000:02:00.0
>     a000-a007 : pata_jmicron
>   a100-a103 : 0000:02:00.0
>     a100-a103 : pata_jmicron
>   a200-a207 : 0000:02:00.0
>     a200-a207 : pata_jmicron
>   a300-a303 : 0000:02:00.0
>     a300-a303 : pata_jmicron
>   a400-a40f : 0000:02:00.0
>     a400-a40f : pata_jmicron
> b000-bfff : PCI Bus 0000:03
>   b000-b0ff : 0000:03:00.0
>     b000-b0ff : r8169
> c000-cfff : PCI Bus 0000:04
>   c000-c0ff : 0000:04:00.0
>     c000-c0ff : r8169
> d000-dfff : PCI Bus 0000:05
>   d000-d0ff : 0000:05:00.0
>     d000-d0ff : 8139too
> e000-e01f : 0000:00:1a.1
>   e000-e01f : uhci_hcd
> e100-e11f : 0000:00:1a.2
>   e100-e11f : uhci_hcd
> e200-e21f : 0000:00:1d.0
>   e200-e21f : uhci_hcd
> e300-e31f : 0000:00:1d.1
>   e300-e31f : uhci_hcd
> e400-e41f : 0000:00:1d.2
>   e400-e41f : uhci_hcd
> e500-e51f : 0000:00:1a.0
>   e500-e51f : uhci_hcd
> e700-e707 : 0000:00:1f.5
>   e700-e707 : ata_piix
> e800-e803 : 0000:00:1f.5
>   e800-e803 : ata_piix
> e900-e907 : 0000:00:1f.5
>   e900-e907 : ata_piix
> ea00-ea03 : 0000:00:1f.5
>   ea00-ea03 : ata_piix
> eb00-eb0f : 0000:00:1f.5
>   eb00-eb0f : ata_piix
> ec00-ec0f : 0000:00:1f.5
>   ec00-ec0f : ata_piix
> f000-f00f : 0000:00:1f.2
>   f000-f00f : ata_piix
> f100-f10f : 0000:00:1f.2
>   f100-f10f : ata_piix
> 
> cat /proc/iomem
> 00000000-0009f7ff : System RAM
> 0009f800-0009ffff : reserved
> 000f0000-000fffff : reserved
> 00100000-efedffff : System RAM
>   00200000-0043f7ad : Kernel code
>   0043f7ae-005a11ef : Kernel data
>   00b1f000-00b92867 : Kernel bss
> efee0000-efee2fff : ACPI Non-volatile Storage
> efee3000-efeeffff : ACPI Tables
> efef0000-efefffff : reserved
> f0000000-f3ffffff : PCI MMCONFIG 0
>   f0000000-f3ffffff : reserved
> f4000000-f4ffffff : PCI Bus 0000:02
> f5000000-f5ffffff : PCI Bus 0000:03
> f6000000-f6ffffff : PCI Bus 0000:04
> f7000000-f8ffffff : PCI Bus 0000:05
>   f7000000-f7ffffff : 0000:05:01.0
>   f8000000-f80000ff : 0000:05:00.0
>     f8000000-f80000ff : 8139too
> f9000000-f9ffffff : PCI Bus 0000:05
>   f9000000-f9ffffff : 0000:05:01.0
> fa000000-fa0fffff : PCI Bus 0000:03
>   fa000000-fa00ffff : 0000:03:00.0
>     fa000000-fa00ffff : r8169
>   fa010000-fa010fff : 0000:03:00.0
>     fa010000-fa010fff : r8169
>   fa020000-fa02ffff : 0000:03:00.0
> fa100000-fa1fffff : PCI Bus 0000:04
>   fa100000-fa10ffff : 0000:04:00.0
>     fa100000-fa10ffff : r8169
>   fa110000-fa110fff : 0000:04:00.0
>     fa110000-fa110fff : r8169
>   fa120000-fa12ffff : 0000:04:00.0
> fa200000-fa2003ff : 0000:00:1a.7
>   fa200000-fa2003ff : ehci_hcd
> fa201000-fa2013ff : 0000:00:1d.7
>   fa201000-fa2013ff : ehci_hcd
> fa202000-fa2020ff : 0000:00:1f.3
> fec00000-ffffffff : reserved
>   fed00000-fed003ff : HPET 0
>   fee00000-fee00fff : Local APIC
> 100000000-10fffffff : System RAM
> 
> [7.5.] PCI information ('lspci -vvv' as root)
> see attach "lspci.txt"
> 
> [7.6.] SCSI information (from /proc/scsi/scsi)
> cat /proc/scsi/scsi
> Attached devices:
> Host: scsi1 Channel: 00 Id: 00 Lun: 00
>   Vendor: ATA      Model: SAMSUNG HD161HJ  Rev: JF10
>   Type:   Direct-Access                    ANSI  SCSI revision: 05
> 
> [7.7.] Other information that might be relevant to the problem
>        (please look in /proc and include all information that you
>        think to be relevant):
> no information
> 
> [X.] Other notes, patches, fixes, workarounds:
> no information
> 
> -- 
>  Terleev                          mailto:lost@nx.uz
