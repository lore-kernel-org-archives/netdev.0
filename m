From: Arkadiusz Miskiewicz <misiek@pld.ORG.PL>
Subject: Re: 2.4.21+O(1) scheduler and eepro100 driver
Date: Thu, 21 Aug 2003 21:53:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308212153.23487.misiek@pld.ORG.PL>
References: <200308210255.50357.misiek@pld.ORG.PL>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <200308210255.50357.misiek@pld.ORG.PL>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> I'm having problems with my 2.4.21 SMP kernel patched to use O(1). It
> sometimes segfault somewhere in networking code.

And more:

Unable to handle kernel NULL pointer dereference at virtual address 00000=
000
00f8989b
*pde =3D 069eb067
Oops: 0002
CPU:    1
EIP:    0010:[<00f8989b>]    Not tainted
EFLAGS: 00010246
eax: 00000000   ebx: 8e0a0ccc   ecx: 00000000   edx: 000005a8
esi: ea000030   edi: 78c0d089   ebp: e0988986   esp: db905e64
ds: 0018   es: 0018   ss: 0018
Process httpd (pid: 17881, stackpage=3Ddb905000)
Stack: c2e02089 10371983 99501823 c021770b 00000000 000005a8 c2026910 c66=
2c7a0
       c01d7114 01cddbb6 c2026910 000005a8 00000000 db905f08 00000000 cf5=
db060
       db905f80 db905f48 da2bc484 df212920 df212920 c78cc2e0 cf5db19c cf5=
db098
Call Trace:    [<c021770b>] [<c01d7114>] [<c01cea8a>] [<c01f4226>]=20
[<c01b1568>]
  [<c01b1784>] [<c013d3c6>] [<c01089b3>]
Code:  Bad EIP value.


>>EIP; 00f8989b Before first symbol   <=3D=3D=3D=3D=3D

>>ebp; e0988986 <[unix].bss.end+5c903/100f7d>
>>esp; db905e64 <___strtok+1b5af1fc/204a9398>

Trace; c021770b <csum_partial_copy_generic+6b/a0>
Trace; c01d7114 <tcp_sendmsg+474/155c>
Trace; c01cea8a <inet_del_protocol+426/430>
Trace; c01f4226 <inet_sendmsg+3a/40>
Trace; c01b1568 <sock_sendmsg+6c/8c>
Trace; c01b1784 <sock_recvmsg+1fc/7e4>
Trace; c013d3c6 <default_llseek+40e/c10>
Trace; c01089b3 <__read_lock_failed+10d7/148c>


 <1>Unable to handle kernel NULL pointer dereference at virtual address=20
00000000
00f8989b
*pde =3D 17a10067
Oops: 0002
CPU:    0
EIP:    0010:[<00f8989b>]    Not tainted
EFLAGS: 00010246
eax: 00000000   ebx: 8e0a0ccc   ecx: 00000000   edx: 000005b4
esi: ea000030   edi: 78c0d089   ebp: e0988986   esp: d24d5e64
ds: 0018   es: 0018   ss: 0018
Process httpd (pid: 18026, stackpage=3Dd24d5000)
Stack: c2e02089 10371983 99501823 c021770b 00000000 000005b4 d53c5910 dc8=
d6160
       c01d7114 01d94ab3 d53c5910 000005b4 00000000 d24d5f08 00000000 c32=
d1560
       d24d5f80 d24d5f48 c8bb95a4 dfc56380 dfc61e10 41c66200 c32d169c c32=
d1598
Call Trace:    [<c021770b>] [<c01d7114>] [<c01f4226>] [<c01b1568>]=20
[<c01b1784>]
  [<c013d3c6>] [<c01089b3>]
Code:  Bad EIP value.


>>EIP; 00f8989b Before first symbol   <=3D=3D=3D=3D=3D

>>ebp; e0988986 <[unix].bss.end+5c903/100f7d>
>>esp; d24d5e64 <___strtok+1217f1fc/204a9398>

Trace; c021770b <csum_partial_copy_generic+6b/a0>
Trace; c01d7114 <tcp_sendmsg+474/155c>
Trace; c01f4226 <inet_sendmsg+3a/40>
Trace; c01b1568 <sock_sendmsg+6c/8c>
Trace; c01b1784 <sock_recvmsg+1fc/7e4>
Trace; c013d3c6 <default_llseek+40e/c10>
Trace; c01089b3 <__read_lock_failed+10d7/148c>


