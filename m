From: Gabor Burjan <buga@buvoshetes.hu>
Subject: Re: kernel oops after unloading nf_conntrack_netbios_ns_module
Date: Thu, 10 May 2007 13:01:17 +0200
Message-ID: <20070510110117.GE13059@odin.sis.hu>
References: <20070510090603.GA13059@odin.sis.hu> <20070510033411.6cf042ad.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760446AbXEJLBh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070510033411.6cf042ad.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, May 10, 2007 at 03:34:11AM -0700, Andrew Morton wrote:
> 
> (add netdev to cc)
> 
> On Thu, 10 May 2007 11:06:03 +0200 Gabor Burjan <buga@buvoshetes.hu> wrote:
> 
> > Hi,
> > 
> > [1.] One line summary of the problem:
> > 
> > Kernel oops after unloading nf_conntrack_netbios_ns module
> > 
> > [2.] Full description of the problem/report:
> > 
> > After I remove the netbios-ns conntrack module,the kernel runs into an oops
> > when it tries to delete the appropriate conntrack entry.  The problem is
> > reproducable, see the script below [7.].  My system has a Core2Duo processon,
> > probably this problem is SMP related problem.
> > 
> > [3.] Keywords (i.e., modules, networking, kernel):
> > 
> > modules, networking, netfilter, conntrack, netbios
> > 
> > [4.] Kernel information
> > [4.1.] Kernel version (from /proc/version):
> > 
> > Linux version 2.6.20-1-686 (Debian 2.6.20-3) (waldi@debian.org) (gcc version 4.1.2 20061115 (prerelease) (Debian 4.1.1-21)) #1 SMP Tue Apr 24 21:52:11 UTC 2007
> > 
> > [4.2.] Kernel .config file:
> > 
> > ...
> >
> > [5.] Most recent kernel version which did not have the bug:
> > 
> > Debian 2.6.18-4 (ip_conntrack_netbios_ns module)
> 
> So it's a regression.
> 
> > [6.] Output of Oops.. message (if applicable) with symbolic information
> >      resolved (see Documentation/oops-tracing.txt)
> > 
> >
> > [...]
> 
> ksymoops seems to have gone and hidden the actual EIP decide from us.
> 
> ksymoops is no longer necessary as long as CONFIG_KALLSYMS=y.  Are you able
> to send just the raw oops message from dmesg please?

