From: Sebastian Hagen <sebastian_hagen@gmx.de>
Subject: PROBLEM: tc-commands trigger oops on linux-2.4.25
Date: Fri, 26 Mar 2004 17:14:40 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <406456F0.5040009@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

target: netdev@oss.sgi.com
subject: PROBLEM: tc-commands trigger oops on linux-2.4.25

[1.] tc-commands trigger oops on linux-2.4.25
[2.]
Using the tc-commands contained in the script in [6.] causes Linux 
2.4.25 (and 2.4.24) to oops under certain
conditions. It can be reproduced on the system mentioned here reliably 
by running the script immediately after
bootup.
After the oops, a number of processes get put into state D (ps-output) 
indefinitely. This always applies to new
instances of ifconfig started without parameters. Some running daemons 
(e.g. named, pppd) also go into D state after variable amounts of time.
"shutdown -r now" still puts the system into runlevel 6, but doesn't 
actually trigger a reboot anymore.
Calling /sbin/reboot while in runlevel 6 does reboot it, though.

[3.]
networking, traffic control

[4.]
Linux version 2.4.25 (root@support-unit-001) (gcc version 3.3.2 20031022 
(Red Hat Linux 3.3.2-1)) #3 Fri Mar 26 16:37:21 CET 2004
[5.]
ksymoops 2.4.5 on i686 2.4.25.  Options used
      -V (specified)
      -k /proc/ksyms (default)
      -l /proc/modules (default)
      -o /lib/modules/2.4.25/ (default)
      -m /boot/System.map-2.4.25 (default)

Unable to handle kernel NULL pointer dereference at virtual address 00000000
00000000
*pde = 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<00000000>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010202
eax: fffffffe   ebx: 80000000   ecx: 00000001   edx: 00000001
esi: de7624c0   edi: c03c9520   ebp: dd1a9cd8   esp: dd1a9c5c
ds: 0018   es: 0018   ss: 0018
Process tc (pid: 904, stackpage=dd1a9000)
Stack: c02b4cac de7624c0 00000001 00000010 00010246 dd1a9e50 dd3be380 
dd1a9c88
        dddf34ac 00000007 dddf3600 00000000 00000001 c03c9520 de7624c0 
00010001
        00000000 00000008 def296d0 c03c9568 00000c68 00000c7c ddab82e4 
000005dc
Call Trace:    [<c02b4cac>] [<c02b01c2>] [<c02afe6f>] [<c02c590a>] 
[<c02c51fd>]
   [<c02c56a3>] [<c02a1563>] [<c02a29d9>] [<c012f116>] [<c01261e6>] 
[<c01263ff>]
   [<c0113a01>] [<c02a1eba>] [<c02a2ea8>] [<c0113860>] [<c01071cf>]
Code:  Bad EIP value.


 >>EIP; 00000000 Before first symbol

 >>eax; fffffffe <END_OF_CODE+1f6f6e9f/????>
 >>ebx; 80000000 Before first symbol
 >>esi; de7624c0 <_end+1e334f08/2048bac8>
 >>edi; c03c9520 <tbf_class_ops+0/40>
 >>ebp; dd1a9cd8 <_end+1cd7c720/2048bac8>
 >>esp; dd1a9c5c <_end+1cd7c6a4/2048bac8>

Trace; c02b4cac <tc_ctl_tfilter+dc/4f0>
Trace; c02b01c2 <rtnetlink_rcv_msg+162/22c>
Trace; c02afe6f <rtnetlink_rcv+af/1b0>
Trace; c02c590a <netlink_data_ready+5a/70>
Trace; c02c51fd <netlink_unicast+23d/2e0>
Trace; c02c56a3 <netlink_sendmsg+183/240>
Trace; c02a1563 <sock_sendmsg+73/b0>
Trace; c02a29d9 <sys_sendmsg+1b9/230>
Trace; c012f116 <lru_cache_add+66/70>
Trace; c01261e6 <do_anonymous_page+d6/e0>
Trace; c01263ff <handle_mm_fault+6f/f0>
Trace; c0113a01 <do_page_fault+1a1/52b>
Trace; c02a1eba <sys_socket+3a/60>
Trace; c02a2ea8 <sys_socketcall+218/240>
Trace; c0113860 <do_page_fault+0/52b>
Trace; c01071cf <system_call+33/38>