Unable to handle kernel paging request at virtual address ba3716b7
ba3716b7
*pde =3D 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<ba3716b7>]    Not tainted
EFLAGS: 00010246
eax: 00000000   ebx: 19a19088   ecx: 00000000   edx: 00000200
esi: 37399c21   edi: 7c7a3714   ebp: f0183718   esp: dc277e64
ds: 0018   es: 0018   ss: 0018
Process httpd (pid: 17539, stackpage=3Ddc277000)
Stack: 83d73a93 f97674bd 49df1a39 c021770b 00000000 00000200 c8a79910 d1d=
2fa40
       c01d7114 01cc7f3e c8a79910 00000200 00000000 dc277f08 00000000 d61=
9baa0
       dc277f80 dc277f48 d3d1d8c4 c02b9118 dc276000 00000004 d619bbdc d61=
9bad8
Call Trace:    [<c021770b>] [<c01d7114>] [<c01f4226>] [<c01b1568>]=20
[<c01b1784>]
  [<c013d3c6>] [<c01089b3>]
Code:  Bad EIP value.


>>EIP; ba3716b7 Before first symbol   <=3D=3D=3D=3D=3D

>>esp; dc277e64 <___strtok+1bf211fc/204a9398>

Trace; c021770b <csum_partial_copy_generic+6b/a0>
Trace; c01d7114 <tcp_sendmsg+474/155c>
Trace; c01f4226 <inet_sendmsg+3a/40>
Trace; c01b1568 <sock_sendmsg+6c/8c>
Trace; c01b1784 <sock_recvmsg+1fc/7e4>
Trace; c013d3c6 <default_llseek+40e/c10>
Trace; c01089b3 <__read_lock_failed+10d7/148c>



 <1>Unable to handle kernel paging request at virtual address 20202020
20202020
*pde =3D 00000000
Oops: 0000
CPU:    0
EIP:    0010:[<20202020>]    Not tainted
EFLAGS: 00010246
eax: 00000000   ebx: 200a0d29   ecx: 00000000   edx: 000005a8
esi: 74417261   edi: 736f7028   ebp: 68632e65   esp: cf58be64
ds: 0018   es: 0018   ss: 0018
Process httpd (pid: 17583, stackpage=3Dcf58b000)
Stack: 61747320 20737574 7874203d c021770b 00000000 000005a8 c6231910 d98=
86900
       c01d7114 02273e70 c6231910 000005a8 00000000 cf58bf08 00000000 d2d=
e2a80
       cf58bf80 cf58bf48 cdf5caa4 0000002b deafac20 00000070 d2de2bbc d2d=
e2ab8
Call Trace:    [<c021770b>] [<c01d7114>] [<c01f4226>] [<c01b1568>]=20
[<c01b1784>]
  [<c013d3c6>] [<c01089b3>]
Code:  Bad EIP value.


>>EIP; 20202020 Before first symbol   <=3D=3D=3D=3D=3D

>>esp; cf58be64 <___strtok+f2351fc/204a9398>

Trace; c021770b <csum_partial_copy_generic+6b/a0>
Trace; c01d7114 <tcp_sendmsg+474/155c>
Trace; c01f4226 <inet_sendmsg+3a/40>
Trace; c01b1568 <sock_sendmsg+6c/8c>
Trace; c01b1784 <sock_recvmsg+1fc/7e4>
Trace; c013d3c6 <default_llseek+40e/c10>
Trace; c01089b3 <__read_lock_failed+10d7/148c>



Unable to handle kernel NULL pointer dereference at virtual address 00000=
000
09050688
*pde =3D 09ea5067
Oops: 0002
CPU:    1
EIP:    0010:[<09050688>]    Not tainted
EFLAGS: 00010246
eax: 00000000   ebx: 06882036   ecx: 00000000   edx: 000005b4
esi: 0b050688   edi: 68bf1c00   ebp: 203678b5   esp: dccf3e64
ds: 0018   es: 0018   ss: 0018
Process httpd (pid: 14769, stackpage=3Ddccf3000)
Stack: 98aa1c00 06882036 1c000a05 c021770b 00000000 000005b4 c3700910 dd3=
07c80
       c01d7114 49d6cc5f c3700910 000005b4 00000000 dccf3f08 00000000 d35=
95060
       dccf3f80 dccf3f48 cd0aeee4 dfc32818 00000000 dfcb6600 d359519c d35=
95098
Call Trace:    [<c021770b>] [<c01d7114>] [<e0807f6f>] [<c01f4226>]=20
[<c01b1568>]
  [<c01b1784>] [<c013d3c6>] [<c01089b3>]
