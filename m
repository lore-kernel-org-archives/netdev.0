From: Olly Madge <oghm2@cam.ac.uk>
Subject: PROBLEM: Kernel oops in skbuff.c
Date: Mon, 04 Oct 2004 14:33:56 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096896836.7327.19.camel@oghm2>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi, I originally sent this to Alan Cox (as his name was listed at the
top of skbuff.c) but he's told me to send it to you instead.


My router had a kernel oops after running for 290+ days (exact number is
unknown). It was under very minor load at the time, just some IRC
traffic. The problem appears to be in networking code.


Kernel version is:
Linux version 2.4.22euclid1 (root@oghm2) (gcc version 3.3.2 (Debian)) #1
Sun Dec 14 22:09:10 GMT 2003

Output of the oops is below, I had to copy the oops debug information off
the screen by hand so it is possible that there are typos. However I did
check what I had typed so I believe it to be correct.


ksymoops 2.4.5 on i586 2.4.22euclid1.  Options used
     -V (specified)
     -k /proc/ksyms (specified)
     -l /proc/modules (default)
     -o /lib/modules/2.4.22euclid1/ (default)
     -m /boot/System.map-2.4.22euclid1 (default)

Warning: kfree_skbpassed an skb still on a list (from c024d8d6).
kernel BUG at skbuff.c:319!
invalid operand: 0000
CPU:    0
EIP:    0010:[<c01fbb87>]   Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
EFLAGS: 00010282
eax: 00000045   ebx: c138f480   ecx: 00000000   edx: c2706000
esi: 00000400   edi: c138f4c4   ebp: c138f480   esp: c02e5da4
ds: 0018    es: 0018    ss: 0018
Process swapper (pid: 0, stackpage=c02e5000)
Stack: c028d200 c024d8d6 c138f480 ffffffff c024d8d6 c138f480 c138f4b4 c1487140
       c2177ba0 c138f480 c0d67800 c10ed800 c01ffe7f c138f480 c10ed800 c2177ba0
       c28dd4a0 c10ed800 c0d67800 c11f0b60 c0207177 c0d67800 c10ed800 c10ed800
Call Trace:    [<c024d8d6>] [<c024d8d6>] [<c01ffe7f>] [<c0207177>] [<c02000cd>]
  [<c0216072>] [<c02066b2>] [<c02141a1>] [<c0215fb0>] [<c0212a1d>] [<c02066b2>]
  [<c0212963>] [<c0212a00>] [<c0211a6b>] [<c02066b2>] [<c0211718>] [<c02118c0>]
  [<c0200630>] [<c0200747>] [<c02008af>] [<c0119a96>] [<c010831e>] [<c0105300>]
  [<c010a5a8>] [<c0105300>] [<c0105324>] [<c0105392>] [<c0105000>]
Code: 0f 0b 3f 01 1c b8 28 c0 58 5a 8b 5c 24 0c e9 67 fe ff ff 8d


>>EIP; c01fbb87 <__kfree_skb+197/1b0>   <=====

>>ebx; c138f480 <_end+1063094/34fcc14>
>>edx; c2706000 <_end+23d9c14/34fcc14>
>>edi; c138f4c4 <_end+10630d8/34fcc14>
>>ebp; c138f480 <_end+1063094/34fcc14>
>>esp; c02e5da4 <init_task_union+1da4/2000>