[6.]
#!/bin/sh
tc qdisc add dev ppp0 root handle 1:0 tbf rate 15kbps latency 50ms \
burst 1454
tc filter add dev ppp0 parent 1:1 prio 0 protocol ip handle 10 fw \
flowid 1:10

[7.]
[7.1.]
# ./scripts/ver_linux
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.

Linux support-unit-001 2.4.25 #3 Fri Mar 26 16:37:21 CET 2004 i686 
athlon i386 GNU/Linux

Gnu C                  3.3.2
Gnu make               3.79.1
util-linux             2.11y
mount                  2.11y
modutils               2.4.25
e2fsprogs              1.34
jfsutils               1.1.3
reiserfsprogs          3.6.8
quota-tools            3.06.
PPP                    2.4.1
isdn4k-utils           3.3
Linux C Library        2.3.2
Dynamic linker (ldd)   2.3.2
Procps                 2.0.17
Net-tools              1.60
Kbd                    1.08
Sh-utils               5.0
Modules Loaded         nfsd parport_pc lp parport sg scsi_mod

# tc -V
tc utility, iproute2-ss991023

[7.2.]
processor       : 0
vendor_id       : AuthenticAMD
cpu family      : 6
model           : 8
model name      : AMD Athlon(tm) XP 2200+
stepping        : 1
cpu MHz         : 1800.545
cache size      : 256 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge 
mca cmov pat pse36 mmx fxsr sse syscall mmxext 3dnowext 3dnow
bogomips        : 3591.37

[7.3.]
nfsd                   79920   8 (autoclean)
parport_pc             26472   1 (autoclean)
lp                      8708   0 (autoclean)
parport                33576   1 (autoclean) [parport_pc lp]
sg                     30428   0 (autoclean) (unused)
scsi_mod               96544   1 (autoclean) [sg]

[7.4.]
[/proc/ioports]
0000-001f : dma1
0020-003f : pic1
0040-005f : timer
0060-006f : keyboard
0070-007f : rtc
0080-008f : dma page reg
00a0-00bf : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : ide1
01f0-01f7 : ide0
0376-0376 : ide1
0378-037a : parport0
03c0-03df : vga+
03f6-03f6 : ide0
03f8-03ff : serial(auto)
0cf8-0cff : PCI conf1
d800-d81f : PCI device 10ec:8029
   d800-d81f : ne2k-pci
dc00-dcff : PCI device 1039:0900
   dc00-dcff : sis900
ff00-ff0f : PCI device 1039:5513
   ff00-ff07 : ide0
   ff08-ff0f : ide1

[/proc/iomem]
00000000-0009fbff : System RAM
0009fc00-0009ffff : reserved
000a0000-000bffff : Video RAM area
000c0000-000c7fff : Video ROM
000e8000-000e9fff : reserved
000f0000-000fffff : System ROM
00100000-1ffeffff : System RAM
   00100000-0034d994 : Kernel code
   0034d995-003d0363 : Kernel data
1fff0000-1fff7fff : ACPI Tables
1fff8000-1fffffff : ACPI Non-volatile Storage
cea00000-cebfffff : PCI Bus #01
ced00000-ceefffff : PCI Bus #01
cf7ec000-cf7ecfff : PCI device 1039:0900
   cf7ec000-cf7ecfff : sis900
cf7ed000-cf7edfff : PCI device 1039:7001
   cf7ed000-cf7edfff : usb-ohci
cf7ee000-cf7eefff : PCI device 1039:7001
   cf7ee000-cf7eefff : usb-ohci
cf7ef000-cf7effff : PCI device 1039:7002
   cf7ef000-cf7effff : ehci_hcd
cf800000-cfffffff : PCI device 5333:8811
d0000000-d7ffffff : PCI device 1039:0746
fec00000-fec00fff : reserved
fee00000-fee00fff : reserved
ffee0000-ffefffff : reserved
fffc0000-ffffffff : reserved

[7.5.]
00:00.0 Host bridge: Silicon Integrated Systems [SiS] 746 Host (rev 10)
         Subsystem: Elitegroup Computer Systems: Unknown device 1808
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
         Latency: 0
         Region 0: Memory at d0000000 (32-bit, non-prefetchable) [size=128M]
         Capabilities: [c0] AGP version 2.0
                 Status: RQ=31 SBA+ 64bit- FW- Rate=x1,x2,x4
                 Command: RQ=0 SBA- AGP- 64bit- FW- Rate=<none>