Code:  Bad EIP value.


>>EIP; 09050688 Before first symbol   <=3D=3D=3D=3D=3D

>>esp; dccf3e64 <___strtok+1c99d1fc/204a9398>

Trace; c021770b <csum_partial_copy_generic+6b/a0>
Trace; c01d7114 <tcp_sendmsg+474/155c>
Trace; e0807f6f <[scsi_mod]scsi_io_completion+1e7/3ec>
Trace; c01f4226 <inet_sendmsg+3a/40>
Trace; c01b1568 <sock_sendmsg+6c/8c>
Trace; c01b1784 <sock_recvmsg+1fc/7e4>
Trace; c013d3c6 <default_llseek+40e/c10>
Trace; c01089b3 <__read_lock_failed+10d7/148c>


Unable to handle kernel paging request at virtual address 20202020
20202020
*pde =3D 00000000
Oops: 0000
CPU:    1
EIP:    0010:[<20202020>]    Not tainted
EFLAGS: 00010246
eax: 00000000   ebx: 20202020   ecx: 00000000   edx: 000005b4
esi: 2f3c3b70   edi: 0a0d3e70   ebp: 73626e26   esp: d002be64
ds: 0018   es: 0018   ss: 0018
Process httpd (pid: 7744, stackpage=3Dd002b000)
Stack: 703c2020 6d693c3e 72732067 c021770b 00000000 000005b4 dcb77910 d22=
aa3c0
       c01d7114 01bb5b81 dcb77910 000005b4 00000000 d002bf08 00000000 ddd=
26040
       d002bf80 d002bf48 d6a665e4 c02b9ad8 d002a000 d6a664c0 ddd2617c ddd=
26078
Call Trace:    [<c021770b>] [<c01d7114>] [<c01f4226>] [<c01b1568>]=20
[<c01b1784>]
  [<c013d3c6>] [<c01089b3>]
Code:  Bad EIP value.


>>EIP; 20202020 Before first symbol   <=3D=3D=3D=3D=3D

>>esp; d002be64 <___strtok+fcd51fc/204a9398>

Trace; c021770b <csum_partial_copy_generic+6b/a0>
Trace; c01d7114 <tcp_sendmsg+474/155c>
Trace; c01f4226 <inet_sendmsg+3a/40>
Trace; c01b1568 <sock_sendmsg+6c/8c>
Trace; c01b1784 <sock_recvmsg+1fc/7e4>
Trace; c013d3c6 <default_llseek+40e/c10>
Trace; c01089b3 <__read_lock_failed+10d7/148c>


dmesg:
Linux version 2.4.21 (builder@ep09) (gcc version 2.95.4 20010319 (prerele=
ase))=20
#1 SMP Wed Aug 13 06:27:47 UTC 2003
BIOS-provided physical RAM map:
 BIOS-e820: 0000000000000000 - 000000000009f800 (usable)
 BIOS-e820: 000000000009f800 - 00000000000a0000 (reserved)
 BIOS-e820: 00000000000e0000 - 0000000000100000 (reserved)
 BIOS-e820: 0000000000100000 - 000000001ffd0000 (usable)
 BIOS-e820: 000000001ffd0000 - 000000001ffff000 (ACPI data)
 BIOS-e820: 000000001ffff000 - 0000000020000000 (ACPI NVS)
 BIOS-e820: 00000000fec00000 - 00000000fec02000 (reserved)
 BIOS-e820: 00000000fee00000 - 00000000fee01000 (reserved)
 BIOS-e820: 00000000fff00000 - 0000000100000000 (reserved)
0MB HIGHMEM available.
511MB LOWMEM available.
found SMP MP-table at 000ff780
hm, page 000ff000 reserved twice.
hm, page 00100000 reserved twice.
hm, page 000f1000 reserved twice.
hm, page 000f2000 reserved twice.
On node 0 totalpages: 131024
zone(0): 4096 pages.
zone(1): 126928 pages.
zone(2): 0 pages.
Intel MultiProcessor Specification v1.4
    Virtual Wire compatibility mode.