Trace; c024d8d6 <packet_rcv_spkt+146/1f0>
Trace; c024d8d6 <packet_rcv_spkt+146/1f0>
Trace; c01ffe7f <dev_queue_xmit_nit+7f/b0>
Trace; c0207177 <qdisc_restart+b7/d0>
Trace; c02000cd <dev_queue_xmit+18d/250>
Trace; c0216072 <ip_finish_output2+c2/18f>
Trace; c02066b2 <nf_hook_slow+d2/1b0>
Trace; c02141a1 <ip_output+71/80>
Trace; c0215fb0 <ip_finish_output2+0/18f>
Trace; c0212a1d <ip_forward_finish+1d/40>
Trace; c02066b2 <nf_hook_slow+d2/1b0>
Trace; c0212963 <ip_forward+143/1e0>
Trace; c0212a00 <ip_forward_finish+0/40>
Trace; c0211a6b <ip_rcv_finish+1ab/210>
Trace; c02066b2 <nf_hook_slow+d2/1b0>
Trace; c0211718 <ip_rcv+168/1b0>
Trace; c02118c0 <ip_rcv_finish+0/210>
Trace; c0200630 <netif_receive_skb+b0/150>
Trace; c0200747 <process_backlog+77/180>
Trace; c02008af <net_rx_action+5f/110>
Trace; c0119a96 <do_softirq+96/a0>
Trace; c010831e <do_IRQ+9e/a0>
Trace; c0105300 <default_idle+0/30>
Trace; c010a5a8 <call_do_IRQ+5/d>
Trace; c0105300 <default_idle+0/30>
Trace; c0105324 <default_idle+24/30>
Trace; c0105392 <cpu_idle+42/60>
Trace; c0105000 <_stext+0/0>

Code;  c01fbb87 <__kfree_skb+197/1b0>
00000000 <_EIP>:
Code;  c01fbb87 <__kfree_skb+197/1b0>   <=====
   0:   0f 0b                     ud2a      <=====
Code;  c01fbb89 <__kfree_skb+199/1b0>
   2:   3f                        aas    
Code;  c01fbb8a <__kfree_skb+19a/1b0>
   3:   01 1c b8                  add    %ebx,(%eax,%edi,4)
Code;  c01fbb8d <__kfree_skb+19d/1b0>
   6:   28 c0                     sub    %al,%al
Code;  c01fbb8f <__kfree_skb+19f/1b0>
   8:   58                        pop    %eax
Code;  c01fbb90 <__kfree_skb+1a0/1b0>
   9:   5a                        pop    %edx
Code;  c01fbb91 <__kfree_skb+1a1/1b0>
   a:   8b 5c 24 0c               mov    0xc(%esp,1),%ebx
Code;  c01fbb95 <__kfree_skb+1a5/1b0>
   e:   e9 67 fe ff ff            jmp    fffffe7a <_EIP+0xfffffe7a> c01fba01 <__kfree_skb+11/1b0>
Code;  c01fbb9a <__kfree_skb+1aa/1b0>
  13:   8d 00                     lea    (%eax),%eax

 <0>Kernel panic: Aiee, killing interrupt handler!


Linux distribution is a minimal install of debian stable with the latest
security updates applied. I am the only local user of the machine.


olly@euclid:~$ cat /proc/cpuinfo
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 5
model           : 2
model name      : Pentium 75 - 200
stepping        : 12
cpu MHz         : 132.957
fdiv_bug        : no
hlt_bug         : no
f00f_bug        : yes
coma_bug        : no
fpu             : yes
fpu_exception   : yes
cpuid level     : 1
wp              : yes
flags           : fpu vme de pse tsc msr mce cx8
bogomips        : 265.42


olly@euclid:~$ cat /proc/modules
sch_ingress             1700   1 (autoclean)
cls_u32                 4828   5 (autoclean)
sch_sfq                 3328   3 (autoclean)
sch_cbq                12288   1 (autoclean)
tun                     4096   3 (autoclean)
ip_nat_irc              2544   0 (unused)
ip_conntrack_irc        3184   1 [ip_nat_irc]
ip_nat_ftp              3312   0 (unused)
ipt_MASQUERADE          1888   2
iptable_mangle          2072   0
ip_conntrack_ftp        4208   1 [ip_nat_ftp]
ipt_REDIRECT             728   0
iptable_nat            21422   3 [ip_nat_irc ip_nat_ftp ipt_MASQUERADE ipt_REDIRECT]
ipt_TCPMSS              2328   1
ipt_REJECT              3416 475
ipt_LOG                 3320  27
ipt_limit                824  29
ipt_length               472   0
ipt_unclean             6808   2
iptable_filter          1644   1
ipt_state                568  31
ip_tables              14656  14 [ipt_MASQUERADE iptable_mangle ipt_REDIRECT iptable_nat ipt_TCPMSS ipt_REJECT ipt_LOG ipt_limit ipt_length ipt_unclean iptable_filter ipt_state]
ip_conntrack           25976   4 [ip_nat_irc ip_conntrack_irc ip_nat_ftp ipt_MASQUERADE ip_conntrack_ftp ipt_REDIRECT iptable_nat ipt_state]


