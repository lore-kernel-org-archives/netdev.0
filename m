From: Ken Sharp <imwellcushtymelike@googlemail.com>
Subject: wakeonlan fails if pm-hibernate used
Date: Sun, 24 Nov 2013 07:09:24 +0000
Message-ID: <5291A624.3040507@googlemail.com>
References: <52039A0D.1000906@o2.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 1074110@bugs.launchpad.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f181.google.com ([74.125.82.181]:58416 "EHLO
	mail-we0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752257Ab3KXHJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 02:09:28 -0500
Received: by mail-we0-f181.google.com with SMTP id x55so2568789wes.26
        for <netdev@vger.kernel.org>; Sat, 23 Nov 2013 23:09:27 -0800 (PST)
In-Reply-To: <52039A0D.1000906@o2.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forwarding as per https://bugzilla.kernel.org/show_bug.cgi?id=65361#c1

On 08/08/13 14:15, Ken Sharp wrote:
> wakeonlan fails if pm-hibernate used
>
> After issuing halt -p, wakeonlan works fine. after issuing pm-hibernate,
> the machine will not wake up.
>
> interfaces:
> auto eth0
> iface eth0 inet dhcp
> up ethtool -s eth0 wol g
> down ethtool -s eth0 wol g
>
> Settings for eth0:
>   Supported ports: [ TP MII ]
>   Supported link modes: 10baseT/Half 10baseT/Full
>                           100baseT/Half 100baseT/Full
>   Supported pause frame use: No
>   Supports auto-negotiation: Yes
>   Advertised link modes: 10baseT/Half 10baseT/Full
>                           100baseT/Half 100baseT/Full
>   Advertised pause frame use: No
>   Advertised auto-negotiation: Yes
>   Link partner advertised link modes: 10baseT/Half 10baseT/Full
>                                        100baseT/Half 100baseT/Full
>   Link partner advertised pause frame use: Symmetric
>   Link partner advertised auto-negotiation: Yes
>   Speed: 100Mb/s
>   Duplex: Full
>   Port: MII
>   PHYAD: 32
>   Transceiver: internal
>   Auto-negotiation: on
>   Supports Wake-on: pumbg
>   Wake-on: g
>   Current message level: 0x00000007 (7)
>            drv probe link
>   Link detected: yes
>
> 01:03.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10
>
> Reported on Launchpad
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1074110
>
> $ cat /proc/version
> Linux version 3.11.0-999-generic (apw@gomeisa) (gcc version 4.6.3
> (Ubuntu/Linaro 4.6.3-1ubuntu5) ) #201308070514 SMP Wed Aug 7 09:24:40
> UTC 2013
>
> $ lsb_release -rd
> Description:    Ubuntu 12.04.2 LTS
> Release:    12.04
>
> $ ./ver_linux
> If some fields are empty or look unusual you may have an old version.
> Compare to the current minimal requirements in Documentation/Changes.
>
> Linux oldhomeserver 3.11.0-999-generic #201308070514 SMP Wed Aug 7
> 09:24:40 UTC 2013 i686 i686 i386 GNU/Linux
>
> Gnu C                  4.6
> Gnu make               3.81
> binutils               2.22
> util-linux             2.20.1
> mount                  support
> module-init-tools      3.16
> e2fsprogs              1.42
> pcmciautils            018
> Linux C Library        2.15
> Dynamic linker (ldd)   2.15
> Procps                 3.2.8
> Net-tools              1.60
> Kbd                    1.15.2
> Sh-utils               8.13
> Modules Loaded         zram dm_crypt nfsd nfs_acl auth_rpcgss nfs
> fscache lockd binfmt_misc sunrpc gpio_ich lpc_ich serio_raw shpchp
> intel_rng mac_hid hwmon_vid lp parport 8139too 8139cp mii
>
> $ cat /proc/cpuinfo
> processor    : 0
> vendor_id    : GenuineIntel
> cpu family    : 6
> model        : 8
> model name    : Pentium III (Coppermine)
> stepping    : 3
> microcode    : 0x10
> cpu MHz        : 734.956
> cache size    : 256 KB
> fdiv_bug    : no
> f00f_bug    : no
> coma_bug    : no
> fpu        : yes
> fpu_exception    : yes
> cpuid level    : 2
> wp        : yes
> flags        : fpu vme de pse tsc msr pae mce cx8 sep mtrr pge mca cmov
> pse36 mmx fxsr sse
> bogomips    : 1469.91
> clflush size    : 32
> cache_alignment    : 32
> address sizes    : 36 bits physical, 32 bits virtual
> power management:
>
> $ cat /proc/modules
> zram 18166 1 - Live 0x00000000 (C)
> dm_crypt 22524 0 - Live 0x00000000
> nfsd 246709 13 - Live 0x00000000
> nfs_acl 12771 1 nfsd, Live 0x00000000
> auth_rpcgss 49253 1 nfsd, Live 0x00000000
> nfs 162863 0 - Live 0x00000000
> fscache 52016 1 nfs, Live 0x00000000
> lockd 79198 2 nfsd,nfs, Live 0x00000000
> binfmt_misc 17268 1 - Live 0x00000000
> sunrpc 236600 23 nfsd,nfs_acl,auth_rpcgss,nfs,lockd, Live 0x00000000
> gpio_ich 13278 0 - Live 0x00000000
> lpc_ich 16987 0 - Live 0x00000000
> serio_raw 13189 0 - Live 0x00000000
> shpchp 32265 0 - Live 0x00000000
> intel_rng 12700 0 - Live 0x00000000
> mac_hid 13077 0 - Live 0x00000000
> hwmon_vid 12723 0 - Live 0x00000000
> lp 13359 0 - Live 0x00000000
> parport 40930 1 lp, Live 0x00000000
> 8139too 32770 0 - Live 0x00000000
> 8139cp 27168 0 - Live 0x00000000
> mii 13693 2 8139too,8139cp, Live 0x00000000
>
> $ cat /proc/ioports
> 0000-001f : dma1
> 0020-0021 : pic1
> 0040-0043 : timer0
> 0050-0053 : timer1
> 0060-0060 : keyboard
> 0064-0064 : keyboard
> 0070-0071 : rtc0
> 0080-008f : dma page reg
> 00a0-00a1 : pic2
> 00c0-00df : dma2
> 00f0-00ff : fpu
> 0170-0177 : 0000:00:1f.1
>    0170-0177 : ata_piix
> 01f0-01f7 : 0000:00:1f.1
>    01f0-01f7 : ata_piix
> 0376-0376 : 0000:00:1f.1
>    0376-0376 : ata_piix
> 03c0-03df : vga+
> 03f6-03f6 : 0000:00:1f.1
>    03f6-03f6 : ata_piix
> 0400-0403 : ACPI PM1a_EVT_BLK
> 0404-0405 : ACPI PM1a_CNT_BLK
> 0408-040b : ACPI PM_TMR
> 0410-0415 : ACPI CPU throttle
> 0428-042b : ACPI GPE0_BLK
> 042c-042f : ACPI GPE1_BLK
> 0430-0433 : iTCO_wdt
> 0460-047f : iTCO_wdt
> 0480-04bf : gpio_ich
>    0480-04bf : 0000:00:1f.0
> 04c0-04cf : 0000:00:1f.3
> 0cf8-0cff : PCI conf1
> c000-cfff : PCI Bus 0000:01
>    cc00-ccff : 0000:01:03.0
>      cc00-ccff : 8139too
> de00-de1f : 0000:00:1f.2
>    de00-de1f : uhci_hcd
> ff00-ff0f : 0000:00:1f.1
>    ff00-ff0f : ata_piix
>
> $ cat /proc/iomem
> 00000000-00000fff : reserved
> 00001000-0009fbff : System RAM
> 0009fc00-0009ffff : reserved
> 000a0000-000bffff : Video RAM area
> 000c0000-000c7fff : Video ROM
> 000e0000-000fffff : reserved
>    000f0000-000fffff : System ROM
> 00100000-0beeffff : System RAM
>    01000000-016680a2 : Kernel code
>    016680a3-019bd17f : Kernel data
>    01aa1000-01b94fff : Kernel bss
> 0bef0000-0bef7fff : ACPI Tables
> 0bef8000-0befffff : ACPI Non-volatile Storage
> 0bf00000-0bffffff : reserved
> dfc00000-dfcfffff : PCI Bus 0000:01
> e0000000-e3ffffff : 0000:00:01.0
> e7e00000-ebefffff : PCI Bus 0000:01
>    e8000000-e80000ff : 0000:01:03.0
>      e8000000-e80000ff : 8139too
> ee000000-ee07ffff : 0000:00:01.0
> fff80000-ffffffff : reserved
>
> $ sudo lspci -vvv
> 00:00.0 Host bridge: Intel Corporation 82810E DC-133 (GMCH) Graphics
> Memory Controller Hub (rev 03)
>      Subsystem: Intel Corporation 82810E DC-133 (GMCH) Graphics Memory
> Controller Hub
>      Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort+ >SERR- <PERR- INTx-
>      Latency: 0
>      Kernel driver in use: agpgart-intel
>
> 00:01.0 VGA compatible controller: Intel Corporation 82810E DC-133 (CGC)
> Chipset Graphics Controller (rev 03) (prog-if 00 [VGA controller])
>      Subsystem: Giga-byte Technology Device 0200
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>      Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Interrupt: pin A routed to IRQ 11
>      Region 0: Memory at e0000000 (32-bit, prefetchable) [size=64M]
>      Region 1: Memory at ee000000 (32-bit, non-prefetchable) [size=512K]
>      Expansion ROM at <unassigned> [disabled]
>      Capabilities: [dc] Power Management version 1
>          Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
> PME(D0-,D1-,D2-,D3hot-,D3cold-)
>          Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>
> 00:1e.0 PCI bridge: Intel Corporation 82801AA PCI Bridge (rev 02)
> (prog-if 00 [Normal decode])
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
>      I/O behind bridge: 0000c000-0000cfff
>      Memory behind bridge: e7e00000-ebefffff
>      Prefetchable memory behind bridge: dfc00000-dfcfffff
>      Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- <SERR- <PERR-
>      BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-
>          PriDiscTmr- SecDiscTmr- DiscTmrStat- DiscTmrSERREn-
>      Kernel modules: shpchp
>
> 00:1f.0 ISA bridge: Intel Corporation 82801AA ISA Bridge (LPC) (rev 02)
>      Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Kernel driver in use: lpc_ich
>      Kernel modules: lpc_ich, intel-rng
>
> 00:1f.1 IDE interface: Intel Corporation 82801AA IDE Controller (rev 02)
> (prog-if 80 [Master])
>      Subsystem: Intel Corporation 82801AA IDE Controller
>      Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Region 0: [virtual] Memory at 000001f0 (32-bit, non-prefetchable)
> [size=8]
>      Region 1: [virtual] Memory at 000003f0 (type 3, non-prefetchable)
> [size=1]
>      Region 2: [virtual] Memory at 00000170 (32-bit, non-prefetchable)
> [size=8]
>      Region 3: [virtual] Memory at 00000370 (type 3, non-prefetchable)
> [size=1]
>      Region 4: I/O ports at ff00 [size=16]
>      Kernel driver in use: ata_piix
>
> 00:1f.2 USB controller: Intel Corporation 82801AA USB Controller (rev
> 02) (prog-if 00 [UHCI])
>      Subsystem: Intel Corporation 82801AA USB Controller
>      Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 0
>      Interrupt: pin D routed to IRQ 10
>      Region 4: I/O ports at de00 [size=32]
>      Kernel driver in use: uhci_hcd
>
> 00:1f.3 SMBus: Intel Corporation 82801AA SMBus Controller (rev 02)
>      Subsystem: Intel Corporation 82801AA SMBus Controller
>      Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR- FastB2B- DisINTx-
>      Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Interrupt: pin B routed to IRQ 0
>      Region 4: I/O ports at 04c0 [size=16]
>      Kernel modules: i2c-i801
>
> 01:03.0 Ethernet controller: Realtek Semiconductor Co., Ltd.
> RTL-8139/8139C/8139C+ (rev 10)
>      Subsystem: Realtek Semiconductor Co., Ltd. RTL-8139/8139C/8139C+
>      Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr-
> Stepping- SERR+ FastB2B- DisINTx-
>      Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort-
> <TAbort- <MAbort- >SERR- <PERR- INTx-
>      Latency: 64 (8000ns min, 16000ns max)
>      Interrupt: pin A routed to IRQ 11
>      Region 0: I/O ports at cc00 [size=256]
>      Region 1: Memory at e8000000 (32-bit, non-prefetchable) [size=256]
>      Capabilities: [50] Power Management version 2
>          Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=375mA
> PME(D0-,D1+,D2+,D3hot+,D3cold+)
>          Status: D0 NoSoftRst- PME-Enable- DSel=0 DScale=0 PME-
>      Kernel driver in use: 8139too
>      Kernel modules: 8139too, 8139cp
>
> $ cat /proc/scsi/scsi
> Attached devices:
> Host: scsi0 Channel: 00 Id: 01 Lun: 00
>    Vendor: ATA      Model: QUANTUM FIREBALL Rev: A01.
>    Type:   Direct-Access                    ANSI  SCSI revision: 05
> Host: scsi1 Channel: 00 Id: 00 Lun: 00
>    Vendor: GoldStar Model: CD-RW CED-8080B  Rev: 1.02
>    Type:   CD-ROM
>
> $ ls /proc
> 1     1026  1406  1471  16    19   25   42   6    695  9 cpuinfo
> fs          kpagecount     mounts        slabinfo       tty
> 10    11    1461  1472  1641  2    26   44   619  7    986        crypto
>        interrupts  kpageflags     mtrr          softirqs       uptime
> 1005  1110  1462  1473  1642  20   27   45   64   709  991 devices
> iomem       latency_stats  net           stat           version
> 1006  12    1463  1477  17    21   28   467  65   731  acpi diskstats
> ioports     loadavg        pagetypeinfo  swaps vmallocinfo
> 1008  13    1466  1499  18    22   3    468  654  793  buddyinfo  dma
>         irq         locks          partitions    sys            vmstat
> 1013  1373  1467  15    1844  224  324  5    657  797  bus        driver
>        kallsyms    mdstat         sched_debug   sysrq-trigger  zoneinfo
> 1014  14    1468  1515  1859  225  326  579  666  8    cgroups
> execdomains  kcore       meminfo        schedstat     sysvipc
> 1021  1401  1469  1535  1867  23   39   584  67   856  cmdline    fb
>         key-users   misc           scsi          timer_list
> 1023  1405  1470  1541  1868  24   41   586  694  895  consoles
> filesystems  kmsg        modules        self          timer_stats
>
> $ sudo ethtool eth0
> Settings for eth0:
>      Supported ports: [ TP MII ]
>      Supported link modes:   10baseT/Half 10baseT/Full
>                              100baseT/Half 100baseT/Full
>      Supported pause frame use: No
>      Supports auto-negotiation: Yes
>      Advertised link modes:  10baseT/Half 10baseT/Full
>                              100baseT/Half 100baseT/Full
>      Advertised pause frame use: No
>      Advertised auto-negotiation: Yes
>      Link partner advertised link modes:  10baseT/Half 10baseT/Full
>                                           100baseT/Half 100baseT/Full
>      Link partner advertised pause frame use: Symmetric
>      Link partner advertised auto-negotiation: Yes
>      Speed: 100Mb/s
>      Duplex: Full
>      Port: MII
>      PHYAD: 32
>      Transceiver: internal
>      Auto-negotiation: on
>      Supports Wake-on: pumbg
>      Wake-on: g
>      Current message level: 0x00000007 (7)
>                     drv probe link
>      Link detected: yes
>
> Taken as a guide to report this:
> https://wiki.ubuntu.com/Bugs/Upstream/kernel
>
> Apologies if this is too much or not enough information, this is the
> first time I have attempted to report a problem with the kernel.
>
> I looked through https://www.kernel.org/doc/Documentation/power/ but the
> processes either didn't seem relevant or I simply didn't understand. If
> you need me to run through the processes then please let me know.
>
> Specifically
> https://www.kernel.org/doc/Documentation/power/basic-pm-debugging.txt
> suggests that the debugging would test the wake/resume cycle, which I
> don't think is relevant in this case. But I could be wrong!
>
> Thanks for your help,
>
> Ken
