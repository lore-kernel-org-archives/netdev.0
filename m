From: Szymon Miotk <spam@crocom.com.pl>
Subject: PROBLEM: IProute hangs after running traffic shaping scripts
Date: Fri, 05 Nov 2004 10:48:44 +0100
Message-ID: <418B4C7C.8000402@crocom.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This mail was posted 02-11-2004 to linux-net@vger.kernel.org, but I got 
no response at all, so I am resending it.

[1.] One line summary of the problem:
IProute hangs after running traffic shaping scripts

[2.] Full description of the problem/report:
I have a server with 3 links to ISPs and 1 link for internal network.
I shape my clients to certain speeds, depending on the time of the day.
I have HTB shaping on each interface, about 2250 classes and 2250 qdisc
on each, so it makes total ~9000 classes (HTB) and ~9000 qdisc (SFQ).
I run shaping scripts 4 times/day.
Sometimes it makes a kernel oops, hangs at some 'tc ...' command (it
differs).
Then the shaping works so-so (usually it works, but doesn't fully
utilize the bandwidth) and every iproute command hangs.
Killing the hanging processes kills them, but still every iproute
command hangs, including ip and tc.
Sometimes the server stops forwarding, but usually it does so few hours
after kernel oops.
Reboot always helps.

[3.] Keywords (i.e., modules, networking, kernel):
traffic shaping, htb, qdisc, networking, kernel

[4.] Kernel version (from /proc/version):
Linux version 2.6.9 (root@ducttape.mlyniec) (gcc version 3.3.3 20040412
(Red Hat Linux 3.3.3-7)) #2 Thu Oct 28 17:06:01 CEST 2004