00:01.0 PCI bridge: Silicon Integrated Systems [SiS] SG86C202 (prog-if 
00 [Normal decode])
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- 
<TAbort- <MAbort- >SERR- <PERR-
         Latency: 64
         Bus: primary=00, secondary=01, subordinate=02, sec-latency=64
         I/O behind bridge: 0000f000-00000fff
         Memory behind bridge: ced00000-ceefffff
         Prefetchable memory behind bridge: cea00000-cebfffff
         BridgeCtl: Parity- SERR+ NoISA- VGA- MAbort- >Reset- FastB2B-

00:02.0 ISA bridge: Silicon Integrated Systems [SiS] SiS85C503/5513 (LPC 
Bridge) (rev 25)
         Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 0

00:02.5 IDE interface: Silicon Integrated Systems [SiS] 5513 [IDE] 
(prog-if 80 [Master])
         Subsystem: Elitegroup Computer Systems: Unknown device 1808
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 128
         Region 4: I/O ports at ff00 [size=16]

00:03.0 USB Controller: Silicon Integrated Systems [SiS] USB 1.0 
Controller (rev 0f) (prog-if 10 [OHCI])
         Subsystem: Elitegroup Computer Systems: Unknown device 1808
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 64 (20000ns max), cache line size 08
         Interrupt: pin A routed to IRQ 10
         Region 0: Memory at cf7ed000 (32-bit, non-prefetchable) [size=4K]

00:03.1 USB Controller: Silicon Integrated Systems [SiS] USB 1.0 
Controller (rev 0f) (prog-if 10 [OHCI])
         Subsystem: Elitegroup Computer Systems: Unknown device 1808
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 64 (20000ns max), cache line size 08
         Interrupt: pin B routed to IRQ 5
         Region 0: Memory at cf7ee000 (32-bit, non-prefetchable) [size=4K]

00:03.2 USB Controller: Silicon Integrated Systems [SiS] USB 2.0 
Controller (prog-if 20 [EHCI])
         Subsystem: Elitegroup Computer Systems: Unknown device 1808
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 64 (20000ns max)
         Interrupt: pin D routed to IRQ 10
         Region 0: Memory at cf7ef000 (32-bit, non-prefetchable) [size=4K]
         Capabilities: [50] Power Management version 2
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=375mA 
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:04.0 Ethernet controller: Silicon Integrated Systems [SiS] SiS900 PCI 
Fast Ethernet (rev 91)
         Subsystem: Elitegroup Computer Systems: Unknown device 1808
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 64 (13000ns min, 2750ns max)
         Interrupt: pin A routed to IRQ 5
         Region 0: I/O ports at dc00 [size=256]
         Region 1: Memory at cf7ec000 (32-bit, non-prefetchable) [size=4K]
         Expansion ROM at cf7c0000 [disabled] [size=128K]
         Capabilities: [40] Power Management version 2
                 Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA 
PME(D0+,D1+,D2+,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-

00:09.0 VGA compatible controller: S3 Inc. 86c764/765 [Trio32/64/64V+] 
(prog-if 00 [VGA])
         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Interrupt: pin A routed to IRQ 11
         Region 0: Memory at cf800000 (32-bit, non-prefetchable) [size=8M]
         Expansion ROM at cf7f0000 [disabled] [size=64K]

00:0b.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8029(AS)
         Subsystem: Realtek Semiconductor Co., Ltd. RTL-8029(AS)
         Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- 
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium 
 >TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Interrupt: pin A routed to IRQ 11
         Region 0: I/O ports at d800 [size=32]

[7.6.]
Attached devices: none

[7.7.]
The following is the output of "tc qdisc show" right after bootup; i.e. 
a situation where running [6.] causes
an oops.
# tc qdisc show
qdisc pfifo_fast 0: dev eth0 [Unknown qdisc, optlen=20]
qdisc pfifo_fast 0: dev eth1 [Unknown qdisc, optlen=20]
qdisc pfifo_fast 0: dev ppp0 [Unknown qdisc, optlen=20]

[X.]
I hope I'm sending this to the correct address...