OEM ID: INTEL    Product ID: CNB30LE      APIC at: 0xFEE00000
Processor #0 Pentium(tm) Pro APIC version 17
Processor #1 Pentium(tm) Pro APIC version 17
I/O APIC #4 Version 17 at 0xFEC00000.
I/O APIC #5 Version 17 at 0xFEC01000.
Enabling APIC mode: Flat.       Using 2 I/O APICs
Processors: 2
Kernel command line: BOOT_IMAGE=3Dpld-2.4.21-1.6s ro root=3D803 console=3D=
tty0=20
console=3DttyS0,9600n81
Initializing CPU#0
Detected 931.030 MHz processor.
Console: colour VGA+ 80x25
Calibrating delay loop... 1854.66 BogoMIPS
Memory: 514856k/524096k available (1133k kernel code, 8852k reserved, 479=
k=20
data, 116k init, 0k highmem)
Dentry cache hash table entries: 65536 (order: 7, 524288 bytes)
Inode cache hash table entries: 32768 (order: 6, 262144 bytes)
Mount cache hash table entries: 512 (order: 0, 4096 bytes)
Buffer-cache hash table entries: 32768 (order: 5, 131072 bytes)
Page-cache hash table entries: 131072 (order: 7, 524288 bytes)
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 256K
CPU serial number disabled.
Intel machine check architecture supported.
Intel machine check reporting enabled on CPU#0.
CPU:     After generic, caps: 0383fbff 00000000 00000000 00000000
CPU:             Common caps: 0383fbff 00000000 00000000 00000000
Enabling fast FPU save and restore... done.
Enabling unmasked SIMD FPU exception support... done.
Checking 'hlt' instruction... OK.
POSIX conformance testing by UNIFIX
mtrr: v1.40 (20010327) Richard Gooch (rgooch@atnf.csiro.au)
mtrr: detected mtrr type: Intel
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 256K
Intel machine check reporting enabled on CPU#0.
CPU:     After generic, caps: 0383fbff 00000000 00000000 00000000
CPU:             Common caps: 0383fbff 00000000 00000000 00000000
CPU0: Intel Pentium III (Coppermine) stepping 06
per-CPU timeslice cutoff: 731.28 usecs.
task migration cache decay timeout: 10 msecs.
enabled ExtINT on CPU#0
ESR value before enabling vector: 00000004
ESR value after enabling vector: 00000000
Booting processor 1/1 eip 2000
Initializing CPU#1
masked ExtINT on CPU#1
ESR value before enabling vector: 00000000
ESR value after enabling vector: 00000000
Calibrating delay loop... 1861.22 BogoMIPS
CPU: L1 I cache: 16K, L1 D cache: 16K
CPU: L2 cache: 256K
CPU serial number disabled.
Intel machine check reporting enabled on CPU#1.
CPU:     After generic, caps: 0383fbff 00000000 00000000 00000000
CPU:             Common caps: 0383fbff 00000000 00000000 00000000
CPU1: Intel Pentium III (Coppermine) stepping 06
Total of 2 processors activated (3715.89 BogoMIPS).
ENABLING IO-APIC IRQs
Setting 4 in the phys_id_present_map
...changing IO-APIC physical APIC ID to 4 ... ok.
Setting 5 in the phys_id_present_map
...changing IO-APIC physical APIC ID to 5 ... ok.
init IO_APIC IRQs
 IO-APIC (apicid-pin) 4-0, 4-3, 4-5, 4-9, 4-11, 5-2, 5-3, 5-4, 5-5, 5-6, =
5-10,=20
5-11, 5-12, 5-13, 5-14, 5-15 not connected.
..TIMER: vector=3D0x31 pin1=3D2 pin2=3D0
..MP-BIOS bug: 8254 timer not connected to IO-APIC
...trying to set up timer (IRQ0) through the 8259A ...
..... (found pin 0) ...works.
number of MP IRQ sources: 17.
number of IO-APIC #4 registers: 16.
number of IO-APIC #5 registers: 16.
testing the IO APIC.......................

IO APIC #4......
.... register #00: 04000000
.......    : physical APIC id: 04
.......    : Delivery Type: 0
.......    : LTS          : 0
.... register #01: 000F0011
.......     : max redirection entries: 000F
.......     : PRQ implemented: 0
.......     : IO APIC version: 0011
.... register #02: 00000000
.......     : arbitration: 00
.... IRQ redirection table:
 NR Log Phy Mask Trig IRR Pol Stat Dest Deli Vect:
 00 003 03  0    0    0   0   0    1    1    31
 01 003 03  0    0    0   0   0    1    1    39
 02 000 00  1    0    0   0   0    0    0    00
 03 000 00  1    0    0   0   0    0    0    00
 04 003 03  0    0    0   0   0    1    1    41
 05 000 00  1    0    0   0   0    0    0    00
 06 003 03  0    0    0   0   0    1    1    49
 07 003 03  0    0    0   0   0    1    1    51
 08 003 03  0    0    0   0   0    1    1    59
 09 000 00  1    0    0   0   0    0    0    00
 0a 003 03  1    1    0   1   0    1    1    61
 0b 000 00  1    0    0   0   0    0    0    00
 0c 003 03  0    0    0   0   0    1    1    69
 0d 003 03  0    0    0   0   0    1    1    71
 0e 003 03  0    0    0   0   0    1    1    79
 0f 003 03  0    0    0   0   0    1    1    81

