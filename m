From: Ben Greear <greearb@candelatech.com>
Subject: Problems with e1000 in 2.4.23
Date: Sat, 29 Nov 2003 23:08:37 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC99775.5020300@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090505070403080406040904"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>,
        "Feldman, Scott" <scott.feldman@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090505070403080406040904
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

I just started doing some testing on 2.4.23 with a dual-port
Intel NIC.  I have seen several crashes and reproducible 'TX watchdog timeout'
messages when connecting an e1000 port to both an e100 on the same machine
and to a tulip on another machine...  I did not see problems when passing
traffic between the two e1000 ports, so the tx-timeout issue seems confined
to e1000 -> 100bt.

I'm running on a dual-amd box which has had issues in the past, but
a bios update seems to have fixed it's pci-routing issues.  Also, I
am running some personal networking patches.

That said, I have not seen any of these issues on 2.4.23-pre9 (+ my patches),
and I saw the same problems on 2.4.23 both with my patched e1000 and with an
unpatched e1000.

Attached is an oops that did not hang the machine.  The hard hang looked
like memory corruption (a few of the registers were 0x15141312,
and the payload of the packets I was sending was incrementing bytes, ie 0x010203040506...).
I'll crank up the serial console and see if I can capture some of
the hard crashes...

The lspci and dmesg files are from a 2.4.23-pre9 boot.

As usual, it could all be my fault, so I'd like to hear if anyone can confirm
or deny the e1000 -> 100bt issue.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------090505070403080406040904
Content-Type: text/plain;
 name="e1000_dump.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="e1000_dump.txt"

ksymoops 2.4.5 on i686 2.4.23.  Options used
     -V (default)
     -k /proc/ksyms (default)
     -l /proc/modules (default)
     -o /lib/modules/2.4.23/ (default)
     -m /boot/System.map-2.4.23 (default)

Warning: You did not tell me where to find symbol information.  I will
assume that the log matches the kernel and modules that are running
right now and I'll use the default options above for symbol resolution.
If the current kernel and/or modules do not match the log, you can get
more accurate output by telling me the kernel version and where to find
map, modules, ksyms etc.  ksymoops -h explains the options.

Error (expand_objects): cannot stat(/lib/ext3.o) for ext3
Error (expand_objects): cannot stat(/lib/jbd.o) for jbd
Warning (map_ksym_to_module): cannot match loaded module ext3 to a unique module object.  Trace may not be reliable.
Nov 29 22:22:17 athlon2 kernel: Unable to handle kernel NULL pointer dereference at virtual address 00000007
Nov 29 22:22:17 athlon2 kernel: c01f0d5a
Nov 29 22:22:17 athlon2 kernel: *pde = 00000000
Nov 29 22:22:17 athlon2 kernel: Oops: 0002
Nov 29 22:22:17 athlon2 kernel: CPU:    1
Nov 29 22:22:17 athlon2 kernel: EIP:    0010:[<c01f0d5a>]    Not tainted
Using defaults from ksymoops -t elf32-i386 -a i386
Nov 29 22:22:17 athlon2 kernel: EFLAGS: 00010206
Nov 29 22:22:17 athlon2 kernel: eax: 00000003   ebx: d620d9c0   ecx: dfeb9690   edx: d620d9c0
Nov 29 22:22:17 athlon2 kernel: esi: dba46a50   edi: d83c0000   ebp: 00002e68   esp: d4e23e9c
Nov 29 22:22:17 athlon2 kernel: ds: 0018   es: 0018   ss: 0018
Nov 29 22:22:17 athlon2 kernel: Process ip (pid: 3963, stackpage=d4e23000)
Nov 29 22:22:17 athlon2 kernel: Stack: d620d900 00000000 00000030
Nov 29 22:22:17 athlon2 kernel: d83c2e68 e0912333 d620d9c0 00001042 00000000 
Nov 29 22:22:17 athlon2 kernel:        000001ef
Nov 29 22:22:17 athlon2 kernel: dba46980 00001003 00001042 00000000 e0911af6 dba46980 dba46800
Nov 29 22:22:17 athlon2 kernel:        c01f4d87 dba46800 00000009 dba46800 dba46800 00001003
Nov 29 22:22:17 athlon2 kernel: c01f62d9 dba46800 
Nov 29 22:22:17 athlon2 kernel: Call Trace:    [<e0912333>] [<e0911af6>]
Nov 29 22:22:17 athlon2 kernel:  [<c01f4d87>] [<c01f62d9>] [<c01f482e>]
Nov 29 22:22:17 athlon2 kernel:   [<c02367d0>] [<c01ed3e0>]
Nov 29 22:22:17 athlon2 kernel:  [<c01ed420>] [<c0155540>] [<c01091ff>]
Nov 29 22:22:17 athlon2 kernel: Code: f0 ff 48 04 


