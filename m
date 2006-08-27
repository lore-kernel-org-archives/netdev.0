From: cagri coltekin <cagri@ripe.net>
Subject: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Sun, 27 Aug 2006 16:23:47 +0200
Message-ID: <20060827142347.GA20092@ripe.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <netdev-owner@vger.kernel.org>
Received: from x10.ripe.net ([193.0.1.10]:14980 "EHLO x10.ripe.net")
	by vger.kernel.org with ESMTP id S932124AbWH0OXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Aug 2006 10:23:50 -0400
To: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

[ Apologies for possible duplicates, and if I'm addressing wrong
  people. ]

The following is the standard bug report form. I believe I have
included enough information for the starters. I'd be happy to try
to provide more if you need it. Please let me know.

Kind Regards,
-- 
Cagri Coltekin

------------------------------------------------------------------------------

[1.] Kernel message: kernel BUG at net/ipv6/ip6_output.c:718

[2.] Full description of the problem/report:
    
 This is a on busy DNS server (serving about 5k queries per
 second). The problem started after we have switched to 2.6
 kernel since it gives better performance. After the the kernel
 bug message below, the system continues to run.  However, bind
 gets stuck, completely unresponsive, killing it makes it zombie
 (parent is init). A new instance of bind can be started, and
 works fine until next time. 

 The problem is not in 2.4, we were running kernel.org 2.4.29
 before.

 I've tried the patch at http://lkml.org/lkml/2006/8/13/56, just
 in case. It does not make any difference.

 The system is a dual CPU (Hyperthreading) Dell Poweredge 2650.

[3.] Keywords: Kernel, networking, IPv6, UDP, DNS 

[4.] Kernel version (from /proc/version):

 Linux version 2.6.17.11-ns-debug (cagri@x10) (gcc version 3.3.5 (Debian 1:3.3.5-8ubuntu2.1)) #6 SMP Sat Aug 26 05:06:53 CEST 2006

 It is vanilla 2.6.17.11 with all unnecessary functionality
 removed during compilation.

 Please note that the kernel is compiled on a different machine,
 I'll provide information on both system below where appropriate.

[5.] Output of Oops.. 

  NOTE that there are bug messages from two consecutive events.