IO APIC #5......
.... register #00: 05000000
.......    : physical APIC id: 05
.......    : Delivery Type: 0
.......    : LTS          : 0
.... register #01: 000F0011
.......     : max redirection entries: 000F
.......     : PRQ implemented: 0
.......     : IO APIC version: 0011
.... register #02: 06000000
.......     : arbitration: 06
.... IRQ redirection table:
NR Log Phy Mask Trig IRR Pol Stat Dest Deli Vect:
 00 003 03  1    1    0   1   0    1    1    89
 01 003 03  1    1    0   1   0    1    1    91
 02 000 00  1    0    0   0   0    0    0    00
 03 000 00  1    0    0   0   0    0    0    00
 04 000 00  1    0    0   0   0    0    0    00
 05 000 00  1    0    0   0   0    0    0    00
 06 000 00  1    0    0   0   0    0    0    00
 07 003 03  1    1    0   1   0    1    1    99
 08 003 03  1    1    0   1   0    1    1    A1
 09 003 03  1    1    0   1   0    1    1    A9
 0a 000 00  1    0    0   0   0    0    0    00
 0b 000 00  1    0    0   0   0    0    0    00
 0c 000 00  1    0    0   0   0    0    0    00
 0d 000 00  1    0    0   0   0    0    0    00
 0e 000 00  1    0    0   0   0    0    0    00
 0f 000 00  1    0    0   0   0    0    0    00
IRQ to pin mappings:
IRQ0 -> 0:0
IRQ1 -> 0:1
IRQ4 -> 0:4
IRQ6 -> 0:6
IRQ7 -> 0:7
IRQ8 -> 0:8
IRQ10 -> 0:10
IRQ12 -> 0:12
IRQ13 -> 0:13
IRQ14 -> 0:14
IRQ15 -> 0:15
IRQ16 -> 1:0
IRQ17 -> 1:1
IRQ23 -> 1:7
IRQ24 -> 1:8
IRQ25 -> 1:9
.................................... done.
Using local APIC timer interrupts.
calibrating APIC timer ...
..... CPU clock speed is 931.0161 MHz.
..... host bus clock speed is 133.0022 MHz.
cpu: 0, clocks: 1330022, slice: 443340
CPU0<T0:1330016,T1:886672,D:4,S:443340,C:1330022>
cpu: 1, clocks: 1330022, slice: 443340
CPU1<T0:1330016,T1:443328,D:8,S:443340,C:1330022>
checking TSC synchronization across CPUs: passed.
migration_task 0 on cpu=3D0
migration_task 1 on cpu=3D1
PCI: PCI BIOS revision 2.10 entry at 0xfda65, last bus=3D1
PCI: Using configuration type 1
PCI: Probing PCI hardware
PCI: Discovered primary peer bus 01 [IRQ]
PCI->APIC IRQ transform: (B0,I4,P0) -> 23
PCI->APIC IRQ transform: (B0,I7,P0) -> 17
PCI->APIC IRQ transform: (B0,I8,P0) -> 16
PCI->APIC IRQ transform: (B0,I15,P0) -> 10
PCI->APIC IRQ transform: (B1,I4,P0) -> 24
PCI->APIC IRQ transform: (B1,I4,P1) -> 25
Linux NET4.0 for Linux 2.4
Based upon Swansea University Computer Society NET3.039
Initializing RT netlink socket
Starting kswapd
kinoded started
VFS: Disk quotas vdquot_6.5.1
devfs: v1.12c (20020818) Richard Gooch (rgooch@atnf.csiro.au)
devfs: boot_options: 0x0
    ACPI-0107: *** Error: Acpi_load_tables: Could not load namespace:=20
AE_NOT_FOUND
    ACPI-0116: *** Error: Acpi_load_tables: Could not load tables:=20