[5.] Output of Oops.. message (if applicable) with symbolic information
      resolved (see Documentation/oops-tracing.txt
ksymoops 2.4.9 on i686 2.6.5-1.358smp.  Options used
      -v /usr/src/linux-2.6.9/vmlinux (specified)
      -K (specified)
      -L (specified)
      -O (specified)
      -m /usr/src/linux-2.6.9/System.map (specified)

Oct 31 15:02:38 cerber kernel: Unable to handle kernel paging request at
virtual address 00100100
Oct 31 15:02:38 cerber kernel: *pde = 00000000
Oct 31 15:02:38 cerber kernel: Oops: 0000 [#1]
Oct 31 15:02:38 cerber kernel: c03728c8
Oct 31 15:02:38 cerber kernel: CPU:    0
Oct 31 15:02:38 cerber kernel: EIP:    0060:[<c03728c8>]    Not tainted VLI
Using defaults from ksymoops -t elf32-i386 -a i386
Oct 31 15:02:38 cerber kernel: EFLAGS: 00010286   (2.6.9)
Oct 31 15:02:38 cerber kernel: eax: 001000b8   ebx: 001000b8   ecx:
f0166048   edx: 00100100
Oct 31 15:02:38 cerber kernel: esi: f7c1b12c   edi: 00010000   ebp:
f7c1b000   esp: f1b47c54
Oct 31 15:02:38 cerber kernel: ds: 007b   es: 007b   ss: 0068
Oct 31 15:02:38 cerber kernel: Stack: ef3aaa10 eedd6000 c037325c
c0373353 00000000 00000000 00000000 00000000
Oct 31 15:02:38 cerber kernel:        00000000 000008dc 00000002
00000000 f23de000 c01044e5 f1b47c94 00000002
Oct 31 15:02:38 cerber kernel:        00000000 ffffffff c18fcf80
ef3aaa00 f5019680 f23de000 00000000 f5019680
Oct 31 15:02:38 cerber kernel: Call Trace:
Oct 31 15:02:38 cerber kernel:  [<c037325c>] tc_modify_qdisc+0x0/0x6e3
Oct 31 15:02:38 cerber kernel:  [<c0373353>] tc_modify_qdisc+0xf7/0x6e3
Oct 31 15:02:38 cerber kernel:  [<c01044e5>] error_code+0x2d/0x38
Oct 31 15:02:38 cerber kernel:  [<c037325c>] tc_modify_qdisc+0x0/0x6e3
Oct 31 15:02:38 cerber kernel:  [<c036bb36>] rtnetlink_rcv+0x2af/0x359
Oct 31 15:02:38 cerber kernel:  [<c036b887>] rtnetlink_rcv+0x0/0x359
Oct 31 15:02:38 cerber kernel:  [<c038add3>] netlink_data_ready+0x55/0x5d
Oct 31 15:02:38 cerber kernel:  [<c038a49f>] netlink_sendskb+0x8a/0x8c
Oct 31 15:02:38 cerber kernel:  [<c038aac5>] netlink_sendmsg+0x1d7/0x2af
Oct 31 15:02:38 cerber kernel:  [<c03595c9>] sock_sendmsg+0xcc/0xe6
Oct 31 15:02:38 cerber kernel:  [<c03596fb>] sock_recvmsg+0xdc/0xf7
Oct 31 15:02:38 cerber kernel:  [<c0140657>] buffered_rmqueue+0xcf/0x27a
Oct 31 15:02:38 cerber kernel:  [<c039333b>] ip_forward_finish+0x26/0x4b
Oct 31 15:02:38 cerber kernel:  [<c011a0f2>]
autoremove_wake_function+0x0/0x43
Oct 31 15:02:38 cerber kernel:  [<c021586d>] copy_from_user+0x54/0x83
Oct 31 15:02:38 cerber kernel:  [<c035f4fa>] verify_iovec+0x2a/0x74
Oct 31 15:02:38 cerber kernel:  [<c035ab74>] sys_sendmsg+0x14c/0x197
Oct 31 15:02:38 cerber kernel:  [<c015001e>] handle_mm_fault+0x11d/0x2cf
Oct 31 15:02:38 cerber kernel:  [<c03593fb>] sockfd_lookup+0x16/0x6e
Oct 31 15:02:38 cerber kernel:  [<c035a921>] sys_setsockopt+0x69/0x9e
Oct 31 15:02:38 cerber kernel:  [<c035af9f>] sys_socketcall+0x22b/0x249
Oct 31 15:02:38 cerber kernel:  [<c0112ca2>] do_page_fault+0x0/0x52b
Oct 31 15:02:38 cerber kernel:  [<c01044e5>] error_code+0x2d/0x38
Oct 31 15:02:38 cerber kernel:  [<c01042e9>] sysenter_past_esp+0x52/0x71
Oct 31 15:02:38 cerber kernel: Code: 89 d7 56 53 8b 88 2c 01 00 00 8d 59
b8 8b 53 48 0f 18 02 90 8d b0 2c 01 00 00 39 f1 74 18 39 7b 14 74 19 8b
53 48 8d 42 b8 89 c3 <8b> 40 48 0f 18 00 90 39 f2 75 e8 31 c0 5b 5e 5f
c3 89 d8 eb f8

>>EIP; c03728c8 <qdisc_lookup+2c/41>   <=====


>>ecx; f0166048 <pg0+2faf4048/3f98c400>
>>esi; f7c1b12c <pg0+375a912c/3f98c400>
>>ebp; f7c1b000 <pg0+375a9000/3f98c400>
>>esp; f1b47c54 <pg0+314d5c54/3f98c400>


Trace; c037325c <tc_modify_qdisc+0/6e3>
Trace; c0373353 <tc_modify_qdisc+f7/6e3>
Trace; c01044e5 <error_code+2d/38>
Trace; c037325c <tc_modify_qdisc+0/6e3>
Trace; c036bb36 <rtnetlink_rcv+2af/359>
Trace; c036b887 <rtnetlink_rcv+0/359>
Trace; c038add3 <netlink_data_ready+55/5d>
Trace; c038a49f <netlink_sendskb+8a/8c>
Trace; c038aac5 <netlink_sendmsg+1d7/2af>
Trace; c03595c9 <sock_sendmsg+cc/e6>
Trace; c03596fb <sock_recvmsg+dc/f7>
Trace; c0140657 <buffered_rmqueue+cf/27a>
Trace; c039333b <ip_forward_finish+26/4b>
Trace; c011a0f2 <autoremove_wake_function+0/43>
Trace; c021586d <copy_from_user+54/83>
Trace; c035f4fa <verify_iovec+2a/74>
Trace; c035ab74 <sys_sendmsg+14c/197>
Trace; c015001e <handle_mm_fault+11d/2cf>
Trace; c03593fb <sockfd_lookup+16/6e>
Trace; c035a921 <sys_setsockopt+69/9e>
Trace; c035af9f <sys_socketcall+22b/249>
Trace; c0112ca2 <do_page_fault+0/52b>
Trace; c01044e5 <error_code+2d/38>
Trace; c01042e9 <sysenter_past_esp+52/71>

This architecture has variable length instructions, decoding before eip
is unreliable, take these instructions with a pinch of salt.


Code;  c037289d <qdisc_lookup+1/41>
00000000 <_EIP>:
Code;  c037289d <qdisc_lookup+1/41>
    0:   89 d7                     mov    %edx,%edi
Code;  c037289f <qdisc_lookup+3/41>
    2:   56                        push   %esi
Code;  c03728a0 <qdisc_lookup+4/41>
    3:   53                        push   %ebx
Code;  c03728a1 <qdisc_lookup+5/41>
    4:   8b 88 2c 01 00 00         mov    0x12c(%eax),%ecx
Code;  c03728a7 <qdisc_lookup+b/41>
    a:   8d 59 b8                  lea    0xffffffb8(%ecx),%ebx
Code;  c03728aa <qdisc_lookup+e/41>
    d:   8b 53 48                  mov    0x48(%ebx),%edx
Code;  c03728ad <qdisc_lookup+11/41>
   10:   0f 18 02                  prefetchnta (%edx)
Code;  c03728b0 <qdisc_lookup+14/41>
   13:   90                        nop
Code;  c03728b1 <qdisc_lookup+15/41>
   14:   8d b0 2c 01 00 00         lea    0x12c(%eax),%esi
Code;  c03728b7 <qdisc_lookup+1b/41>
   1a:   39 f1                     cmp    %esi,%ecx
Code;  c03728b9 <qdisc_lookup+1d/41>
   1c:   74 18                     je     36 <_EIP+0x36>
Code;  c03728bb <qdisc_lookup+1f/41>
   1e:   39 7b 14                  cmp    %edi,0x14(%ebx)
Code;  c03728be <qdisc_lookup+22/41>
   21:   74 19                     je     3c <_EIP+0x3c>
Code;  c03728c0 <qdisc_lookup+24/41>
   23:   8b 53 48                  mov    0x48(%ebx),%edx
Code;  c03728c3 <qdisc_lookup+27/41>
   26:   8d 42 b8                  lea    0xffffffb8(%edx),%eax
Code;  c03728c6 <qdisc_lookup+2a/41>
   29:   89 c3                     mov    %eax,%ebx

This decode from eip onwards should be reliable


Code;  c03728c8 <qdisc_lookup+2c/41>
00000000 <_EIP>:
Code;  c03728c8 <qdisc_lookup+2c/41>   <=====
    0:   8b 40 48                  mov    0x48(%eax),%eax   <=====
Code;  c03728cb <qdisc_lookup+2f/41>
    3:   0f 18 00                  prefetchnta (%eax)
Code;  c03728ce <qdisc_lookup+32/41>
    6:   90                        nop
Code;  c03728cf <qdisc_lookup+33/41>
    7:   39 f2                     cmp    %esi,%edx
Code;  c03728d1 <qdisc_lookup+35/41>
    9:   75 e8                     jne    fffffff3 <_EIP+0xfffffff3>
Code;  c03728d3 <qdisc_lookup+37/41>
    b:   31 c0                     xor    %eax,%eax
Code;  c03728d5 <qdisc_lookup+39/41>
    d:   5b                        pop    %ebx
Code;  c03728d6 <qdisc_lookup+3a/41>
    e:   5e                        pop    %esi
Code;  c03728d7 <qdisc_lookup+3b/41>
    f:   5f                        pop    %edi
Code;  c03728d8 <qdisc_lookup+3c/41>
   10:   c3                        ret
Code;  c03728d9 <qdisc_lookup+3d/41>
   11:   89 d8                     mov    %ebx,%eax
Code;  c03728db <qdisc_lookup+3f/41>
   13:   eb f8                     jmp    d <_EIP+0xd>

[6.] A small shell script or example program which triggers the
      problem (if possible)
my traffic shaping scripts are rather huge and they don't always cause
kernel oops. I tried to run them together (so classes and qdisc on every
interface were changed in parallel), but it didn't help.
I can send you them if you wish.

[7.] Environment
[7.1.] Software (add the output of the ver_linux script here)
This is output from where the kernel was compiled. This is machine with
the same hardware setup and the same Linux distro, but with developing
packages installed.
Gnu C                  3.3.3
Gnu make               3.80
binutils               2.15.90.0.3
util-linux             2.12
mount                  2.12
module-init-tools      2.4.26
e2fsprogs              1.35
reiserfsprogs          line
reiser4progs           line
pcmcia-cs              3.2.7
quota-tools            3.10.
PPP                    2.4.2
isdn4k-utils           3.3
nfs-utils              1.0.6
Linux C Library        2.3.3
Dynamic linker (ldd)   2.3.3
Procps                 3.2.0
Net-tools              1.60
Kbd                    1.12
Sh-utils               5.2.1

[7.2.] Processor information (from /proc/cpuinfo):
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 15
model           : 2
model name      : Intel(R) Pentium(R) 4 CPU 2.80GHz
stepping        : 5
cpu MHz         : 2814.286
cache size      : 512 KB
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : no
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 2
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge
mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe cid xtpr
bogomips        : 5554.17

This is HT P4, but SMP was disabled.

[7.3.] Module information (from /proc/modules):
This is static kernel, no modules.

[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
cat /proc/ioports
0000-001f : dma1
0020-0021 : pic1
0040-0043 : timer0
0050-0053 : timer1
0060-006f : keyboard
0070-0077 : rtc
0080-008f : dma page reg
00a0-00a1 : pic2
00c0-00df : dma2
00f0-00ff : fpu
0170-0177 : ide1
01f0-01f7 : libata
02f8-02ff : serial
0376-0376 : ide1
03c0-03df : vga+
03f8-03ff : serial
0cf8-0cff : PCI conf1
1000-107f : 0000:00:1f.0
1080-10bf : 0000:00:1f.0
1400-141f : 0000:00:1f.3
a000-a03f : 0000:02:00.0
   a000-a03f : e1000
a400-a43f : 0000:02:01.0
   a400-a43f : e1000
a800-a83f : 0000:02:02.0
   a800-a83f : e1000
ac00-ac3f : 0000:02:03.0
   ac00-ac3f : e1000
f000-f00f : 0000:00:1f.2
   f000-f00f : libata

  cat /proc/iomem
00000000-0009ffff : System RAM
000a0000-000bffff : Video RAM area
000c0000-000ccbff : Video ROM
000d0000-000d0fff : Adapter ROM
000d1000-000d1fff : Adapter ROM
000d2000-000d2fff : Adapter ROM
000d3000-000d3fff : Adapter ROM
000f0000-000fffff : System ROM
00100000-3ffeffff : System RAM
   00100000-004215e9 : Kernel code
   004215ea-0057e3ff : Kernel data
3fff0000-3fff2fff : ACPI Non-volatile Storage
3fff3000-3fffffff : ACPI Tables
e8000000-efffffff : 0000:00:00.0
f0000000-f7ffffff : PCI Bus #01
   f0000000-f7ffffff : 0000:01:00.0
f8000000-f9ffffff : PCI Bus #01
   f8000000-f8ffffff : 0000:01:00.0
fb000000-fb01ffff : 0000:02:00.0
   fb000000-fb01ffff : e1000
fb020000-fb03ffff : 0000:02:00.0
   fb020000-fb03ffff : e1000
fb040000-fb05ffff : 0000:02:01.0
   fb040000-fb05ffff : e1000
fb060000-fb07ffff : 0000:02:01.0
   fb060000-fb07ffff : e1000
fb080000-fb09ffff : 0000:02:02.0
   fb080000-fb09ffff : e1000
fb0a0000-fb0bffff : 0000:02:02.0
   fb0a0000-fb0bffff : e1000
fb0c0000-fb0dffff : 0000:02:03.0
   fb0c0000-fb0dffff : e1000
fb0e0000-fb0fffff : 0000:02:03.0
   fb0e0000-fb0fffff : e1000
fec00000-ffffffff : reserved

[7.5.] PCI information ('lspci -vvv' as root)
In short: 4 x Intel 1000 MT carts, Marvell/Yukon integreated GbE disabled.


00:00.0 Host bridge: Intel Corp. 82865G/PE/P DRAM Controller/Host-Hub
Interface (rev 02)
         Subsystem: Giga-byte Technology GA-8IPE1000 Pro2 motherboard
(865PE)
         Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort+ >SERR- <PERR-
         Latency: 0
         Region 0: Memory at e8000000 (32-bit, prefetchable)
         Capabilities: [e4] #09 [2106]
         Capabilities: [a0] AGP version 3.0
                 Status: RQ=32 Iso- ArqSz=2 Cal=0 SBA+ ITACoh- GART64-
HTrans- 64bit- FW+ AGP3- Rate=x1,x2,x4
                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit-
FW- Rate=<none>

00:01.0 PCI bridge: Intel Corp. 82865G/PE/P PCI to AGP Controller (rev
02) (prog-if 00 [Normal decode])
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap- 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
         Latency: 64
         Bus: primary=00, secondary=01, subordinate=01, sec-latency=32
         I/O behind bridge: 0000f000-00000fff
         Memory behind bridge: f8000000-f9ffffff
         Prefetchable memory behind bridge: f0000000-f7ffffff
         BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-

00:1e.0 PCI bridge: Intel Corp. 82801BA/CA/DB/EB/ER Hub interface to PCI
Bridge (rev c2) (prog-if 00 [Normal decode])
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR+ FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=fast >TAbort-
<TAbort- <MAbort- >SERR- <PERR-
         Latency: 0
         Bus: primary=00, secondary=02, subordinate=02, sec-latency=32
         I/O behind bridge: 0000a000-0000afff
         Memory behind bridge: fa000000-fbffffff
         Prefetchable memory behind bridge: fff00000-000fffff
         BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-

00:1f.0 ISA bridge: Intel Corp. 82801EB/ER (ICH5/ICH5R) LPC Bridge (rev 02)
         Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 0

00:1f.2 IDE interface: Intel Corp. 82801EB (ICH5) Serial ATA 150 Storage
Controller (rev 02) (prog-if 8a [Master SecP PriP])
         Subsystem: Giga-byte Technology GA-8IPE1000 Pro2 motherboard
(865PE)
         Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 0
         Interrupt: pin A routed to IRQ 11
         Region 0: I/O ports at <unassigned>
         Region 1: I/O ports at <unassigned>
         Region 2: I/O ports at <unassigned>
         Region 3: I/O ports at <unassigned>
         Region 4: I/O ports at f000 [size=16]

00:1f.3 SMBus: Intel Corp. 82801EB/ER (ICH5/ICH5R) SMBus Controller (rev 02)
         Subsystem: Giga-byte Technology GA-8IPE1000 Pro2 motherboard
(865PE)
         Control: I/O+ Mem- BusMaster- SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Interrupt: pin B routed to IRQ 9
         Region 4: I/O ports at 1400 [size=32]

01:00.0 VGA compatible controller: nVidia Corporation NV11 [GeForce2
MX/MX 400] (rev b2) (prog-if 00 [VGA])
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (1250ns min, 250ns max)
         Interrupt: pin A routed to IRQ 5
         Region 0: Memory at f8000000 (32-bit, non-prefetchable)
         Region 1: Memory at f0000000 (32-bit, prefetchable) [size=128M]
         Capabilities: [60] Power Management version 2
                 Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA
PME(D0-,D1-,D2-,D3hot-,D3cold-)
                 Status: D0 PME-Enable- DSel=0 DScale=0 PME-
         Capabilities: [44] AGP version 2.0
                 Status: RQ=32 Iso- ArqSz=0 Cal=0 SBA- ITACoh- GART64-
HTrans- 64bit- FW- AGP3- Rate=x1,x2,x4
                 Command: RQ=1 ArqSz=0 Cal=0 SBA- AGP- GART64- 64bit-
FW- Rate=<none>

02:00.0 Ethernet controller: Intel Corp. 82541GI/PI Gigabit Ethernet
Controller
         Subsystem: Intel Corp. PRO/1000 MT Desktop Adapter
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (63750ns min), Cache Line Size 08
         Interrupt: pin A routed to IRQ 11
         Region 0: Memory at fb020000 (32-bit, non-prefetchable)
         Region 1: Memory at fb000000 (32-bit, non-prefetchable) [size=128K]
         Region 2: I/O ports at a000 [size=64]
         Capabilities: [dc] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [e4] PCI-X non-bridge device.
                 Command: DPERE- ERO+ RBC=0 OST=0
                 Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-,
DC=simple, DMMRBC=2, DMOST=0, DMCRS=0, RSCEM-
         Capabilities: [f0] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-
                 Address: 0000000000000000  Data: 0000

02:01.0 Ethernet controller: Intel Corp. 82541GI/PI Gigabit Ethernet
Controller
         Subsystem: Intel Corp. PRO/1000 MT Desktop Adapter
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (63750ns min), Cache Line Size 08
         Interrupt: pin A routed to IRQ 12
         Region 0: Memory at fb040000 (32-bit, non-prefetchable)
         Region 1: Memory at fb060000 (32-bit, non-prefetchable) [size=128K]
         Region 2: I/O ports at a400 [size=64]
         Capabilities: [dc] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [e4] PCI-X non-bridge device.
                 Command: DPERE- ERO+ RBC=0 OST=0
                 Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-,
DC=simple, DMMRBC=2, DMOST=0, DMCRS=0, RSCEM-
         Capabilities: [f0] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-
                 Address: 0000000000000000  Data: 0000

02:02.0 Ethernet controller: Intel Corp. 82541GI/PI Gigabit Ethernet
Controller
         Subsystem: Intel Corp. PRO/1000 MT Desktop Adapter
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (63750ns min), Cache Line Size 08
         Interrupt: pin A routed to IRQ 10
         Region 0: Memory at fb080000 (32-bit, non-prefetchable)
         Region 1: Memory at fb0a0000 (32-bit, non-prefetchable) [size=128K]
         Region 2: I/O ports at a800 [size=64]
         Capabilities: [dc] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [e4] PCI-X non-bridge device.
                 Command: DPERE- ERO+ RBC=0 OST=0
                 Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-,
DC=simple, DMMRBC=2, DMOST=0, DMCRS=0, RSCEM-
         Capabilities: [f0] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-
                 Address: 0000000000000000  Data: 0000

02:03.0 Ethernet controller: Intel Corp. 82541GI/PI Gigabit Ethernet
Controller
         Subsystem: Intel Corp. PRO/1000 MT Desktop Adapter
         Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop-
ParErr- Stepping- SERR- FastB2B-
         Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium
>TAbort- <TAbort- <MAbort- >SERR- <PERR-
         Latency: 32 (63750ns min), Cache Line Size 08
         Interrupt: pin A routed to IRQ 5
         Region 0: Memory at fb0c0000 (32-bit, non-prefetchable)
         Region 1: Memory at fb0e0000 (32-bit, non-prefetchable) [size=128K]
         Region 2: I/O ports at ac00 [size=64]
         Capabilities: [dc] Power Management version 2
                 Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA
PME(D0+,D1-,D2-,D3hot+,D3cold+)
                 Status: D0 PME-Enable- DSel=0 DScale=1 PME-
         Capabilities: [e4] PCI-X non-bridge device.
                 Command: DPERE- ERO+ RBC=0 OST=0
                 Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-,
DC=simple, DMMRBC=2, DMOST=0, DMCRS=0, RSCEM-
         Capabilities: [f0] Message Signalled Interrupts: 64bit+
Queue=0/0 Enable-
                 Address: 0000000000000000  Data: 0000

[7.6.] SCSI information (from /proc/scsi/scsi)
2 SATA Samsung drives.
Attached devices:
Host: scsi0 Channel: 00 Id: 00 Lun: 00
   Vendor: ATA      Model: SAMSUNG SP0812C  Rev: SU10
   Type:   Direct-Access                    ANSI SCSI revision: 05
Host: scsi0 Channel: 00 Id: 01 Lun: 00
   Vendor: ATA      Model: SAMSUNG SP0812C  Rev: SU10
   Type:   Direct-Access                    ANSI SCSI revision: 05

[7.7.] Other information that might be relevant to the problem
        (please look in /proc and include all information that you
        think to be relevant):
The system is Fedora Core 2.
The default kernel has serious problems with traffic shaping, that was
resolved in 2.6.9 kernel line.
The kernel is vanilla 2.6.9.
After recompiling the kernel I recompiled iproute using vanilla
iproute2-2.6.9-041019.tar.gz
I use PSCHED_CPU.
Without recompiling iproute, it hanged every time two iproute commands
were run in parallel.

[X.] Other notes, patches, fixes, workarounds:
None of those.