>>EIP; c01f0d5a <__kfree_skb+1a/170>   <=====

>>ebx; d620d9c0 <_end+15ebad88/204ba448>
>>ecx; dfeb9690 <_end+1fb66a58/204ba448>
>>edx; d620d9c0 <_end+15ebad88/204ba448>
>>esi; dba46a50 <_end+1b6f3e18/204ba448>
>>edi; d83c0000 <_end+1806d3c8/204ba448>
>>ebp; 00002e68 Before first symbol
>>esp; d4e23e9c <_end+14ad1264/204ba448>

Trace; e0912333 <[e1000]e1000_clean_rx_ring+53/110>
Trace; e0911af6 <[e1000]e1000_close+16/30>
Trace; c01f4d87 <dev_close+c7/d0>
Trace; c01f62d9 <dev_change_flags+129/140>
Trace; c01f482e <dev_get+1e/40>
Trace; c02367d0 <devinet_ioctl+290/610>
Trace; c01ed3e0 <sock_ioctl+0/80>
Trace; c01ed420 <sock_ioctl+40/80>
Trace; c0155540 <sys_ioctl+f0/2a0>
Trace; c01091ff <system_call+33/38>

Code;  c01f0d5a <__kfree_skb+1a/170>
00000000 <_EIP>:
Code;  c01f0d5a <__kfree_skb+1a/170>
   0:   f0 ff 48 04               lock decl 0x4(%eax)


2 warnings and 2 errors issued.  Results may not be reliable.

--------------090505070403080406040904
Content-Type: text/plain;
 name="amd_lspci.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="amd_lspci.txt"

00:00.0 Host bridge: Advanced Micro Devices [AMD] AMD-760 MP [IGD4-2P] System Controller (rev 11)
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 32
	Region 0: Memory at f8000000 (32-bit, prefetchable) [size=64M]
	Region 1: Memory at f6200000 (32-bit, prefetchable) [size=4K]
	Region 2: I/O ports at 1090 [disabled] [size=4]
	Capabilities: [a0] AGP version 2.0
		Status: RQ=15 SBA+ 64bit- FW- Rate=x1,x2
		Command: RQ=0 SBA+ AGP+ 64bit- FW- Rate=<none>

00:01.0 PCI bridge: Advanced Micro Devices [AMD] AMD-760 MP [IGD4-2P] AGP Bridge (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64
	Bus: primary=00, secondary=01, subordinate=01, sec-latency=64
	I/O behind bridge: 0000f000-00000fff
	Memory behind bridge: fff00000-000fffff
	Prefetchable memory behind bridge: fff00000-000fffff
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-

00:07.0 ISA bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] ISA (rev 05)
	Control: I/O+ Mem+ BusMaster+ SpecCycle+ MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0

00:07.1 IDE interface: Advanced Micro Devices [AMD] AMD-768 [Opus] IDE (rev 04) (prog-if 8a [Master SecP PriP])
	Subsystem: Advanced Micro Devices [AMD] AMD-768 [Opus] IDE
	Control: I/O+ Mem- BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 0
	Region 4: I/O ports at f000 [size=16]