Aug 25 04:03:35 ns kernel: ------------[ cut here ]------------
Aug 25 04:03:35 ns kernel: kernel BUG at net/ipv6/ip6_output.c:718!
Aug 25 04:03:35 ns kernel: invalid operand: 0000 [#1]
Aug 25 04:03:35 ns kernel: SMP 
Aug 25 04:03:35 ns kernel: Modules linked in: uhci_hcd ehci_hcd ohci_hcd aic7xxx ide_cd
Aug 25 04:03:35 ns kernel: CPU:    3
Aug 25 04:03:35 ns kernel: EIP:    0060:[svc_create_socket+189/416]    Not tainted VLI
Aug 25 04:03:35 ns kernel: EFLAGS: 00010282   (2.6.12.6-ncc-server) 
Aug 25 04:03:35 ns kernel: EIP is at ip6_fragment+0x24d/0x880
Aug 25 04:03:35 ns kernel: eax: fffffff2   ebx: f5391ff8   ecx: 000007e8   edx: f792a600
Aug 25 04:03:35 ns kernel: esi: f792a800   edi: f5391ff8   ebp: f513d180   esp: f6defbac
Aug 25 04:03:35 ns kernel: ds: 007b   es: 007b   ss: 0068
Aug 25 04:03:35 ns kernel: Process named (pid: 1942, threadinfo=f6dee000 task=f7959a20)
Aug 25 04:03:35 ns kernel: Stack: f31a8480 000007e8 f5392000 fffffdd0 f6dee000 00000000 b6346cc8 8000021e 
Aug 25 04:03:35 ns kernel:        00000000 000007e8 00000000 fffffdd0 ffffffee 000007e8 fffffdd4 f7075780 
Aug 25 04:03:35 ns kernel:        f792a048 f792a018 f31a8480 f792a040 f7b18080 c031fd50 f31a8480 c031fa30 
Aug 25 04:03:35 ns kernel: Call Trace:
Aug 25 04:03:35 ns kernel:  [svc_tcp_accept+960/992] ip6_output+0x30/0x40
Aug 25 04:03:35 ns kernel:  [svc_tcp_accept+160/992] ip6_output2+0x0/0x2f0
Aug 25 04:03:35 ns kernel:  [svcauth_unix_accept+43/496] ip6_push_pending_frames+0x29b/0x470
Aug 25 04:03:35 ns kernel:  [__func__.2+898/986] udp_v6_push_pending_frames+0x148/0x1b0
Aug 25 04:03:35 ns kernel:  [ip_send_reply+144/592] ip_generic_getfrag+0x0/0xc0
Aug 25 04:03:35 ns kernel:  [__func__.1+0/17] udpv6_sendmsg+0x52c/0x920
Aug 25 04:03:35 ns kernel:  [arp_solicit+356/464] udp_recvmsg+0x54/0x300
Aug 25 04:03:35 ns kernel:  [igmp_rcv+125/336] inet_sendmsg+0x4d/0x60
Aug 25 04:03:35 ns kernel:  [sys_connect+90/176] sock_sendmsg+0xda/0x100
Aug 25 04:03:35 ns kernel:  [find_busiest_group+209/736] find_busiest_group+0xd1/0x2e0
Aug 25 04:03:35 ns kernel:  [pci_bus_read_config_dword+38/144] copy_from_user+0x46/0x80
Aug 25 04:03:35 ns kernel:  [autoremove_wake_function+0/96] autoremove_wake_function+0x0/0x60
Aug 25 04:03:35 ns kernel:  [sock_wfree+15/96] sys_sendmsg+0x18f/0x1f0
Aug 25 04:03:35 ns kernel:  [futex_wait+292/576] futex_wait+0x124/0x240
Aug 25 04:03:35 ns kernel:  [find_extend_vma+41/144] find_extend_vma+0x29/0x90
Aug 25 04:03:35 ns kernel:  [default_wake_function+0/32] default_wake_function+0x0/0x20
Aug 25 04:03:35 ns kernel:  [futex_wake+123/208] futex_wake+0x7b/0xd0
Aug 25 04:03:35 ns kernel:  [pci_bus_read_config_dword+38/144] copy_from_user+0x46/0x80
Aug 25 04:03:35 ns kernel:  [sock_alloc_send_pskb+370/480] sys_socketcall+0x242/0x260
Aug 25 04:03:35 ns kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Aug 25 04:03:35 ns kernel: Code: 00 00 00 00 8b 54 24 2c 8b 4c 24 24 89 54 24 0c 8b 45 24 89 4c 24 04 89 44 24 08 8b 44 24 58 89 04 24 e8 a7 44 fa ff 85 c0 74 08 <0f> 0b ce 02 86 07 3a c0 0f b7 44 24 20 0f b6 d0 c1 e2 08 c1 e8 
Aug 25 05:49:07 ns kernel:  <7>UDP: bad checksum. From 213.147.0.92:53 to 193.0.0.195:2101 ulen 52
Aug 25 06:30:02 ns kernel: ------------[ cut here ]------------
Aug 25 06:30:02 ns kernel: kernel BUG at net/ipv6/ip6_output.c:718!
Aug 25 06:30:02 ns kernel: invalid operand: 0000 [#2]
Aug 25 06:30:02 ns kernel: SMP 
Aug 25 06:30:02 ns kernel: Modules linked in: uhci_hcd ehci_hcd ohci_hcd aic7xxx ide_cd
Aug 25 06:30:02 ns kernel: CPU:    0
Aug 25 06:30:02 ns kernel: EIP:    0060:[svc_create_socket+189/416]    Not tainted VLI
Aug 25 06:30:02 ns kernel: EFLAGS: 00010282   (2.6.12.6-ncc-server) 
Aug 25 06:30:02 ns kernel: EIP is at ip6_fragment+0x24d/0x880
Aug 25 06:30:02 ns kernel: eax: fffffff2   ebx: f301a7f0   ecx: 000007e0   edx: f55cee00
Aug 25 06:30:02 ns kernel: esi: f55ceff8   edi: f301a7f0   ebp: f65d6c80   esp: f7305bac
Aug 25 06:30:02 ns kernel: ds: 007b   es: 007b   ss: 0068
Aug 25 06:30:02 ns kernel: Process named (pid: 13193, threadinfo=f7304000 task=f6867520)
Aug 25 06:30:02 ns kernel: Stack: f5036a80 000007e0 f301a7f8 fffffdd8 f7304000 00000000 b7b9bcc8 a80001fe 
Aug 25 06:30:02 ns kernel:        00000000 000007e0 00000000 fffffdd8 ffffffd6 000007e0 fffffddc f7075480 
Aug 25 06:30:02 ns kernel:        f55ce848 f55ce818 f5036a80 f55ce840 f7b18800 c031fd50 f5036a80 c031fa30 
Aug 25 06:30:02 ns kernel: Call Trace:
Aug 25 06:30:02 ns kernel:  [svc_tcp_accept+960/992] ip6_output+0x30/0x40
Aug 25 06:30:02 ns kernel:  [svc_tcp_accept+160/992] ip6_output2+0x0/0x2f0
Aug 25 06:30:02 ns kernel:  [svcauth_unix_accept+43/496] ip6_push_pending_frames+0x29b/0x470
Aug 25 06:30:02 ns kernel:  [__func__.2+898/986] udp_v6_push_pending_frames+0x148/0x1b0
Aug 25 06:30:02 ns kernel:  [ip_send_reply+144/592] ip_generic_getfrag+0x0/0xc0
Aug 25 06:30:02 ns kernel:  [__func__.1+0/17] udpv6_sendmsg+0x52c/0x920
Aug 25 06:30:02 ns kernel:  [arp_solicit+356/464] udp_recvmsg+0x54/0x300
Aug 25 06:30:02 ns kernel:  [igmp_rcv+125/336] inet_sendmsg+0x4d/0x60
Aug 25 06:30:02 ns kernel:  [sys_connect+90/176] sock_sendmsg+0xda/0x100
Aug 25 06:30:02 ns kernel:  [find_busiest_group+209/736] find_busiest_group+0xd1/0x2e0
Aug 25 06:30:02 ns kernel:  [pci_bus_read_config_dword+38/144] copy_from_user+0x46/0x80
Aug 25 06:30:02 ns kernel:  [autoremove_wake_function+0/96] autoremove_wake_function+0x0/0x60
Aug 25 06:30:02 ns kernel:  [sock_wfree+15/96] sys_sendmsg+0x18f/0x1f0
Aug 25 06:30:02 ns kernel:  [futex_wait+292/576] futex_wait+0x124/0x240
Aug 25 06:30:02 ns kernel:  [find_extend_vma+41/144] find_extend_vma+0x29/0x90
Aug 25 06:30:02 ns kernel:  [default_wake_function+0/32] default_wake_function+0x0/0x20
Aug 25 06:30:02 ns kernel:  [futex_wake+123/208] futex_wake+0x7b/0xd0
Aug 25 06:30:02 ns kernel:  [pci_bus_read_config_dword+38/144] copy_from_user+0x46/0x80
Aug 25 06:30:02 ns kernel:  [sock_alloc_send_pskb+370/480] sys_socketcall+0x242/0x260
Aug 25 06:30:02 ns kernel:  [syscall_call+7/11] syscall_call+0x7/0xb
Aug 25 06:30:02 ns kernel: Code: 00 00 00 00 8b 54 24 2c 8b 4c 24 24 89 54 24 0c 8b 45 24 89 4c 24 04 89 44 24 08 8b 44 24 58 89 04 24 e8 a7 44 fa ff 85 c0 74 08 <0f> 0b ce 02 86 07 3a c0 0f b7 44 24 20 0f b6 d0 c1 e2 08 c1 e8 
------------[ cut here ]------------

[6.] A small shell script or example program which triggers the
     problem (if possible)

 Even though the problem occurs quite quite deterministically, I
 do not (yet) have a method to re-produce it. Currently I have a
 workaround (Queries via IPv6 is handled by another system
 running 2.4), so do not hit the bug on production system.
 However, I have traffic dumps from the time span that we had
 problems, so I can try to reproduce in a test system if
 necessary. 

[7.] Environment
[7.1.] Software (add the output of the ver_linux script here)


Environment that kernel is compiled:
------------[ cut here ]------------
x10$ scripts/ver_linux 
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux x10 2.6.10-5-686-smp #1 SMP Thu Aug 18 22:54:45 UTC 2005 i686 GNU/Linux
 
Gnu C                  3.3.5
Gnu make               3.80
binutils               2.15
util-linux             2.12p
mount                  2.12p
module-init-tools      3.1
e2fsprogs              1.35
jfsutils               1.1.6
reiserfsprogs          3.6.19
reiser4progs           1.0.3
xfsprogs               2.6.20
quota-tools            3.12.
nfs-utils              1.0.6
Linux C Library        2.3.2
Dynamic linker (ldd)   2.3.2
Procps                 3.2.4
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.2.1
udev                   050
Modules Loaded         proc_intf freq_table cpufreq_userspace cpufreq_powersave cpufreq_ondemand md msdos fat usb_storage rfcomm l2cap hci_usb bluetooth nls_cp437 isofs udf af_packet nfs nfsd exportfs lockd sunrpc autofs4 ipv6 tg3 i2c_i801 i2c_core usbhid piix snd_intel8x0 snd_ac97_codec snd_pcm_oss snd_mixer_oss snd_pcm snd_timer snd soundcore snd_page_alloc ehci_hcd uhci_hcd usbcore pci_hotplug intel_agp agpgart rtc pcspkr capability commoncap tsdev evdev psmouse mousedev parport_pc lp parport ide_generic ide_disk ide_cd ide_core cdrom ext3 jbd mbcache dm_mod sd_mod ata_piix libata scsi_mod unix thermal processor fan fbcon font bitblit vesafb cfbcopyarea cfbimgblt cfbfillrect
------------[ cut here ]------------

Production Environment that the kernel runs:
------------[ cut here ]------------
ns# sh ./ver_linux 
If some fields are empty or look unusual you may have an old version.
Compare to the current minimal requirements in Documentation/Changes.
 
Linux ns 2.6.17.11-ns-debug #6 SMP Sat Aug 26 05:06:53 CEST 2006 i686 GNU/Linux
 
Gnu C                  3.3.5
Gnu make               3.80
binutils               2.15
util-linux             2.12p
mount                  2.12p
module-init-tools      3.2-pre1
e2fsprogs              1.37
nfs-utils              1.0.6
Linux C Library        2.3.2
Dynamic linker (ldd)   2.3.2
Procps                 3.2.1
Net-tools              1.60
Console-tools          0.2.3
Sh-utils               5.2.1
Modules Loaded         ide_cd cdrom
------------[ cut here ]------------

Production environment runs debian sarge (should be fairly
up-to-date). The bind version running on the system is 9.3.2 with
a patch (AFAIK not yet public) provided by ISC.

[7.2.] Processor information (from /proc/cpuinfo):
------------[ cut here ]------------
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 15
model		: 2
model name	: Intel(R) Xeon(TM) CPU 2.40GHz
stepping	: 7
cpu MHz		: 2387.891
cache size	: 512 KB
physical id	: 0
siblings	: 2
core id		: 0
cpu cores	: 1
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 2
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe cid
bogomips	: 4780.50

processor	: 1
vendor_id	: GenuineIntel
cpu family	: 15
model		: 2
model name	: Intel(R) Xeon(TM) CPU 2.40GHz
stepping	: 7
cpu MHz		: 2387.891
cache size	: 512 KB
physical id	: 0
siblings	: 2
core id		: 0
cpu cores	: 1
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 2
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe cid
bogomips	: 4775.16

processor	: 2
vendor_id	: GenuineIntel
cpu family	: 15
model		: 2
model name	: Intel(R) Xeon(TM) CPU 2.40GHz
stepping	: 7
cpu MHz		: 2387.891
cache size	: 512 KB
physical id	: 3
siblings	: 2
core id		: 0
cpu cores	: 1
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 2
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe cid
bogomips	: 4775.25

processor	: 3
vendor_id	: GenuineIntel
cpu family	: 15
model		: 2
model name	: Intel(R) Xeon(TM) CPU 2.40GHz
stepping	: 7
cpu MHz		: 2387.891
cache size	: 512 KB
physical id	: 3
siblings	: 2
core id		: 0
cpu cores	: 1
fdiv_bug	: no
hlt_bug		: no
f00f_bug	: no
coma_bug	: no
fpu		: yes
fpu_exception	: yes
cpuid level	: 2
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe cid
bogomips	: 4775.36
------------[ cut here ]------------

[7.3.] Module information (from /proc/modules):

ide_cd 41220 0 - Live 0xf8a2f000
cdrom 42784 1 ide_cd, Live 0xf8831000

[7.4.] Loaded driver and hardware information (/proc/ioports, /proc/iomem)
------------[ begin: /proc/ioports ]------------
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
01f0-01f7 : ide0
02f8-02ff : serial
03c0-03df : vga+
03f6-03f6 : ide0
03f8-03ff : serial
0800-0803 : PM1b_EVT_BLK
0804-0805 : PM1b_CNT_BLK
0808-080b : PM_TMR
080c-0813 : GPE0_BLK
0844-0847 : PM1a_EVT_BLK
0848-0849 : PM1a_CNT_BLK
0850-0857 : GPE1_BLK
08b0-08bf : 0000:00:0f.1
c000-cfff : PCI Bus #05
  c800-c8ff : 0000:05:06.1
  cc00-ccff : 0000:05:06.0
e800-e8ff : 0000:00:0e.0
ec80-ecbf : 0000:00:04.1
  ec80-ec87 : serial
ece8-ecef : 0000:00:04.0
ecf4-ecf7 : 0000:00:04.2
ecf8-ecff : 0000:00:04.0
------------[ end: /proc/ioports ]------------
------------[ begin: /proc/iomem ]------------
00000000-0009ffff : System RAM
000a0000-000bffff : Video RAM area
000c0000-000c7fff : Video ROM
000cc000-000cc5ff : Adapter ROM
000f0000-000fffff : System ROM
00100000-effeffff : System RAM
  00100000-002d8cee : Kernel code
  002d8cef-003d3503 : Kernel data
efff0000-efffebff : ACPI Tables
efffec00-efffefff : reserved
f0000000-f7ffffff : 0000:04:08.1
f8000000-f801ffff : 0000:00:0e.0
f8100000-f81fffff : PCI Bus #05
  f8100000-f811ffff : 0000:05:06.1
fcb00000-fcb0ffff : 0000:04:08.1
fcc00000-fcdfffff : PCI Bus #05
  fccfe000-fccfefff : 0000:05:06.1
  fccff000-fccfffff : 0000:05:06.0
  fcd00000-fcd1ffff : 0000:05:06.0
fcf00000-fcf0ffff : 0000:03:08.0
  fcf00000-fcf0ffff : tg3
fcf10000-fcf1ffff : 0000:03:06.0
  fcf10000-fcf1ffff : tg3
fd000000-fdffffff : 0000:00:0e.0
fe000000-fe00ffff : 0000:00:04.0
fe100000-fe100fff : 0000:00:0f.2
fe101000-fe101fff : 0000:00:0e.0
fe102000-fe102fff : 0000:00:04.1
feb00000-feb7ffff : 0000:00:04.1
feb80000-feb80fff : 0000:00:04.0
fec00000-fec0ffff : reserved
fee00000-fee0ffff : reserved
fff80000-ffffffff : reserved
------------[ end: /proc/iomem ]------------

[7.5.] PCI information ('lspci -vvv' as root)
------------[ begin: 'lspci -vvv' ]------------
0000:00:00.0 Host bridge: ServerWorks CMIC-WS Host Bridge (GC-LE chipset) (rev 13)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

0000:00:00.1 Host bridge: ServerWorks CMIC-WS Host Bridge (GC-LE chipset)
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

0000:00:00.2 Host bridge: ServerWorks CMIC-LE
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR-

0000:00:04.0 ff00: Dell Embedded Remote Access or ERA/O
	Subsystem: Dell Embedded Remote Access or ERA/O
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32, Cache Line Size: 0x10 (64 bytes)
	Interrupt: pin A routed to IRQ 11
	Region 0: Memory at feb80000 (32-bit, prefetchable) [size=4K]
	Region 1: I/O ports at ecf8 [size=8]
	Region 2: I/O ports at ece8 [size=8]
	Expansion ROM at fe000000 [disabled] [size=64K]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

0000:00:04.1 ff00: Dell Remote Access Card III
	Subsystem: Dell Remote Access Card III
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin B routed to IRQ 16
	Region 0: Memory at fe102000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at ec80 [size=64]
	Region 2: Memory at feb00000 (32-bit, prefetchable) [size=512K]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

0000:00:04.2 ff00: Dell Embedded Remote Access: BMC/SMIC device
	Subsystem: Dell Embedded Remote Access: BMC/SMIC device
	Control: I/O+ Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Interrupt: pin C routed to IRQ 7
	Region 0: I/O ports at ecf4 [size=4]
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

0000:00:0e.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27) (prog-if 00 [VGA])
	Subsystem: Dell: Unknown device 0121
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop+ ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (2000ns min), Cache Line Size: 0x10 (64 bytes)
	Region 0: Memory at fd000000 (32-bit, non-prefetchable) [size=16M]
	Region 1: I/O ports at e800 [size=256]
	Region 2: Memory at fe101000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at f8000000 [disabled] [size=128K]
	Capabilities: [5c] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

0000:00:0f.0 Host bridge: ServerWorks CSB5 South Bridge (rev 93)
	Subsystem: ServerWorks CSB5 South Bridge
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 32

0000:00:0f.1 IDE interface: ServerWorks CSB5 IDE Controller (rev 93) (prog-if 82 [Master PriP])
	Subsystem: ServerWorks CSB5 IDE Controller
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 0: I/O ports at <ignored>
	Region 1: I/O ports at <ignored>
	Region 2: I/O ports at <ignored>
	Region 3: I/O ports at <ignored>
	Region 4: I/O ports at 08b0 [size=16]

0000:00:0f.2 USB Controller: ServerWorks OSB4/CSB5 OHCI USB Controller (rev 05) (prog-if 10 [OHCI])
	Subsystem: ServerWorks OSB4/CSB5 OHCI USB Controller
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (20000ns max)
	Interrupt: pin A routed to IRQ 5
	Region 0: Memory at fe100000 (32-bit, non-prefetchable) [size=4K]

0000:00:0f.3 ISA bridge: ServerWorks CSB5 LPC bridge
	Subsystem: ServerWorks: Unknown device 0230
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66MHz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

0000:00:10.0 Host bridge: ServerWorks CIOB-X2 PCI-X I/O Bridge (rev 03)
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Capabilities: [60] 
0000:00:10.2 Host bridge: ServerWorks CIOB-X2 PCI-X I/O Bridge (rev 03)
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Capabilities: [60] 
0000:00:11.0 Host bridge: ServerWorks CIOB-X2 PCI-X I/O Bridge (rev 03)
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Capabilities: [60] 
0000:00:11.2 Host bridge: ServerWorks CIOB-X2 PCI-X I/O Bridge (rev 03)
	Control: I/O- Mem+ BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Capabilities: [60] 
0000:03:06.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit Ethernet (rev 15)
	Subsystem: Dell Broadcom BCM5701 1000Base-T
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (16000ns min), Cache Line Size: 0x10 (64 bytes)
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at fcf10000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [40] PCI-X non-bridge device.
		Command: DPERE- ERO- RBC=0 OST=0
		Status: Bus=3 Dev=6 Func=1 64bit+ 133MHz+ SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
		Address: a526860a9e070490  Data: 4e6a

0000:03:08.0 Ethernet controller: Broadcom Corporation NetXtreme BCM5701 Gigabit Ethernet (rev 15)
	Subsystem: Dell Broadcom BCM5701 1000Base-T
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (16000ns min), Cache Line Size: 0x10 (64 bytes)
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at fcf00000 (64-bit, non-prefetchable) [size=64K]
	Capabilities: [40] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=0 OST=0
		Status: Bus=3 Dev=8 Func=1 64bit+ 133MHz+ SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-
	Capabilities: [48] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [50] Vital Product Data
	Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=0/3 Enable-
		Address: 850016aeb9a02088  Data: 3569

0000:04:08.0 PCI bridge: Intel Corp. 80303 I/O Processor PCI-to-PCI Bridge (rev 01) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32, Cache Line Size: 0x10 (64 bytes)
	Bus: primary=04, secondary=05, subordinate=05, sec-latency=32
	I/O behind bridge: 0000c000-0000cfff
	Memory behind bridge: fcc00000-fcdfffff
	Prefetchable memory behind bridge: f8100000-f81fffff
	BridgeCtl: Parity- SERR+ NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [68] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

0000:04:08.1 RAID bus controller: Dell PowerEdge Expandable RAID Controller 3/Di (rev 01)
	Subsystem: Dell: Unknown device 0121
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=slow >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32, Cache Line Size: 0x10 (64 bytes)
	Interrupt: pin A routed to IRQ 19
	Region 0: Memory at f0000000 (32-bit, prefetchable) [size=128M]
	Expansion ROM at fcb00000 [disabled] [size=64K]
	Capabilities: [80] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

0000:05:06.0 SCSI storage controller: Adaptec RAID subsystem HBA (rev 01)
	Subsystem: Dell PowerEdge 2400,2500,2550,4400
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (10000ns min, 6250ns max), Cache Line Size: 0x10 (64 bytes)
	Interrupt: pin A routed to IRQ 7
	BIST result: 00
	Region 0: I/O ports at cc00 [size=256]
	Region 1: Memory at fccff000 (64-bit, non-prefetchable) [size=4K]
	Expansion ROM at fcd00000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

0000:05:06.1 SCSI storage controller: Adaptec RAID subsystem HBA (rev 01)
	Subsystem: Dell PowerEdge 2400,2500,2550,4400
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR+ FastB2B-
	Status: Cap+ 66MHz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 32 (10000ns min, 6250ns max), Cache Line Size: 0x10 (64 bytes)
	Interrupt: pin B routed to IRQ 11
	BIST result: 00
	Region 0: I/O ports at c800 [size=256]
	Region 1: Memory at fccfe000 (64-bit, non-prefetchable) [size=4K]
	Expansion ROM at f8100000 [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
------------[ end: 'lspci -vvv' ]------------


[7.6.] SCSI information (from /proc/scsi/scsi)

CONFIG_SCSI_PROC_FS is not set. I can provide scsi information
if you think it is relevant.

[7.7.] Other information that might be relevant to the problem
       (please look in /proc and include all information that you
       think to be relevant):
------------------------------------------------------------------------------