olly@euclid:~$ cat /proc/ioports
0000-001f : dma1
0020-003f : pic1
0040-005f : timer
0060-006f : keyboard
0080-008f : dma page reg
00a0-00bf : pic2
00c0-00df : dma2
00f0-00ff : fpu
01f0-01f7 : ide0
02f8-02ff : serial(set)
03c0-03df : vga+
03f6-03f6 : ide0
0cf8-0cff : PCI conf1
f800-f8ff : National Semiconductor Corporation DP83815 (MacPhyter) Ethernet Controller
  f800-f8ff : eth1
fc00-fcff : National Semiconductor Corporation DP83815 (MacPhyter) Ethernet Controller (#2)
  fc00-fcff : eth0


olly@euclid:~$ cat /proc/iomem
00000000-0009fbff : System RAM
000a0000-000bffff : Video RAM area
000c0000-000c7fff : Video ROM
000f0000-000fffff : System ROM
00100000-02ffffff : System RAM
  00100000-0025f624 : Kernel code
  0025f625-002e3ddf : Kernel data
fe000000-feffffff : Cirrus Logic GD 5430/40 [Alpine]
fffbe000-fffbefff : National Semiconductor Corporation DP83815 (MacPhyter) Ethernet Controller
fffbe000-fffbefff : eth1
fffbf000-fffbffff : National Semiconductor Corporation DP83815 (MacPhyter) Ethernet Controller (#2)
fffbf000-fffbffff : eth0
fffc0000-ffffffff : reserved



olly@euclid:~$ sudo lspci -vvv
Password:
00:00.0 Host bridge: Intel Corp. 430FX - 82437FX TSC [Triton I] (rev 02)
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
        Latency: 64

00:07.0 ISA bridge: Intel Corp. 82371FB PIIX ISA [Triton I] (rev 02)
        Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 0

00:08.0 VGA compatible controller: Cirrus Logic GD 5430/40 [Alpine] (rev 47) (prog-if 00 [VGA])
        Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
        Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Region 0: Memory at fe000000 (32-bit, prefetchable) [size=16M]
        Expansion ROM at <unassigned> [disabled] [size=16M]

00:11.0 Ethernet controller: National Semiconductor Corporation DP83815 (MacPhyter) Ethernet Controller
        Subsystem: Netgear: Unknown device f311
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 66 (2750ns min, 13000ns max)
        Interrupt: pin A routed to IRQ 10
        Region 0: I/O ports at f800 [size=256]
        Region 1: Memory at fffbe000 (32-bit, non-prefetchable) [size=4K]
        Expansion ROM at <unassigned> [disabled] [size=64K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME+

00:13.0 Ethernet controller: National Semiconductor Corporation DP83815 (MacPhyter) Ethernet Controller
        Subsystem: Netgear: Unknown device f311
        Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 66 (2750ns min, 13000ns max)
        Interrupt: pin A routed to IRQ 11
        Region 0: I/O ports at fc00 [size=256]
        Region 1: Memory at fffbf000 (32-bit, non-prefetchable) [size=4K]
        Expansion ROM at <unassigned> [disabled] [size=64K]
        Capabilities: [40] Power Management version 2
                Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=320mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
                Status: D0 PME-Enable- DSel=0 DScale=0 PME+



This is obviously a reasonably rare problem for it to take so long to
occur. I have no idea what actually caused to happen when it did. The
machine was running smoothly before for a long time.

Olly Madge