00:07.3 Bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] ACPI (rev 03)
	Subsystem: Advanced Micro Devices [AMD] AMD-768 [Opus] ACPI
	Control: I/O- Mem- BusMaster- SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-

00:08.0 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (Copper) (rev 01)
	Subsystem: Intel Corp. PRO/1000 MT Dual Port Server Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (63750ns min), cache line size 10
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f4000000 (64-bit, non-prefetchable) [size=128K]
	Region 4: I/O ports at 1000 [size=64]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=0 OST=0
		Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000

00:08.1 Ethernet controller: Intel Corp. 82546EB Gigabit Ethernet Controller (Copper) (rev 01)
	Subsystem: Intel Corp. PRO/1000 MT Dual Port Server Adapter
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64 (63750ns min), cache line size 10
	Interrupt: pin B routed to IRQ 17
	Region 0: Memory at f4020000 (64-bit, non-prefetchable) [size=128K]
	Region 4: I/O ports at 1040 [size=64]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1- D2- AuxCurrent=0mA PME(D0+,D1-,D2-,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [e4] PCI-X non-bridge device.
		Command: DPERE- ERO+ RBC=0 OST=0
		Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-	Capabilities: [f0] Message Signalled Interrupts: 64bit+ Queue=0/0 Enable-
		Address: 0000000000000000  Data: 0000

00:09.0 PCI bridge: Intel Corp. 21154 PCI-to-PCI Bridge (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 64, cache line size 10
	Bus: primary=00, secondary=02, subordinate=02, sec-latency=68
	I/O behind bridge: 00002000-00002fff
	Memory behind bridge: f4100000-f41fffff
	Prefetchable memory behind bridge: 00000000fff00000-0000000000000000
	BridgeCtl: Parity- SERR- NoISA+ VGA- MAbort- >Reset- FastB2B-
	Capabilities: [dc] Power Management version 1
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-
		Bridge: PM- B3+

00:10.0 PCI bridge: Advanced Micro Devices [AMD] AMD-768 [Opus] PCI (rev 05) (prog-if 00 [Normal decode])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz+ UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort+ >SERR- <PERR-
	Latency: 99
	Bus: primary=00, secondary=03, subordinate=03, sec-latency=168
	I/O behind bridge: 00003000-00003fff
	Memory behind bridge: f4200000-f5ffffff
	Prefetchable memory behind bridge: fff00000-000fffff
	BridgeCtl: Parity- SERR- NoISA+ VGA+ MAbort- >Reset- FastB2B-

02:00.0 Ethernet controller: Intel Corp. 82559ER (rev 10)
	Subsystem: Ramix Inc: Unknown device 0610
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 66 (2000ns min, 14000ns max), cache line size 10
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at f4180000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at 2000 [size=64]
	Region 2: Memory at f4100000 (32-bit, non-prefetchable) [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-

02:01.0 Ethernet controller: Intel Corp. 82559ER (rev 10)
	Subsystem: Ramix Inc: Unknown device 0610
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 66 (2000ns min, 14000ns max), cache line size 10
	Interrupt: pin A routed to IRQ 18
	Region 0: Memory at f4181000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at 2040 [size=64]
	Region 2: Memory at f4120000 (32-bit, non-prefetchable) [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-

02:02.0 Ethernet controller: Intel Corp. 82559ER (rev 10)
	Subsystem: Ramix Inc: Unknown device 0610
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 66 (2000ns min, 14000ns max), cache line size 10
	Interrupt: pin A routed to IRQ 16
	Region 0: Memory at f4182000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at 2080 [size=64]
	Region 2: Memory at f4140000 (32-bit, non-prefetchable) [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-

02:03.0 Ethernet controller: Intel Corp. 82559ER (rev 10)
	Subsystem: Ramix Inc: Unknown device 0610
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 66 (2000ns min, 14000ns max), cache line size 10
	Interrupt: pin A routed to IRQ 17
	Region 0: Memory at f4183000 (32-bit, non-prefetchable) [size=4K]
	Region 1: I/O ports at 20c0 [size=64]
	Region 2: Memory at f4160000 (32-bit, non-prefetchable) [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI+ D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-

03:00.0 USB Controller: Advanced Micro Devices [AMD] AMD-768 [Opus] USB (rev 07) (prog-if 10 [OHCI])
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap- 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR+
	Latency: 64 (20000ns max)
	Interrupt: pin D routed to IRQ 19
	Region 0: Memory at f4200000 (32-bit, non-prefetchable) [size=4K]

03:07.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27) (prog-if 00 [VGA])
	Subsystem: ATI Technologies Inc Rage XL
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping+ SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 66 (2000ns min), cache line size 10
	Region 0: Memory at f5000000 (32-bit, non-prefetchable) [size=16M]
	Region 1: I/O ports at 3000 [size=256]
	Region 2: Memory at f4201000 (32-bit, non-prefetchable) [size=4K]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: [5c] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot-,D3cold-)
		Status: D0 PME-Enable- DSel=0 DScale=0 PME-

03:08.0 Ethernet controller: 3Com Corporation 3c980-TX 10/100baseTX NIC [Python-T] (rev 78)
	Subsystem: Tyan Computer Thunder K7 S2462
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 80 (2500ns min, 2500ns max), cache line size 10
	Interrupt: pin A routed to IRQ 18
	Region 0: I/O ports at 3400 [size=128]
	Region 1: Memory at f4202000 (32-bit, non-prefetchable) [size=128]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-

03:09.0 Ethernet controller: 3Com Corporation 3c980-TX 10/100baseTX NIC [Python-T] (rev 78)
	Subsystem: Tyan Computer Thunder K7 S2462
	Control: I/O+ Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop- ParErr- Stepping- SERR- FastB2B-
	Status: Cap+ 66Mhz- UDF- FastB2B- ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
	Latency: 80 (2500ns min, 2500ns max), cache line size 10
	Interrupt: pin A routed to IRQ 19
	Region 0: I/O ports at 3480 [size=128]
	Region 1: Memory at f4202400 (32-bit, non-prefetchable) [size=128]
	Expansion ROM at <unassigned> [disabled] [size=128K]
	Capabilities: [dc] Power Management version 2
		Flags: PMEClk- DSI- D1+ D2+ AuxCurrent=0mA PME(D0+,D1+,D2+,D3hot+,D3cold+)
		Status: D0 PME-Enable- DSel=0 DScale=2 PME-


--------------090505070403080406040904
Content-Type: text/plain;
 name="amd_dmesg.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="amd_dmesg.txt"

Linux version 2.4.23-pre9 (greear@grok.yi.org) (gcc version 3.2.2 20030222 (Red Hat Linux 3.2.2-5)) #28 SMP Thu Nov 20 00:31:38 PST 2003
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000ca000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001fef0000 (usable)
 BIOS-e820: 000000001fef0000 - 000000001fef6000 (ACPI data)
 BIOS-e820: 000000001fef6000 - 000000001ff00000 (ACPI NVS)
 BIOS-e820: 000000001ff00000 - 000000001ff80000 (usable)
 BIOS-e820: 000000001ff80000 - 0000000020000000 (reserved)
 BIOS-e820: 00000000fec00000 - 00000000fec04000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000fff80000 - 0000000100000000 (reserved)
511MB LOWMEM available.
found SMP MP-table at 000f7110
hm, page 000f7000 reserved twice.
hm, page 000f8000 reserved twice.
hm, page 0009f000 reserved twice.
hm, page 000a0000 reserved twice.
On node 0 totalpages: 130944
zone(0): 4096 pages.
zone(1): 126848 pages.
zone(2): 0 pages.
ACPI: RSDP (v000 PTLTD                                     ) @ 0x000f70a0
ACPI: RSDT (v001 PTLTD    RSDT   0x06040000  LTP 0x00000000) @ 0x1fef3f4a
ACPI: FADT (v001 AMD    TECATE   0x06040000 PTL  0x000f4240) @ 0x1fef5f2e
ACPI: MADT (v001 PTLTD  	 APIC   0x06040000  LTP 0x00000000) @ 0x1fef5fa2
ACPI: DSDT (v001    AMD  AMDACPI 0x06040000 MSFT 0x0100000d) @ 0x00000000
ACPI: Local APIC address 0xfee00000
ACPI: LAPIC (acpi_id[0x00] lapic_id[0x01] enabled)
Processor #1 Pentium(tm) Pro APIC version 16
ACPI: LAPIC (acpi_id[0x01] lapic_id[0x00] enabled)
Processor #0 Pentium(tm) Pro APIC version 16
ACPI: LAPIC_NMI (acpi_id[0x00] polarity[0x1] trigger[0x1] lint[0x1])
ACPI: LAPIC_NMI (acpi_id[0x01] polarity[0x1] trigger[0x1] lint[0x1])
Using ACPI for processor (LAPIC) configuration information
Intel MultiProcessor Specification v1.4
    Virtual Wire compatibility mode.
OEM ID: TYAN     Product ID: PAULANER     APIC at: 0xFEE00000
I/O APIC #2 Version 17 at 0xFEC00000.
Enabling APIC mode: Flat.	Using 1 I/O APICs
Processors: 2
Kernel command line: ro root=/dev/hda2 console=ttyS0,38400 console=tty0
Initializing CPU#0
Detected 1666.731 MHz processor.
Console: colour VGA+ 80x25
Calibrating delay loop... 3329.22 BogoMIPS
Memory: 515108k/523776k available (1407k kernel code, 8216k reserved, 524k data, 152k init, 0k highmem)
Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
Inode cache hash table entries: 32768 (order: 6, 262144 bytes)
Mount cache hash table entries: 512 (order: 0, 4096 bytes)
Buffer cache hash table entries: 32768 (order: 5, 131072 bytes)
Page-cache hash table entries: 131072 (order: 7, 524288 bytes)
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 256K (64 bytes/line)
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU:     After generic, caps: 0383fbff c1cbfbff 00000000 00000000
CPU:             Common caps: 0383fbff c1cbfbff 00000000 00000000
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
POSIX conformance testing by UNIFIX
mtrr: v1.40 (20010327) Richard Gooch (rgooch@atnf.csiro.au)
mtrr: detected mtrr type: Intel
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 256K (64 bytes/line)
Intel machine check reporting enabled on CPU#0.
CPU:     After generic, caps: 0383fbff c1cbfbff 00000000 00000000
CPU:             Common caps: 0383fbff c1cbfbff 00000000 00000000
CPU0: AMD Athlon(tm) MP 2000+ stepping 02
per-CPU timeslice cutoff: 731.44 usecs.
masked ExtINT on CPU#0
ESR value before enabling vector: 00000000
ESR value after enabling vector: 00000000
Booting processor 1/0 eip 2000
Initializing CPU#1
masked ExtINT on CPU#1
ESR value before enabling vector: 00000000
ESR value after enabling vector: 00000000
Calibrating delay loop... 3329.22 BogoMIPS
CPU: L1 I Cache: 64K (64 bytes/line), D cache 64K (64 bytes/line)
CPU: L2 Cache: 256K (64 bytes/line)
Intel machine check reporting enabled on CPU#1.
CPU:     After generic, caps: 0383fbff c1cbfbff 00000000 00000000
CPU:             Common caps: 0383fbff c1cbfbff 00000000 00000000
CPU1: AMD Athlon(tm) Processor stepping 02
Total of 2 processors activated (6658.45 BogoMIPS).
ENABLING IO-APIC IRQs
Setting 2 in the phys_id_present_map
...changing IO-APIC physical APIC ID to 2 ... ok.
init IO_APIC IRQs
 IO-APIC (apicid-pin) 2-0, 2-5, 2-9, 2-10, 2-11, 2-20, 2-21, 2-22, 2-23 not connected.
..TIMER: vector=0x31 pin1=2 pin2=0
number of MP IRQ sources: 21.
number of IO-APIC #2 registers: 24.
testing the IO APIC.......................

IO APIC #2......
.... register #00: 02000000
.......    : physical APIC id: 02
.......    : Delivery Type: 0
.......    : LTS          : 0
.... register #01: 00170011
.......     : max redirection entries: 0017
.......     : PRQ implemented: 0
.......     : IO APIC version: 0011
.... register #02: 00000000
.......     : arbitration: 00
.... IRQ redirection table:
 NR Log Phy Mask Trig IRR Pol Stat Dest Deli Vect:   
 00 000 00  1    0    0   0   0    0    0    00
 01 003 03  0    0    0   0   0    1    1    39
 02 003 03  0    0    0   0   0    1    1    31
 03 003 03  0    0    0   0   0    1    1    41
 04 003 03  0    0    0   0   0    1    1    49
 05 000 00  1    0    0   0   0    0    0    00
 06 003 03  0    0    0   0   0    1    1    51
 07 003 03  0    0    0   0   0    1    1    59
 08 003 03  0    0    0   0   0    1    1    61
 09 000 00  1    0    0   0   0    0    0    00
 0a 000 00  1    0    0   0   0    0    0    00
 0b 000 00  1    0    0   0   0    0    0    00
 0c 003 03  0    0    0   0   0    1    1    69
 0d 003 03  0    0    0   0   0    1    1    71
 0e 003 03  0    0    0   0   0    1    1    79
 0f 003 03  0    0    0   0   0    1    1    81
 10 003 03  1    1    0   1   0    1    1    89
 11 003 03  1    1    0   1   0    1    1    91
 12 003 03  1    1    0   1   0    1    1    99
 13 003 03  1    1    0   1   0    1    1    A1
 14 000 00  1    0    0   0   0    0    0    00
 15 000 00  1    0    0   0   0    0    0    00
 16 000 00  1    0    0   0   0    0    0    00
 17 000 00  1    0    0   0   0    0    0    00
IRQ to pin mappings:
IRQ0 -> 0:2
IRQ1 -> 0:1
IRQ3 -> 0:3
IRQ4 -> 0:4
IRQ6 -> 0:6
IRQ7 -> 0:7
IRQ8 -> 0:8
IRQ12 -> 0:12
IRQ13 -> 0:13
IRQ14 -> 0:14
IRQ15 -> 0:15
IRQ16 -> 0:16
IRQ17 -> 0:17
IRQ18 -> 0:18
IRQ19 -> 0:19
.................................... done.
Using local APIC timer interrupts.
calibrating APIC timer ...
..... CPU clock speed is 1666.8222 MHz.
..... host bus clock speed is 266.6915 MHz.
cpu: 0, clocks: 2666915, slice: 888971
CPU0<T0:2666912,T1:1777936,D:5,S:888971,C:2666915>
cpu: 1, clocks: 2666915, slice: 888971
CPU1<T0:2666912,T1:888960,D:10,S:888971,C:2666915>
checking TSC synchronization across CPUs: passed.
Waiting on wait_init_idle (map = 0x2)
All processors have done init_idle
mtrr: your CPUs had inconsistent fixed MTRR settings
mtrr: probably your BIOS does not setup all CPUs
PCI: PCI BIOS revision 2.10 entry at 0xfd790, last bus=3
PCI: Using configuration type 1
PCI: Probing PCI hardware
PCI: Probing PCI hardware (bus 00)
PCI: Using IRQ router AMD768 [1022/7443] at 00:07.3
PCI->APIC IRQ transform: (B0,I8,P0) -> 16
PCI->APIC IRQ transform: (B0,I8,P1) -> 17
PCI->APIC IRQ transform: (B2,I0,P0) -> 17
PCI->APIC IRQ transform: (B2,I1,P0) -> 18
PCI->APIC IRQ transform: (B2,I2,P0) -> 16
PCI->APIC IRQ transform: (B2,I3,P0) -> 17
PCI->APIC IRQ transform: (B3,I0,P3) -> 19
PCI->APIC IRQ transform: (B3,I8,P0) -> 18
PCI->APIC IRQ transform: (B3,I9,P0) -> 19
BIOS failed to enable PCI standards compliance, fixing this error.
isapnp: Scanning for PnP cards...
isapnp: No Plug & Play device found
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
apm: BIOS version 1.2 Flags 0x03 (Driver version 1.16)
apm: disabled - APM is not SMP safe.
Starting kswapd
VFS: Disk quotas vdquot_6.5.1
pty: 512 Unix98 ptys configured
Serial driver version 5.05c (2001-07-08) with MANY_PORTS MULTIPORT SHARE_IRQ SERIAL_PCI ISAPNP enabled
ttyS00 at 0x03f8 (irq = 4) is a 16550A
ttyS01 at 0x02f8 (irq = 3) is a 16550A
Real Time Clock Driver v1.10e
Floppy drive(s): fd0 is 1.44M
FDC 0 is a post-1991 82077
NET4: Frame Diverter 0.46
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
Uniform Multi-Platform E-IDE driver Revision: 7.00beta4-2.4
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
AMD7441: IDE controller at PCI slot 00:07.1
AMD7441: chipset revision 4
AMD7441: not 100% native mode: will probe irqs later
ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
AMD_IDE: Advanced Micro Devices [AMD] AMD-768 [Opus] IDE (rev 04) UDMA100 controller on pci00:07.1
    ide0: BM-DMA at 0xf000-0xf007, BIOS settings: hda:DMA, hdb:pio
    ide1: BM-DMA at 0xf008-0xf00f, BIOS settings: hdc:DMA, hdd:pio
hda: WDC WD200BB-75CAA0, ATA DISK drive
blk: queue c03449a0, I/O limit 4095Mb (mask 0xffffffff)
hdc: SAMSUNG CD-ROM SC-152L, ATAPI CD/DVD-ROM drive
ide0 at 0x1f0-0x1f7,0x3f6 on irq 14
ide1 at 0x170-0x177,0x376 on irq 15
hda: attached ide-disk driver.
hda: host protected area => 1
hda: 39062500 sectors (20000 MB) w/2048KiB Cache, CHS=2431/255/63, UDMA(100)
Partition check:
 hda: hda1 hda2 hda3
ide: late registration of driver.
md: md driver 0.90.0 MAX_MD_DEVS=256, MD_SB_DISKS=27
md: Autodetecting RAID arrays.
md: autorun ...
md: ... autorun DONE.
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP, IGMP
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP: Hash tables configured (established 32768 bind 32768)
Linux IP multicast router 0.06 plus PIM-SM
NET4: Unix domain sockets 1.0/SMP for Linux NET4.0.
RAMDISK: Compressed image found at block 0
Freeing initrd memory: 146k freed
VFS: Mounted root (ext2 filesystem).
Journalled Block Device driver loaded
kjournald starting.  Commit interval 5 seconds
EXT3-fs: mounted filesystem with ordered data mode.
Freeing unused kernel memory: 152k freed
usb.c: registered new driver usbdevfs
usb.c: registered new driver hub
usb-ohci.c: USB OHCI at membase 0xe084d000, IRQ 19
usb-ohci.c: usb-03:00.0, Advanced Micro Devices [AMD] AMD-768 [Opus] USB
usb.c: new USB bus registered, assigned bus number 1
hub.c: USB hub found
hub.c: 4 ports detected
usb.c: registered new driver hiddev
usb.c: registered new driver hid
hid-core.c: v1.8.1 Andreas Gal, Vojtech Pavlik <vojtech@suse.cz>
hid-core.c: USB HID support drivers
mice: PS/2 mouse device common for all mice
EXT3 FS 2.4-0.9.19, 19 August 2002 on ide0(3,2), internal journal
Adding Swap: 1048312k swap-space (priority -1)
kjournald starting.  Commit interval 5 seconds
EXT3 FS 2.4-0.9.19, 19 August 2002 on ide0(3,1), internal journal
EXT3-fs: mounted filesystem with ordered data mode.
parport0: PC-style at 0x378 (0x778) [PCSPP,TRISTATE,EPP]
parport0: irq 7 detected
ip_tables: (C) 2000-2002 Netfilter core team
3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
See Documentation/networking/vortex.txt
03:08.0: 3Com PCI 3c980C Python-T at 0x3400. Vers LK1.1.18-ac
 00:e0:81:21:7d:c8, IRQ 18
  product code 0000 rev 00.6 date 00-00-00
  Internal config register is 1800000, transceivers 0xa.
  8K byte-wide RAM 5:3 Rx:Tx split, autoselect/Autonegotiate interface.
  MII transceiver found at address 24, status 782d.
  Enabling bus-master transmits and whole-frame receives.
03:08.0: scatter/gather enabled. h/w checksums enabled
divert: allocating divert_blk for eth0
See Documentation/networking/vortex.txt
03:09.0: 3Com PCI 3c980C Python-T at 0x3480. Vers LK1.1.18-ac
 00:e0:81:21:7d:c9, IRQ 19
  product code 0000 rev 00.6 date 00-00-00
  Internal config register is 1800000, transceivers 0xa.
  8K byte-wide RAM 5:3 Rx:Tx split, autoselect/Autonegotiate interface.
  MII transceiver found at address 24, status 7809.
  Enabling bus-master transmits and whole-frame receives.
03:09.0: scatter/gather enabled. h/w checksums enabled
divert: allocating divert_blk for eth1
ip_tables: (C) 2000-2002 Netfilter core team
parport0: PC-style at 0x378 (0x778) [PCSPP,TRISTATE,EPP]
parport0: irq 7 detected
lp0: using parport0 (polling).
lp0: console ready
pktgen.c: v1.7: Packet Generator for packet performance testing.
pktgen: cycles_calibrate, cycles_per_ns: 1  per_us: 1666  per_ms: 1666000
Intel(R) PRO/1000 Network Driver - version 5.2.16-k2
Copyright (c) 1999-2003 Intel Corporation.
divert: allocating divert_blk for eth2
eth2: Intel(R) PRO/1000 Network Connection
Transmit Descriptors set to 1024
Receive Descriptors set to 4096
divert: allocating divert_blk for eth3
eth3: Intel(R) PRO/1000 Network Connection
Transmit Descriptors set to 1024
Receive Descriptors set to 4096
Intel(R) PRO/100 Network Driver - version 2.3.18-k1
Copyright (c) 2003 Intel Corporation

divert: allocating divert_blk for eth4
e100: selftest OK.
e1000: eth2 NIC Link is Up 100 Mbps Full Duplex
e100: eth4: Intel(R) PRO/100 Network Connection
  Hardware receive checksums enabled

divert: allocating divert_blk for eth5
e100: selftest OK.
e100: eth5: Intel(R) PRO/100 Network Connection
  Hardware receive checksums enabled

divert: allocating divert_blk for eth6
e100: selftest OK.
e100: eth6: Intel(R) PRO/100 Network Connection
  Hardware receive checksums enabled

divert: allocating divert_blk for eth7
e100: selftest OK.
e100: eth7: Intel(R) PRO/100 Network Connection
  Hardware receive checksums enabled

MAC address based VLAN support Revision: 1.3
e1000: eth2 NIC Link is Up 100 Mbps Full Duplex
e1000: eth2 NIC Link is Up 100 Mbps Full Duplex
e1000: eth2 NIC Link is Up 100 Mbps Full Duplex

--------------090505070403080406040904--