AE_NOT_FOUND
ACPI: System description table load failed
Detected PS/2 Mouse Port.
pty: 512 Unix98 ptys configured
keyboard: Timeout - AT keyboard not present?(ed)
keyboard: Timeout - AT keyboard not present?(f4)
Serial driver version 5.05c (2001-07-08) with MANY_PORTS SHARE_IRQ SERIAL=
_PCI=20
enabled
ttyS00 at 0x03f8 (irq =3D 4) is a 16550A
NET4: Frame Diverter 0.46
RAMDISK driver initialized: 16 RAM disks of 4096K size 1024 blocksize
IEEE 802.2 LLC for Linux 2.1 (c) 1996 Tim Alpaerts
NET4: Linux TCP/IP 1.0 for NET4.0
IP Protocols: ICMP, UDP, TCP, IGMP
IP: routing cache hash table of 4096 buckets, 32Kbytes
TCP: Hash tables configured (established 32768 bind 32768)
Linux IP multicast router 0.06 plus PIM-SM
Measuring network checksumming speed
   basic     :   441.600 MB/sec
   simple    :   217.600 MB/sec
func 3Dnow! skipped: not supported by CPU
func AMD MMX skipped: not supported by CPU
   SSE1+     :  1056.000 MB/sec
csum: using csum function: SSE1+
   basic     :   140.800 MB/sec
   simple    :   128.000 MB/sec
func AND MMX skipped: not supported by CPU
   SSE1+     :   332.800 MB/sec
   SSE1      :   339.200 MB/sec
csum: using csum_copy function: SSE1
RAMDISK: Compressed image found at block 0
Freeing initrd memory: 248k freed
VFS: Mounted root (romfs filesystem) readonly.
SCSI subsystem driver Revision: 1.00
scsi0 : Adaptec AIC7XXX EISA/VLB/PCI SCSI HBA DRIVER, Rev 6.2.36
        <Adaptec aic7899 Ultra160 SCSI adapter>
        aic7899: Ultra160 Wide Channel A, SCSI Id=3D11, 32/253 SCBs

scsi1 : Adaptec AIC7XXX EISA/VLB/PCI SCSI HBA DRIVER, Rev 6.2.36
        <Adaptec aic7899 Ultra160 SCSI adapter>
        aic7899: Ultra160 Wide Channel B, SCSI Id=3D12, 32/253 SCBs

blk: queue dfc39e18, I/O limit 4095Mb (mask 0xffffffff)
(scsi1:A:0): 160.000MB/s transfers (80.000MHz DT, offset 63, 16bit)
(scsi1:A:1): 160.000MB/s transfers (80.000MHz DT, offset 63, 16bit)
  Vendor: IBM       Model: DDYS-T36950M      Rev: S9YB
  Type:   Direct-Access                      ANSI SCSI revision: 03
blk: queue dfc32818, I/O limit 4095Mb (mask 0xffffffff)
  Vendor: SEAGATE   Model: ST336732LC        Rev: 0022
  Type:   Direct-Access                      ANSI SCSI revision: 03
blk: queue dfc32418, I/O limit 4095Mb (mask 0xffffffff)
  Vendor: ESG-SHV   Model: SCA HSBP M14      Rev: 0.01
  Type:   Processor                          ANSI SCSI revision: 02
blk: queue dfc2b218, I/O limit 4095Mb (mask 0xffffffff)
scsi1:A:0:0: Tagged Queuing enabled.  Depth 253
scsi1:A:1:0: Tagged Queuing enabled.  Depth 253
Attached scsi disk sda at scsi1, channel 0, id 0, lun 0
Attached scsi disk sdb at scsi1, channel 0, id 1, lun 0
SCSI device sda: 71687340 512-byte hdwr sectors (36704 MB)
Partition check:
 /dev/scsi/host1/bus0/target0/lun0: p1 p2 p3 p4 < p5 p6 p7 p8 p9 >
SCSI device sdb: 71687369 512-byte hdwr sectors (36704 MB)
 /dev/scsi/host1/bus0/target1/lun0: p1
reiserfs: found format "3.5" with standard journal
reiserfs: using ordered data mode
reiserfs: checking transaction log (device sd(8,3)) ...
for (sd(8,3))
Using r5 hash to sort names
VFS: Mounted root (reiserfs filesystem) readonly.
Trying to move old root to /initrd ... okay
Freeing unused kernel memory: 116k freed


--=20
Arkadiusz Mi=B6kiewicz    CS at FoE, Wroclaw University of Technology
arekm.pld-linux.org AM2-6BONE, 1024/3DB19BBD, arekm(at)ircnet, PLD/Linux