BUG: unable to handle kernel paging request at virtual address f898b9ec
printing eip:
f89ea20c
*pde = 02100067
*pte = 00000000
Oops: 0000 [#1]
SMP
Modules linked in: ipt_REJECT ipt_LOG xt_tcpudp nf_conntrack_ipv4 xt_state nf_conntrack nfnetlink iptable_filter ip_tables x_tables ext3 jbd mbcache dm_mirror dm_snapshot dm_mod raid10 raid456 xor raid1 raid0 multipath linear md_mod sd_mod ide_cd cdrom usbhid hid ata_generic ata_piix libata scsi_mod piix ehci_hcd uhci_hcd generic floppy ide_core e1000 usbcore thermal processor fan
CPU:    0
EIP:    0060:[<f89ea20c>]    Not tainted VLI
EFLAGS: 00010282   (2.6.20-1-686 #1)
EIP is at destroy_conntrack+0x52/0x127 [nf_conntrack]
eax: f898b980   ebx: c21d7194   ecx: c21d7194   edx: 00000000
esi: c21d7270   edi: f89e9823   ebp: 00000000   esp: c0337f1c
ds: 007b   es: 007b   ss: 0068
Process swapper (pid: 0, ti=c0336000 task=c030d3a0 task.ti=c0336000)
Stack: c23ed140 00000000 f89ea2d8 c23ed140 c0389b00 f89e98a2 00000100 c0128a66
      00000000 c010613e c01465a2 c01082ee c0337f4c c0337f4c 00000021 c032ff48
      0000000a c012538a 00000046 00000000 c0336008 00000008 c0125433 00000000
Call Trace:
[<f89ea2d8>] destroy_conntrack+0x11e/0x127 [nf_conntrack]
[<f89e98a2>] death_by_timeout+0x7f/0x81 [nf_conntrack]
[<c0128a66>] run_timer_softirq+0x107/0x170
[<c010613e>] timer_interrupt+0x65/0x6b
[<c01465a2>] handle_IRQ_event+0x23/0x51
[<c01082ee>] sched_clock+0x3f/0x59
[<c012538a>] __do_softirq+0x66/0xcc
[<c0125433>] do_softirq+0x43/0x51
[<c0113b95>] smp_apic_timer_interrupt+0x74/0x7f
[<c0103800>] apic_timer_interrupt+0x28/0x30
[<c0101240>] mwait_idle_with_hints+0x3b/0x3f
[<c01013af>] cpu_idle+0xb0/0xc9
[<c033b7b1>] start_kernel+0x3f7/0x3ff
[<c033b1b8>] unknown_bootoption+0x0/0x202
=======================
Code: 74 19 8b 43 68 f6 c4 02 75 11 89 d9 ba 04 00 00 00 b8 e4 6e 9f f8 e8 10 22 74 c7 f0 0f ba 6b 68 09 85 f6 74 11 8b 06 85 c0 74 0b <8b> 50 6c 85 d2 74 04 89 d8 ff d2 0f b7 43 52 ba 40 66 9f f8 66
EIP: [<f89ea20c>] destroy_conntrack+0x52/0x127 [nf_conntrack] SS:ESP 0068:c0337f1c
<0>Kernel panic - not syncing: Fatal exception in interrupt
BUG: at arch/i386/kernel/smp.c:547 smp_call_function()
[<c01118de>] smp_call_function+0x66/0x10b
[<c0121778>] printk+0x1b/0x1f
[<c011199e>] smp_send_stop+0x1b/0x36
[<c0120d2b>] panic+0x54/0xf5
[<c01041dc>] die+0x205/0x239
[<c0119363>] do_page_fault+0x45e/0x53b
[<c0118f05>] do_page_fault+0x0/0x53b
[<c02999ac>] error_code+0x7c/0x84
[<f89e9823>] death_by_timeout+0x0/0x81 [nf_conntrack]
[<f89ea20c>] destroy_conntrack+0x52/0x127 [nf_conntrack]
[<f89ea2d8>] destroy_conntrack+0x11e/0x127 [nf_conntrack]
[<f89e98a2>] death_by_timeout+0x7f/0x81 [nf_conntrack]
[<c0128a66>] run_timer_softirq+0x107/0x170
[<c010613e>] timer_interrupt+0x65/0x6b
[<c01465a2>] handle_IRQ_event+0x23/0x51
[<c01082ee>] sched_clock+0x3f/0x59
[<c012538a>] __do_softirq+0x66/0xcc
[<c0125433>] do_softirq+0x43/0x51
[<c0113b95>] smp_apic_timer_interrupt+0x74/0x7f
[<c0103800>] apic_timer_interrupt+0x28/0x30
[<c0101240>] mwait_idle_with_hints+0x3b/0x3f
[<c01013af>] cpu_idle+0xb0/0xc9
[<c033b7b1>] start_kernel+0x3f7/0x3ff
[<c033b1b8>] unknown_bootoption+0x0/0x202
======================= 

> >  [...]
> > 
> > [7.] A small shell script or example program which triggers the
> >      problem (if possible)
> > 
> > after booting with init=/bin/sh (clean environment)
> > 
> > <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> > #!/bin/sh -x
> > 
> > ifconfig eth0 <ip> netmask <netmask>
> > 
> > sleep 5
> > 
> > modprobe nf_conntrack_netbios_ns
> > 
> > sleep 3
> > 
> > iptables -F
> > iptables -P INPUT DROP
> > iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
> > iptables -P OUTPUT ACCEPT
> > 
> > sleep 3
> > 
> > nmblookup <existing_netbios_name>
> > cat /proc/net/ip_conntrack
> > 
> > sleep 3
> > 
> > rmmod nf_conntrack_netbios_ns
> > 
> > watch -n 1 cat /proc/net/ip_conntrack
> > >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
> > 
> > [8.] Environment
> > [8.1.] Software (add the output of the ver_linux script here)
> > 
> > If some fields are empty or look unusual you may have an old version.
> > Compare to the current minimal requirements in Documentation/Changes.
> >  
> >  Linux duplo 2.6.20-1-686 #1 SMP Tue Apr 24 21:52:11 UTC 2007 i686 GNU/Linux
> >   
> >   Gnu C                  4.1.3
> >   Gnu make               3.81
> >   binutils               Binutils
> >   util-linux             2.12r
> >   mount                  2.12r
> >   module-init-tools      3.3-pre2
> >   e2fsprogs              1.40-WIP
> >   Linux C Library        > libc.2.5
> >   Dynamic linker (ldd)   2.5
> >   Procps                 3.2.7
> >   Net-tools              1.60
> >   Kbd                    85:
> >   Sh-utils               5.97
> >   udev                   105
> >   Modules Loaded         nf_conntrack_ipv4 xt_state iptable_filter ip_tables x_tables nf_conntrack_netbios_ns nf_conntrack nfnetlink ext3 jbd mbcache dm_mirror dm_snapshot dm_mod raid10 raid456 xor raid1 raid0 multipath linear md_mod ide_cd cdrom sd_mod ata_generic usbhid hid ata_piix libata scsi_mod piix floppy ehci_hcd uhci_hcd generic ide_core e1000 usbcore thermal processor fan
> > 
> > [8.2.] Processor information (from /proc/cpuinfo):
> > 
> > processor       : 0
> > vendor_id       : GenuineIntel
> > cpu family      : 6
> > model           : 15
> > model name      : Intel(R) Core(TM)2 CPU          6400  @ 2.13GHz
> > stepping        : 6
> > cpu MHz         : 2128.070
> > cache size      : 2048 KB
> > physical id     : 0
> > siblings        : 2
> > core id         : 0
> > cpu cores       : 2
> > fdiv_bug        : no
> > hlt_bug         : no
> > f00f_bug        : no
> > coma_bug        : no
> > fpu             : yes
> > fpu_exception   : yes
> > cpuid level     : 10
> > wp              : yes
> > flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe lm constant_tsc pni monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr lahf_lm
> > bogomips        : 4259.22
> > clflush size    : 64
> > 
> > processor       : 1
> > vendor_id       : GenuineIntel
> > cpu family      : 6
> > model           : 15
> > model name      : Intel(R) Core(TM)2 CPU          6400  @ 2.13GHz
> > stepping        : 6
> > cpu MHz         : 2128.070
> > cache size      : 2048 KB
> > physical id     : 0
> > siblings        : 2
> > core id         : 1
> > cpu cores       : 2
> > fdiv_bug        : no
> > hlt_bug         : no
> > f00f_bug        : no
> > coma_bug        : no
> > fpu             : yes
> > fpu_exception   : yes
> > cpuid level     : 10
> > wp              : yes
> > flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe lm constant_tsc pni monitor ds_cpl vmx est tm2 ssse3 cx16 xtpr lahf_lm
> > bogomips        : 4256.21
> > clflush size    : 64
> > 
> > [8.3.] Module information (from /proc/modules):
> > 
> > Module                  Size  Used by
> > nf_conntrack_ipv4      17772  1 
> > xt_state                2560  1 
> > iptable_filter          3072  1 
> > ip_tables              12324  1 iptable_filter
> > x_tables               14628  2 xt_state,ip_tables
> > nf_conntrack_netbios_ns     3168  0 
> > nf_conntrack           58440  3 nf_conntrack_ipv4,xt_state,nf_conntrack_netbios_ns
> > nfnetlink               6648  2 nf_conntrack_ipv4,nf_conntrack
> > ext3                  121032  1 
> > jbd                    55368  1 ext3
> > mbcache                 8420  1 ext3
> > dm_mirror              20340  0 
> > dm_snapshot            16580  0 
> > dm_mod                 52812  2 dm_mirror,dm_snapshot
> > raid10                 22656  0 
> > raid456               119568  0 
> > xor                    14504  1 raid456
> > raid1                  22144  0 
> > raid0                   8096  0 
> > multipath               8576  0 
> > linear                  5984  0 
> > md_mod                 71860  6 raid10,raid456,raid1,raid0,multipath,linear
> > ide_cd                 36672  0 
> > cdrom                  32960  1 ide_cd
> > sd_mod                 19968  2 
> > ata_generic             7876  0 
> > usbhid                 23136  0 
> > hid                    22784  1 usbhid
> > ata_piix               13860  1 
> > libata                100052  2 ata_generic,ata_piix
> > scsi_mod              133100  2 sd_mod,libata
> > piix                    9540  0 [permanent]
> > floppy                 54468  0 
> > ehci_hcd               29132  0 
> > uhci_hcd               22160  0 
> > generic                 4932  0 [permanent]
> > ide_core              114728  3 ide_cd,piix,generic
> > e1000                 113376  0 
> > usbcore               122312  4 usbhid,ehci_hcd,uhci_hcd
> > thermal                13928  0 
> > processor              30536  1 thermal
> > fan                     4772  0 
> > 
> > [8.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
> > 
> > /proc/ioports:
> > 
> > 0000-001f : dma1
> > 0020-0021 : pic1
> > 0040-0043 : timer0
> > 0050-0053 : timer1
> > 0060-006f : keyboard
> > 0080-008f : dma page reg
> > 00a0-00a1 : pic2
> > 00c0-00df : dma2
> > 00f0-00ff : fpu
> > 0170-0177 : 0000:00:1f.1
> > 01f0-01f7 : 0000:00:1f.1
> >   01f0-01f7 : ide0
> > 0290-0297 : pnp 00:08
> > 0376-0376 : 0000:00:1f.1
> > 03c0-03df : vga+
> > 03f2-03f5 : floppy
> > 03f6-03f6 : 0000:00:1f.1
> >   03f6-03f6 : ide0
> > 03f7-03f7 : floppy DIR
> > 03f8-03ff : serial
> > 0400-041f : 0000:00:1f.3
> >   0410-0415 : ACPI CPU throttle
> > 0480-04bf : 0000:00:1f.0
> > 0800-087f : 0000:00:1f.0
> >   0800-0803 : ACPI PM1a_EVT_BLK
> >   0804-0805 : ACPI PM1a_CNT_BLK
> >   0808-080b : ACPI PM_TMR
> >   0820-0820 : ACPI PM2_CNT_BLK
> >   0828-082f : ACPI GPE0_BLK
> > 0cf8-0cff : PCI conf1
> > 8000-801f : 0000:00:1d.0
> >   8000-801f : uhci_hcd
> > 8400-841f : 0000:00:1d.1
> >   8400-841f : uhci_hcd
> > 8800-881f : 0000:00:1d.2
> >   8800-881f : uhci_hcd
> > 9000-901f : 0000:00:1d.3
> >   9000-901f : uhci_hcd
> > 9400-940f : 0000:00:1f.2
> >   9400-940f : libata
> > 9800-9803 : 0000:00:1f.2
> >   9800-9803 : libata
> > a000-a007 : 0000:00:1f.2
> >   a000-a007 : libata
> > a400-a403 : 0000:00:1f.2
> >   a400-a403 : libata
> > a800-a807 : 0000:00:1f.2
> >   a800-a807 : libata
> > b000-bfff : PCI Bus #01
> > c000-cfff : PCI Bus #02
> >   c800-c81f : 0000:02:00.0
> >     c800-c81f : e1000
> > d000-dfff : PCI Bus #03
> > e000-efff : PCI Bus #04
> > ffa0-ffaf : 0000:00:1f.1
> >   ffa0-ffa7 : ide0
> >   ffa8-ffaf : ide1
> > 
> > iomem:
> > 
> > 00000000-0009fbff : System RAM
> >   00000000-00000000 : Crash kernel
> > 0009fc00-0009ffff : reserved
> > 000a0000-000bffff : Video RAM area
> > 000c0000-000cefff : Video ROM
> > 000f0000-000fffff : System ROM
> > 00100000-7ff9ffff : System RAM
> >   00100000-0029a5e4 : Kernel code
> >   0029a5e5-003353b3 : Kernel data
> > 7ffa0000-7ffadfff : ACPI Tables
> > 7ffae000-7ffdffff : ACPI Non-volatile Storage
> > 7ffe0000-7fffffff : reserved
> > cddf8000-cddfbfff : 0000:00:1b.0
> > cddffc00-cddfffff : 0000:00:1d.7
> >   cddffc00-cddfffff : ehci_hcd
> > cde00000-cdefffff : PCI Bus #02
> >   cdee0000-cdefffff : 0000:02:00.0
> >     cdee0000-cdefffff : e1000
> > cdf00000-cfffffff : PCI Bus #04
> >   cdfe0000-cdffffff : 0000:04:00.0
> >   ce000000-ceffffff : 0000:04:00.0
> >   cf000000-cfffffff : 0000:04:00.0
> > d0000000-dfffffff : PCI Bus #04
> >   d0000000-dfffffff : 0000:04:00.0
> > ffb80000-ffffffff : reserved
> > 
> > [8.5.] PCI information ('lspci -vvv' as root)
> > 
> > 00:00.0 Host bridge: Intel Corporation 82945G/GZ/P/PL Memory Controller Hub (rev 02)
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 817a
> > 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
> > 	Latency: 0
> > 	Capabilities: [e0] Vendor Specific Information
> > 
> > 00:01.0 PCI bridge: Intel Corporation 82945G/GZ/P/PL PCI Express Root Port (rev 02) (prog-if 00 [Normal decode])
> > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0, Cache Line Size: 16 bytes
> > 	Bus: primary=00, secondary=04, subordinate=04, sec-latency=0
> > 	I/O behind bridge: 0000e000-0000efff
> > 	Memory behind bridge: cdf00000-cfffffff
> > 	Prefetchable memory behind bridge: 00000000d0000000-00000000dfffffff
> > 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> > 	BridgeCtl: Parity- SERR+ NoISA- VGA+ MAbort- >Reset- FastB2B-
> > 	Capabilities: [88] Subsystem: Intel Corporation Unknown device 0000
> > 	Capabilities: [80] Power Management version 2
> > 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 	Capabilities: [90] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> > 		Address: fee0300c  Data: 41b9
> > 	Capabilities: [a0] Express Root Port (Slot+) IRQ 0
> > 		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
> > 		Device: Latency L0s <64ns, L1 <1us
> > 		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
> > 		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > 		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
> > 		Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 2
> > 		Link: Latency L0s <256ns, L1 <4us
> > 		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
> > 		Link: Speed 2.5Gb/s, Width x16
> > 		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug- Surpise-
> > 		Slot: Number 0, PowerLimit 75.000000
> > 		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
> > 		Slot: AttnInd Off, PwrInd On, Power-
> > 		Root: Correctable- Non-Fatal- Fatal- PME-
> > 
> > 00:1b.0 Audio device: Intel Corporation 82801G (ICH7 Family) High Definition Audio Controller (rev 01)
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8237
> > 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0, Cache Line Size: 16 bytes
> > 	Interrupt: pin A routed to IRQ 5
> > 	Region 0: Memory at cddf8000 (64-bit, non-prefetchable) [size=16K]
> > 	Capabilities: [50] Power Management version 2
> > 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=55mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 	Capabilities: [60] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
> > 		Address: 0000000000000000  Data: 0000
> > 	Capabilities: [70] Express Unknown type IRQ 0
> > 		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
> > 		Device: Latency L0s <64ns, L1 <1us
> > 		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
> > 		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop+
> > 		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
> > 		Link: Supported Speed unknown, Width x0, ASPM unknown, Port 0
> > 		Link: Latency L0s <64ns, L1 <1us
> > 		Link: ASPM Disabled CommClk- ExtSynch-
> > 		Link: Speed unknown, Width x0
> > 
> > 00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 1 (rev 01) (prog-if 00 [Normal decode])
> > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0, Cache Line Size: 16 bytes
> > 	Bus: primary=00, secondary=03, subordinate=03, sec-latency=0
> > 	I/O behind bridge: 0000d000-0000dfff
> > 	Memory behind bridge: fff00000-000fffff
> > 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> > 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> > 	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
> > 	Capabilities: [40] Express Root Port (Slot+) IRQ 0
> > 		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
> > 		Device: Latency L0s unlimited, L1 unlimited
> > 		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
> > 		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > 		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
> > 		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 1
> > 		Link: Latency L0s <256ns, L1 <4us
> > 		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
> > 		Link: Speed 2.5Gb/s, Width x0
> > 		Slot: AtnBtn- PwrCtrl- MRL- AtnInd- PwrInd- HotPlug+ Surpise+
> > 		Slot: Number 1, PowerLimit 10.000000
> > 		Slot: Enabled AtnBtn- PwrFlt- MRL- PresDet- CmdCplt- HPIrq-
> > 		Slot: AttnInd Unknown, PwrInd Unknown, Power-
> > 		Root: Correctable- Non-Fatal- Fatal- PME-
> > 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> > 		Address: fee0300c  Data: 41c1
> > 	Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Capabilities: [a0] Power Management version 2
> > 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:1c.1 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 2 (rev 01) (prog-if 00 [Normal decode])
> > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0, Cache Line Size: 16 bytes
> > 	Bus: primary=00, secondary=02, subordinate=02, sec-latency=0
> > 	I/O behind bridge: 0000c000-0000cfff
> > 	Memory behind bridge: cde00000-cdefffff
> > 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> > 	Secondary status: 66MHz- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- <SERR- <PERR-
> > 	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
> > 	Capabilities: [40] Express Root Port (Slot-) IRQ 0
> > 		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
> > 		Device: Latency L0s unlimited, L1 unlimited
> > 		Device: Errors: Correctable+ Non-Fatal+ Fatal+ Unsupported+
> > 		Device: RlxdOrd- ExtTag- PhantFunc- AuxPwr- NoSnoop-
> > 		Device: MaxPayload 128 bytes, MaxReadReq 128 bytes
> > 		Link: Supported Speed 2.5Gb/s, Width x1, ASPM L0s L1, Port 2
> > 		Link: Latency L0s <256ns, L1 <4us
> > 		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
> > 		Link: Speed 2.5Gb/s, Width x1
> > 		Root: Correctable- Non-Fatal- Fatal- PME-
> > 	Capabilities: [80] Message Signalled Interrupts: Mask- 64bit- Queue=0/0 Enable+
> > 		Address: fee0300c  Data: 41c9
> > 	Capabilities: [90] Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Capabilities: [a0] Power Management version 2
> > 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:1d.0 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI #1 (rev 01) (prog-if 00 [UHCI])
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0
> > 	Interrupt: pin A routed to IRQ 18
> > 	Region 4: I/O ports at 8000 [size=32]
> > 
> > 00:1d.1 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI #2 (rev 01) (prog-if 00 [UHCI])
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0
> > 	Interrupt: pin B routed to IRQ 17
> > 	Region 4: I/O ports at 8400 [size=32]
> > 
> > 00:1d.2 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI #3 (rev 01) (prog-if 00 [UHCI])
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0
> > 	Interrupt: pin C routed to IRQ 19
> > 	Region 4: I/O ports at 8800 [size=32]
> > 
> > 00:1d.3 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI #4 (rev 01) (prog-if 00 [UHCI])
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0
> > 	Interrupt: pin D routed to IRQ 20
> > 	Region 4: I/O ports at 9000 [size=32]
> > 
> > 00:1d.7 USB Controller: Intel Corporation 82801G (ICH7 Family) USB2 EHCI Controller (rev 01) (prog-if 20 [EHCI])
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0
> > 	Interrupt: pin A routed to IRQ 18
> > 	Region 0: Memory at cddffc00 (32-bit, non-prefetchable) [size=1K]
> > 	Capabilities: [50] Power Management version 2
> > 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 	Capabilities: [58] Debug port
> > 
> > 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev e1) (prog-if 01 [Subtractive decode])
> > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0
> > 	Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
> > 	I/O behind bridge: 0000b000-0000bfff
> > 	Memory behind bridge: fff00000-000fffff
> > 	Prefetchable memory behind bridge: 00000000fff00000-00000000000fffff
> > 	Secondary status: 66MHz- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ <SERR- <PERR-
> > 	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
> > 	Capabilities: [50] Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 
> > 00:1f.0 ISA bridge: Intel Corporation 82801GB/GR (ICH7 Family) LPC Interface Bridge (rev 01)
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0
> > 	Capabilities: [e0] Vendor Specific Information
> > 
> > 00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE Controller (rev 01) (prog-if 8a [Master SecP PriP])
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0
> > 	Interrupt: pin A routed to IRQ 19
> > 	Region 0: I/O ports at 01f0 [size=8]
> > 	Region 1: I/O ports at 03f4 [size=1]
> > 	Region 2: I/O ports at 0170 [size=8]
> > 	Region 3: I/O ports at 0374 [size=1]
> > 	Region 4: I/O ports at ffa0 [size=16]
> > 
> > 00:1f.2 IDE interface: Intel Corporation 82801GB/GR/GH (ICH7 Family) Serial ATA Storage Controller IDE (rev 01) (prog-if 8f [Master SecP SecO PriP PriO])
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 2601
> > 	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0
> > 	Interrupt: pin B routed to IRQ 17
> > 	Region 0: I/O ports at a800 [size=8]
> > 	Region 1: I/O ports at a400 [size=4]
> > 	Region 2: I/O ports at a000 [size=8]
> > 	Region 3: I/O ports at 9800 [size=4]
> > 	Region 4: I/O ports at 9400 [size=16]
> > 	Capabilities: [70] Power Management version 2
> > 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
> > 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 
> > 00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controller (rev 01)
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 8179
> > 	Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Interrupt: pin B routed to IRQ 0
> > 	Region 4: I/O ports at 0400 [size=32]
> > 
> > 02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 81c2
> > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0, Cache Line Size: 64 bytes
> > 	Interrupt: pin A routed to IRQ 220
> > 	Region 0: Memory at cdee0000 (32-bit, non-prefetchable) [size=128K]
> > 	Region 2: I/O ports at c800 [size=32]
> > 	Capabilities: [c8] Power Management version 2
> > 		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
> > 		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
> > 	Capabilities: [d0] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable+
> > 		Address: 00000000fee0300c  Data: 41e9
> > 	Capabilities: [e0] Express Endpoint IRQ 0
> > 		Device: Supported: MaxPayload 256 bytes, PhantFunc 0, ExtTag-
> > 		Device: Latency L0s <512ns, L1 <64us
> > 		Device: AtnBtn- AtnInd- PwrInd-
> > 		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
> > 		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> > 		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
> > 		Link: Supported Speed 2.5Gb/s, Width x1, ASPM unknown, Port 0
> > 		Link: Latency L0s <128ns, L1 <64us
> > 		Link: ASPM Disabled RCB 64 bytes CommClk+ ExtSynch-
> > 		Link: Speed 2.5Gb/s, Width x1
> > 
> > 04:00.0 VGA compatible controller: nVidia Corporation GeForce 7300 GS (rev a1) (prog-if 00 [VGA])
> > 	Subsystem: ASUSTeK Computer Inc. Unknown device 81f1
> > 	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
> > 	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-
> > 	Latency: 0, Cache Line Size: 16 bytes
> > 	Interrupt: pin A routed to IRQ 11
> > 	Region 0: Memory at cf000000 (32-bit, non-prefetchable) [size=16M]
> > 	Region 1: Memory at d0000000 (64-bit, prefetchable) [size=256M]
> > 	Region 3: Memory at ce000000 (64-bit, non-prefetchable) [size=16M]
> > 	Expansion ROM at cdfe0000 [disabled] [size=128K]
> > 	Capabilities: [60] Power Management version 2
> > 		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
> > 		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
> > 	Capabilities: [68] Message Signalled Interrupts: Mask- 64bit+ Queue=0/0 Enable-
> > 		Address: 0000000000000000  Data: 0000
> > 	Capabilities: [78] Express Endpoint IRQ 0
> > 		Device: Supported: MaxPayload 128 bytes, PhantFunc 0, ExtTag-
> > 		Device: Latency L0s <256ns, L1 <4us
> > 		Device: AtnBtn- AtnInd- PwrInd-
> > 		Device: Errors: Correctable- Non-Fatal- Fatal- Unsupported-
> > 		Device: RlxdOrd+ ExtTag- PhantFunc- AuxPwr- NoSnoop+
> > 		Device: MaxPayload 128 bytes, MaxReadReq 512 bytes
> > 		Link: Supported Speed 2.5Gb/s, Width x16, ASPM L0s L1, Port 0
> > 		Link: Latency L0s <256ns, L1 <4us
> > 		Link: ASPM Disabled RCB 128 bytes CommClk+ ExtSynch-
> > 		Link: Speed 2.5Gb/s, Width x16
> > 
> > [8.6.] SCSI information (from /proc/scsi/scsi)
> > 
> > (SATA)
> > 
> > Attached devices:
> > Host: scsi0 Channel: 00 Id: 00 Lun: 00
> >   Vendor: ATA      Model: SAMSUNG HD080HJ  Rev: ZH10
> >   Type:   Direct-Access                    ANSI SCSI revision: 05
> > Host: scsi1 Channel: 00 Id: 00 Lun: 00
> >   Vendor: ATA      Model: SAMSUNG HD080HJ  Rev: ZH10
> >   Type:   Direct-Access                    ANSI SCSI revision: 05
> > 
