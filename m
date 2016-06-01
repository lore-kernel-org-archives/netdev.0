From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: ath9k gpio request
Date: Wed, 01 Jun 2016 17:48:31 +0530
Message-ID: <574ED297.4080004@gmail.com>
References: <20160530132225.4d297678@canb.auug.org.au>	<574C4851.9090201@gmail.com> <87fusy3cqx.fsf_-_@kamboji.qca.qualcomm.com>,<574D3EAA.3060102@gmail.com> <1464764036580.70506@qti.qualcomm.com> <574EC331.1080901@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090008070508080508040606"
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	ath9k-devel <ath9k-devel@qualcomm.com>,
	"linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"ath9k-devel@lists.ath9k.org" <ath9k-devel@lists.ath9k.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Miaoqing Pan <miaoqing@codeaurora.org>
To: "Pan, Miaoqing" <miaoqing@qti.qualcomm.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <574EC331.1080901@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090008070508080508040606
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit

On Wednesday 01 June 2016 04:42 PM, Sudip Mukherjee wrote:
> On Wednesday 01 June 2016 12:24 PM, Pan, Miaoqing wrote:
>> which chip ?  And what's the GPIO number ?
>
> lspci -v reports:
> 09:00.0 Network controller: Qualcomm Atheros AR9462 Wireless Network
> Adapter (rev 01)
>      Subsystem: Foxconn International, Inc. Device e052
>      Flags: bus master, fast devsel, latency 0, IRQ 19
>      Memory at c0500000 (64-bit, non-prefetchable) [size=512K]
>      Expansion ROM at c0580000 [disabled] [size=64K]
>      Capabilities: [40] Power Management version 2
>      Capabilities: [50] MSI: Enable- Count=1/4 Maskable+ 64bit+
>      Capabilities: [70] Express Endpoint, MSI 00
>      Capabilities: [100] Advanced Error Reporting
>      Capabilities: [140] Virtual Channel
>      Capabilities: [160] Device Serial Number 00-00-00-00-00-00-00-00
>      Kernel driver in use: ath9k
>
> Any easy way to find out the gpio number or i can modify the module to
> find that out.

Its trying for GPIO 11 with label ath9k-rfkill.

The attached dmesg is with some modification as below.

diff --git a/drivers/net/wireless/ath/ath9k/hw.c 
b/drivers/net/wireless/ath/ath9k/hw.c
index 8b2895f9..23deea7 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -2729,14 +2729,16 @@ static void ath9k_hw_gpio_cfg_wmac(struct ath_hw 
*ah, u32 gpio, bool out,
  static void ath9k_hw_gpio_request(struct ath_hw *ah, u32 gpio, bool out,
                                   const char *label, u32 ah_signal_type)
  {
-       WARN_ON(gpio >= ah->caps.num_gpio_pins);
+//     WARN_ON(gpio >= ah->caps.num_gpio_pins);
+
+       pr_err("sudip: %d %s\n", gpio, label);

         if (BIT(gpio) & ah->caps.gpio_mask)
                 ath9k_hw_gpio_cfg_wmac(ah, gpio, out, ah_signal_type);
         else if (AR_SREV_SOC(ah))
                 ath9k_hw_gpio_cfg_soc(ah, gpio, out, label);
-       else
-               WARN_ON(1);
+//     else
+//             WARN_ON(1);
  }

Regards
Sudip

--------------090008070508080508040606
Content-Type: text/plain; charset=UTF-8;
 name="dm1.txt"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
 filename="dm1.txt"

Linux version 4.7.0-rc1-next-20160530+ (sudip@sudip-laptop) (gcc version =
4.8.4 (Ubuntu 4.8.4-2ubuntu1~14.04) ) #5 SMP Wed Jun 1 17:03:25 IST 2016
Command line: BOOT_IMAGE=3D/boot/vmlinuz-4.7.0-rc1-next-20160530+ root=3D=
UUID=3D9ccf6248-fccd-462b-b0a6-0a0b4469bc15 ro quiet splash vt.handoff=3D=
7
KERNEL supported cpus:
  Intel GenuineIntel
  AMD AuthenticAMD
  Centaur CentaurHauls
x86/fpu: xstate_offset[2]:  576, xstate_sizes[2]:  256
x86/fpu: Supporting XSAVE feature 0x001: 'x87 floating point registers'
x86/fpu: Supporting XSAVE feature 0x002: 'SSE registers'
x86/fpu: Supporting XSAVE feature 0x004: 'AVX registers'
x86/fpu: Enabled xstate features 0x7, context size is 832 bytes, using 's=
tandard' format.
x86/fpu: Using 'eager' FPU context switches.
e820: BIOS-provided physical RAM map:
BIOS-e820: [mem 0x0000000000000000-0x000000000009d7ff] usable
BIOS-e820: [mem 0x000000000009d800-0x000000000009ffff] reserved
BIOS-e820: [mem 0x00000000000e0000-0x00000000000fffff] reserved
BIOS-e820: [mem 0x0000000000100000-0x000000001fffffff] usable
BIOS-e820: [mem 0x0000000020000000-0x00000000201fffff] reserved
BIOS-e820: [mem 0x0000000020200000-0x0000000040003fff] usable
BIOS-e820: [mem 0x0000000040004000-0x0000000040004fff] reserved
BIOS-e820: [mem 0x0000000040005000-0x00000000a6abefff] usable
BIOS-e820: [mem 0x00000000a6abf000-0x00000000a6ebefff] reserved
BIOS-e820: [mem 0x00000000a6ebf000-0x00000000a6fbefff] ACPI NVS
BIOS-e820: [mem 0x00000000a6fbf000-0x00000000a6ffefff] ACPI data
BIOS-e820: [mem 0x00000000a6fff000-0x00000000a6ffffff] usable
BIOS-e820: [mem 0x00000000a7000000-0x00000000af9fffff] reserved
BIOS-e820: [mem 0x00000000e0000000-0x00000000efffffff] reserved
BIOS-e820: [mem 0x00000000feb00000-0x00000000feb03fff] reserved
BIOS-e820: [mem 0x00000000fec00000-0x00000000fec00fff] reserved
BIOS-e820: [mem 0x00000000fed10000-0x00000000fed19fff] reserved
BIOS-e820: [mem 0x00000000fed1c000-0x00000000fed1ffff] reserved
BIOS-e820: [mem 0x00000000fee00000-0x00000000fee00fff] reserved
BIOS-e820: [mem 0x00000000ffc00000-0x00000000ffffffff] reserved
BIOS-e820: [mem 0x0000000100000000-0x000000014f5fffff] usable
NX (Execute Disable) protection: active
SMBIOS 2.7 present.
DMI: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
e820: update [mem 0x00000000-0x00000fff] usable =3D=3D> reserved
e820: remove [mem 0x000a0000-0x000fffff] usable
e820: last_pfn =3D 0x14f600 max_arch_pfn =3D 0x400000000
MTRR default type: uncachable
MTRR fixed ranges enabled:
  00000-9FFFF write-back
  A0000-BFFFF uncachable
  C0000-E7FFF write-protect
  E8000-EFFFF write-combining
  F0000-FFFFF write-protect
MTRR variable ranges enabled:
  0 base 000000000 mask F80000000 write-back
  1 base 080000000 mask FC0000000 write-back
  2 base 0A7000000 mask FFF000000 uncachable
  3 base 0A8000000 mask FF8000000 uncachable
  4 base 0B0000000 mask FF0000000 uncachable
  5 base 0FFC00000 mask FFFC00000 write-protect
  6 base 100000000 mask FC0000000 write-back
  7 base 140000000 mask FF0000000 write-back
  8 base 14F600000 mask FFFE00000 uncachable
  9 base 14F800000 mask FFF800000 uncachable
x86/PAT: Configuration [0-7]: WB  WC  UC- UC  WB  WC  UC- WT =20
e820: last_pfn =3D 0xa7000 max_arch_pfn =3D 0x400000000
found SMP MP-table at [mem 0x000fe1b0-0x000fe1bf] mapped at [ffff8800000f=
e1b0]
Scanning 1 areas for low memory corruption
Base memory trampoline at [ffff880000097000] 97000 size 24576
BRK [0x0200a000, 0x0200afff] PGTABLE
BRK [0x0200b000, 0x0200bfff] PGTABLE
BRK [0x0200c000, 0x0200cfff] PGTABLE
BRK [0x0200d000, 0x0200dfff] PGTABLE
BRK [0x0200e000, 0x0200efff] PGTABLE
BRK [0x0200f000, 0x0200ffff] PGTABLE
RAMDISK: [mem 0x23154000-0x2d8a1fff]
ACPI: Early table checksum verification disabled
ACPI: RSDP 0x00000000000FE020 000024 (v02 ACRSYS)
ACPI: XSDT 0x00000000A6FFE210 00009C (v01 ACRSYS ACRPRDCT 00000001      0=
1000013)
ACPI: FACP 0x00000000A6FFB000 00010C (v05 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: DSDT 0x00000000A6FEC000 00B1A0 (v01 ACRSYS ACRPRDCT 00000000 1025 0=
0040000)
ACPI: FACS 0x00000000A6FBB000 000040
ACPI: UEFI 0x00000000A6FFD000 000236 (v01 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: ASF! 0x00000000A6FFC000 0000A5 (v32 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: HPET 0x00000000A6FFA000 000038 (v01 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: APIC 0x00000000A6FF9000 00008C (v03 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: MCFG 0x00000000A6FF8000 00003C (v01 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: SLIC 0x00000000A6FEB000 000176 (v01 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: WDAT 0x00000000A6FEA000 000224 (v01 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: SSDT 0x00000000A6FE8000 001068 (v01 ACRSYS ACRPRDCT 00001000 1025 0=
0040000)
ACPI: BOOT 0x00000000A6FE6000 000028 (v01 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: ASPT 0x00000000A6FE1000 000034 (v07 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: MSDM 0x00000000A6FE0000 000055 (v03 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: FPDT 0x00000000A6FDE000 000044 (v01 ACRSYS ACRPRDCT 00000001 1025 0=
0040000)
ACPI: SSDT 0x00000000A6FDD000 000968 (v01 ACRSYS ACRPRDCT 00003000 1025 0=
0040000)
ACPI: SSDT 0x00000000A6FDC000 000A92 (v01 ACRSYS ACRPRDCT 00003000 1025 0=
0040000)
ACPI: Local APIC address 0xfee00000
No NUMA configuration found
Faking a node at [mem 0x0000000000000000-0x000000014f5fffff]
NODE_DATA(0) allocated [mem 0x14f5f8000-0x14f5fbfff]
Zone ranges:
  DMA      [mem 0x0000000000001000-0x0000000000ffffff]
  DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
  Normal   [mem 0x0000000100000000-0x000000014f5fffff]
Movable zone start for each node
Early memory node ranges
  node   0: [mem 0x0000000000001000-0x000000000009cfff]
  node   0: [mem 0x0000000000100000-0x000000001fffffff]
  node   0: [mem 0x0000000020200000-0x0000000040003fff]
  node   0: [mem 0x0000000040005000-0x00000000a6abefff]
  node   0: [mem 0x00000000a6fff000-0x00000000a6ffffff]
  node   0: [mem 0x0000000100000000-0x000000014f5fffff]
Initmem setup node 0 [mem 0x0000000000001000-0x000000014f5fffff]
On node 0 totalpages: 1007195
  DMA zone: 64 pages used for memmap
  DMA zone: 21 pages reserved
  DMA zone: 3996 pages, LIFO batch:0
  DMA32 zone: 10595 pages used for memmap
  DMA32 zone: 678079 pages, LIFO batch:31
  Normal zone: 5080 pages used for memmap
  Normal zone: 325120 pages, LIFO batch:31
Reserving Intel graphics stolen memory at 0xa7a00000-0xaf9fffff
ACPI: PM-Timer IO Port: 0x408
ACPI: Local APIC address 0xfee00000
IOAPIC[0]: apic_id 0, version 32, address 0xfec00000, GSI 0-23
ACPI: INT_SRC_OVR (bus 0 bus_irq 0 global_irq 2 dfl dfl)
ACPI: INT_SRC_OVR (bus 0 bus_irq 9 global_irq 9 high level)
ACPI: IRQ0 used by override.
ACPI: IRQ9 used by override.
Using ACPI (MADT) for SMP configuration information
ACPI: HPET id: 0x8086a201 base: 0xfed00000
smpboot: Allowing 8 CPUs, 4 hotplug CPUs
PM: Registered nosave memory: [mem 0x00000000-0x00000fff]
PM: Registered nosave memory: [mem 0x0009d000-0x0009dfff]
PM: Registered nosave memory: [mem 0x0009e000-0x0009ffff]
PM: Registered nosave memory: [mem 0x000a0000-0x000dffff]
PM: Registered nosave memory: [mem 0x000e0000-0x000fffff]
PM: Registered nosave memory: [mem 0x20000000-0x201fffff]
PM: Registered nosave memory: [mem 0x40004000-0x40004fff]
PM: Registered nosave memory: [mem 0xa6abf000-0xa6ebefff]
PM: Registered nosave memory: [mem 0xa6ebf000-0xa6fbefff]
PM: Registered nosave memory: [mem 0xa6fbf000-0xa6ffefff]
PM: Registered nosave memory: [mem 0xa7000000-0xaf9fffff]
PM: Registered nosave memory: [mem 0xafa00000-0xdfffffff]
PM: Registered nosave memory: [mem 0xe0000000-0xefffffff]
PM: Registered nosave memory: [mem 0xf0000000-0xfeafffff]
PM: Registered nosave memory: [mem 0xfeb00000-0xfeb03fff]
PM: Registered nosave memory: [mem 0xfeb04000-0xfebfffff]
PM: Registered nosave memory: [mem 0xfec00000-0xfec00fff]
PM: Registered nosave memory: [mem 0xfec01000-0xfed0ffff]
PM: Registered nosave memory: [mem 0xfed10000-0xfed19fff]
PM: Registered nosave memory: [mem 0xfed1a000-0xfed1bfff]
PM: Registered nosave memory: [mem 0xfed1c000-0xfed1ffff]
PM: Registered nosave memory: [mem 0xfed20000-0xfedfffff]
PM: Registered nosave memory: [mem 0xfee00000-0xfee00fff]
PM: Registered nosave memory: [mem 0xfee01000-0xffbfffff]
PM: Registered nosave memory: [mem 0xffc00000-0xffffffff]
e820: [mem 0xafa00000-0xdfffffff] available for PCI devices
Booting paravirtualized kernel on bare hardware
clocksource: refined-jiffies: mask: 0xffffffff max_cycles: 0xffffffff, ma=
x_idle_ns: 7645519600211568 ns
setup_percpu: NR_CPUS:256 nr_cpumask_bits:256 nr_cpu_ids:8 nr_node_ids:1
percpu: Embedded 35 pages/cpu @ffff88014f200000 s102744 r8192 d32424 u262=
144
pcpu-alloc: s102744 r8192 d32424 u262144 alloc=3D1*2097152
pcpu-alloc: [0] 0 1 2 3 4 5 6 7=20
Built 1 zonelists in Node order, mobility grouping on.  Total pages: 9914=
35
Policy zone: Normal
Kernel command line: BOOT_IMAGE=3D/boot/vmlinuz-4.7.0-rc1-next-20160530+ =
root=3DUUID=3D9ccf6248-fccd-462b-b0a6-0a0b4469bc15 ro quiet splash vt.han=
doff=3D7
PID hash table entries: 4096 (order: 3, 32768 bytes)
Calgary: detecting Calgary via BIOS EBDA area
Calgary: Unable to locate Rio Grande table in EBDA - bailing!
Memory: 3709984K/4028780K available (8055K kernel code, 1274K rwdata, 363=
6K rodata, 1520K init, 1296K bss, 318796K reserved, 0K cma-reserved)
SLUB: HWalign=3D64, Order=3D0-3, MinObjects=3D0, CPUs=3D8, Nodes=3D1
Hierarchical RCU implementation.
	Build-time adjustment of leaf fanout to 64.
	RCU restricting CPUs from NR_CPUS=3D256 to nr_cpu_ids=3D8.
RCU: Adjusting geometry for rcu_fanout_leaf=3D64, nr_cpu_ids=3D8
NR_IRQS:16640 nr_irqs:488 16
	Offload RCU callbacks from all CPUs
	Offload RCU callbacks from CPUs: 0-7.
Console: colour dummy device 80x25
console [tty0] enabled
clocksource: hpet: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: =
133484882848 ns
hpet clockevent registered
tsc: Fast TSC calibration using PIT
tsc: Detected 2494.483 MHz processor
Calibrating delay loop (skipped), value calculated using timer frequency.=
=2E 4988.96 BogoMIPS (lpj=3D9977932)
pid_max: default: 32768 minimum: 301
ACPI: Core revision 20160422
Security Framework initialized
Yama: becoming mindful.
AppArmor: AppArmor initialized
Dentry cache hash table entries: 524288 (order: 10, 4194304 bytes)
Inode-cache hash table entries: 262144 (order: 9, 2097152 bytes)
Mount-cache hash table entries: 8192 (order: 4, 65536 bytes)
Mountpoint-cache hash table entries: 8192 (order: 4, 65536 bytes)
CPU: Physical Processor ID: 0
CPU: Processor Core ID: 0
ENERGY_PERF_BIAS: Set to 'normal', was 'performance'
ENERGY_PERF_BIAS: View and update with x86_energy_perf_policy(8)
mce: CPU supports 7 MCE banks
CPU0: Thermal monitoring enabled (TM1)
process: using mwait in idle threads
Last level iTLB entries: 4KB 512, 2MB 8, 4MB 8
Last level dTLB entries: 4KB 512, 2MB 32, 4MB 32, 1GB 0
Freeing SMP alternatives memory: 32K (ffffffff81ebc000 - ffffffff81ec4000=
)
ftrace: allocating 31677 entries in 124 pages
smpboot: Max logical packages: 4
smpboot: APIC(0) Converting physical 0 to logical package 0
x2apic: IRQ remapping doesn't support X2APIC mode
=2E.TIMER: vector=3D0x30 apic1=3D0 pin1=3D2 apic2=3D-1 pin2=3D-1
TSC deadline timer enabled
smpboot: CPU0: Intel(R) Core(TM) i5-3210M CPU @ 2.50GHz (family: 0x6, mod=
el: 0x3a, stepping: 0x9)
Performance Events: PEBS fmt1+, 16-deep LBR, IvyBridge events, full-width=
 counters, Intel PMU driver.
=2E.. version:                3
=2E.. bit width:              48
=2E.. generic registers:      4
=2E.. value mask:             0000ffffffffffff
=2E.. max period:             0000ffffffffffff
=2E.. fixed-purpose events:   3
=2E.. event mask:             000000070000000f
NMI watchdog: enabled on all CPUs, permanently consumes one hw-PMU counte=
r.
x86: Booting SMP configuration:
=2E... node  #0, CPUs:      #1 #2
calibrate_delay_direct() dropping max bogoMips estimate 4 =3D 447004294
 #3<6>x86: Booted up 1 node, 4 CPUs
smpboot: Total of 4 processors activated (19959.45 BogoMIPS)
devtmpfs: initialized
x86/mm: Memory block size: 128MB
evm: security.selinux
evm: security.SMACK64
evm: security.SMACK64EXEC
evm: security.SMACK64TRANSMUTE
evm: security.SMACK64MMAP
evm: security.ima
evm: security.capability
PM: Registering ACPI NVS region [mem 0xa6ebf000-0xa6fbefff] (1048576 byte=
s)
clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_n=
s: 7645041785100000 ns
pinctrl core: initialized pinctrl subsystem
RTC time: 17:27:07, date: 06/01/16
NET: Registered protocol family 16
cpuidle: using governor ladder
cpuidle: using governor menu
Simple Boot Flag at 0x44 set to 0x1
ACPI FADT declares the system doesn't support PCIe ASPM, so disable it
ACPI: bus type PCI registered
acpiphp: ACPI Hot Plug PCI Controller Driver version: 0.5
PCI: MMCONFIG for domain 0000 [bus 00-ff] at [mem 0xe0000000-0xefffffff] =
(base 0xe0000000)
PCI: MMCONFIG at [mem 0xe0000000-0xefffffff] reserved in E820
PCI: Using configuration type 1 for base access
core: PMU erratum BJ122, BV98, HSD29 worked around, HT is on
HugeTLB registered 2 MB page size, pre-allocated 0 pages
ACPI: Added _OSI(Module Device)
ACPI: Added _OSI(Processor Device)
ACPI: Added _OSI(3.0 _SCP Extensions)
ACPI: Added _OSI(Processor Aggregator Device)
ACPI: Executed 1 blocks of module-level executable AML code
ACPI: 4 ACPI AML tables successfully acquired and loaded

ACPI: [Firmware Bug]: BIOS _OSI(Linux) query ignored
ACPI: Dynamic OEM Table Load:
ACPI: SSDT 0xFFFF880149E95000 00083B (v01 PmRef  Cpu0Cst  00003001 INTL 2=
0111123)
ACPI: Dynamic OEM Table Load:
ACPI: SSDT 0xFFFF880149ECE800 000303 (v01 PmRef  ApIst    00003000 INTL 2=
0111123)
ACPI: Dynamic OEM Table Load:
ACPI: SSDT 0xFFFF880149E8B600 000119 (v01 PmRef  ApCst    00003000 INTL 2=
0111123)
ACPI: Interpreter enabled
ACPI: (supports S0 S3 S4 S5)
ACPI: Using IOAPIC for interrupt routing
PCI: Using host bridge windows from ACPI; if necessary, use "pci=3Dnocrs"=
 and report a bug
ACPI: PCI Root Bridge [PCI0] (domain 0000 [bus 00-fe])
acpi PNP0A08:00: _OSC: OS supports [ExtendedConfig ASPM ClockPM Segments =
MSI]
\_SB_.PCI0 (33DB4D5B-1FF7-401C-9657-7441C03DD766): _OSC invalid UUID
_OSC request data: 1 1f 0
acpi PNP0A08:00: _OSC failed (AE_ERROR); disabling ASPM
PCI host bridge to bus 0000:00
pci_bus 0000:00: root bus resource [io  0x0000-0x0cf7 window]
pci_bus 0000:00: root bus resource [io  0x0d00-0xffff window]
pci_bus 0000:00: root bus resource [mem 0x000a0000-0x000bffff window]
pci_bus 0000:00: root bus resource [mem 0xafa00000-0xfeafffff window]
pci_bus 0000:00: root bus resource [bus 00-fe]
pci 0000:00:00.0: [8086:0154] type 00 class 0x060000
pci 0000:00:02.0: [8086:0166] type 00 class 0x030000
pci 0000:00:02.0: reg 0x10: [mem 0xc0000000-0xc03fffff 64bit]
pci 0000:00:02.0: reg 0x18: [mem 0xb0000000-0xbfffffff 64bit pref]
pci 0000:00:02.0: reg 0x20: [io  0x3000-0x303f]
pci 0000:00:14.0: [8086:1e31] type 00 class 0x0c0330
pci 0000:00:14.0: reg 0x10: [mem 0xc0700000-0xc070ffff 64bit]
pci 0000:00:14.0: PME# supported from D3hot D3cold
pci 0000:00:14.0: System wakeup disabled by ACPI
pci 0000:00:16.0: [8086:1e3a] type 00 class 0x078000
pci 0000:00:16.0: reg 0x10: [mem 0xc0714000-0xc071400f 64bit]
pci 0000:00:16.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.0: [8086:1e2d] type 00 class 0x0c0320
pci 0000:00:1a.0: reg 0x10: [mem 0xc0719000-0xc07193ff]
pci 0000:00:1a.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1a.0: System wakeup disabled by ACPI
pci 0000:00:1b.0: [8086:1e20] type 00 class 0x040300
pci 0000:00:1b.0: reg 0x10: [mem 0xc0710000-0xc0713fff 64bit]
pci 0000:00:1b.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1b.0: System wakeup disabled by ACPI
pci 0000:00:1c.0: [8086:1e10] type 01 class 0x060400
pci 0000:00:1c.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.0: System wakeup disabled by ACPI
pci 0000:00:1c.2: [8086:1e14] type 01 class 0x060400
pci 0000:00:1c.2: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.2: System wakeup disabled by ACPI
pci 0000:00:1c.7: [8086:1e1e] type 01 class 0x060400
pci 0000:00:1c.7: PME# supported from D0 D3hot D3cold
pci 0000:00:1c.7: System wakeup disabled by ACPI
pci 0000:00:1d.0: [8086:1e26] type 00 class 0x0c0320
pci 0000:00:1d.0: reg 0x10: [mem 0xc0718000-0xc07183ff]
pci 0000:00:1d.0: PME# supported from D0 D3hot D3cold
pci 0000:00:1d.0: System wakeup disabled by ACPI
pci 0000:00:1f.0: [8086:1e57] type 00 class 0x060100
pci 0000:00:1f.2: [8086:1e03] type 00 class 0x010601
pci 0000:00:1f.2: reg 0x10: [io  0x3088-0x308f]
pci 0000:00:1f.2: reg 0x14: [io  0x3094-0x3097]
pci 0000:00:1f.2: reg 0x18: [io  0x3080-0x3087]
pci 0000:00:1f.2: reg 0x1c: [io  0x3090-0x3093]
pci 0000:00:1f.2: reg 0x20: [io  0x3060-0x307f]
pci 0000:00:1f.2: reg 0x24: [mem 0xc0717000-0xc07177ff]
pci 0000:00:1f.2: PME# supported from D3hot
pci 0000:00:1f.3: [8086:1e22] type 00 class 0x0c0500
pci 0000:00:1f.3: reg 0x10: [mem 0xc0715000-0xc07150ff 64bit]
pci 0000:00:1f.3: reg 0x20: [io  0x3040-0x305f]
pci 0000:00:1c.0: PCI bridge to [bus 02]
pci 0000:04:00.0: [10ec:5289] type 00 class 0xff0000
pci 0000:04:00.0: reg 0x10: [mem 0xc0600000-0xc060ffff]
pci 0000:04:00.0: supports D1 D2
pci 0000:04:00.0: PME# supported from D1 D2 D3hot D3cold
pci 0000:04:00.0: System wakeup disabled by ACPI
pci 0000:04:00.2: [10ec:8168] type 00 class 0x020000
pci 0000:04:00.2: reg 0x10: [io  0x2000-0x20ff]
pci 0000:04:00.2: reg 0x18: [mem 0xc0404000-0xc0404fff 64bit pref]
pci 0000:04:00.2: reg 0x20: [mem 0xc0400000-0xc0403fff 64bit pref]
pci 0000:04:00.2: supports D1 D2
pci 0000:04:00.2: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:00:1c.2: PCI bridge to [bus 04]
pci 0000:00:1c.2:   bridge window [io  0x2000-0x2fff]
pci 0000:00:1c.2:   bridge window [mem 0xc0600000-0xc06fffff]
pci 0000:00:1c.2:   bridge window [mem 0xc0400000-0xc04fffff 64bit pref]
pci 0000:09:00.0: [168c:0034] type 00 class 0x028000
pci 0000:09:00.0: reg 0x10: [mem 0xc0500000-0xc057ffff 64bit]
pci 0000:09:00.0: reg 0x30: [mem 0xffff0000-0xffffffff pref]
pci 0000:09:00.0: supports D1 D2
pci 0000:09:00.0: PME# supported from D0 D1 D2 D3hot D3cold
pci 0000:09:00.0: System wakeup disabled by ACPI
pci 0000:00:1c.7: PCI bridge to [bus 09]
pci 0000:00:1c.7:   bridge window [mem 0xc0500000-0xc05fffff]
ACPI: PCI Interrupt Link [LNKA] (IRQs 1 3 4 5 6 10 11 12 14 15) *7
ACPI: PCI Interrupt Link [LNKB] (IRQs 1 3 4 5 6 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKC] (IRQs 1 3 4 5 6 10 *11 12 14 15)
ACPI: PCI Interrupt Link [LNKD] (IRQs 1 3 4 5 6 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKE] (IRQs 1 3 4 5 6 10 11 12 14 15) *0, disab=
led.
ACPI: PCI Interrupt Link [LNKF] (IRQs 1 3 4 5 6 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKG] (IRQs 1 3 4 5 6 *10 11 12 14 15)
ACPI: PCI Interrupt Link [LNKH] (IRQs 1 3 4 5 6 10 11 12 14 15) *7
ACPI: Enabled 4 GPEs in block 00 to 3F
ACPI : EC: GPE =3D 0x17, I/O: command/status =3D 0x66, data =3D 0x62
ACPI : EC: EC started
vgaarb: setting as boot device: PCI:0000:00:02.0
vgaarb: device added: PCI:0000:00:02.0,decodes=3Dio+mem,owns=3Dio+mem,loc=
ks=3Dnone
vgaarb: loaded
vgaarb: bridge control possible 0000:00:02.0
SCSI subsystem initialized
libata version 3.00 loaded.
ACPI: bus type USB registered
usbcore: registered new interface driver usbfs
usbcore: registered new interface driver hub
usbcore: registered new device driver usb
PCI: Using ACPI for IRQ routing
PCI: pci_cache_line_size set to 64 bytes
e820: reserve RAM buffer [mem 0x0009d800-0x0009ffff]
e820: reserve RAM buffer [mem 0x40004000-0x43ffffff]
e820: reserve RAM buffer [mem 0xa6abf000-0xa7ffffff]
e820: reserve RAM buffer [mem 0xa7000000-0xa7ffffff]
e820: reserve RAM buffer [mem 0x14f600000-0x14fffffff]
NetLabel: Initializing
NetLabel:  domain hash size =3D 128
NetLabel:  protocols =3D UNLABELED CIPSOv4
NetLabel:  unlabeled traffic allowed by default
hpet0: at MMIO 0xfed00000, IRQs 2, 8, 0, 0, 0, 0, 0, 0
hpet0: 8 comparators, 64-bit 14.318180 MHz counter
clocksource: Switched to clocksource hpet
VFS: Disk quotas dquot_6.6.0
VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
AppArmor: AppArmor Filesystem Enabled
pnp: PnP ACPI init
system 00:00: [io  0x0680-0x069f] has been reserved
system 00:00: [io  0x1000-0x100f] has been reserved
system 00:00: [io  0xffff] has been reserved
system 00:00: [io  0xffff] has been reserved
system 00:00: [io  0x0400-0x0453] could not be reserved
system 00:00: [io  0x0458-0x047f] has been reserved
system 00:00: [io  0x0500-0x057f] has been reserved
system 00:00: [io  0x164e-0x164f] has been reserved
system 00:00: Plug and Play ACPI device, IDs PNP0c02 (active)
pnp 00:01: Plug and Play ACPI device, IDs PNP0b00 (active)
system 00:02: [io  0x0454-0x0457] has been reserved
system 00:02: Plug and Play ACPI device, IDs INT3f0d PNP0c02 (active)
pnp 00:03: Plug and Play ACPI device, IDs PNP0303 (active)
pnp 00:04: Plug and Play ACPI device, IDs SYN1b20 SYN1b00 SYN0002 PNP0f13=
 (active)
system 00:05: [mem 0xfed1c000-0xfed1ffff] has been reserved
system 00:05: [mem 0xfed10000-0xfed17fff] has been reserved
system 00:05: [mem 0xfed18000-0xfed18fff] has been reserved
system 00:05: [mem 0xfed19000-0xfed19fff] has been reserved
system 00:05: [mem 0xe0000000-0xefffffff] has been reserved
system 00:05: [mem 0xfed20000-0xfed3ffff] has been reserved
system 00:05: [mem 0xfed90000-0xfed93fff] has been reserved
system 00:05: [mem 0xff000000-0xffffffff] could not be reserved
system 00:05: [mem 0xfee00000-0xfeefffff] could not be reserved
system 00:05: [mem 0xafa00000-0xafa00fff] has been reserved
system 00:05: Plug and Play ACPI device, IDs PNP0c02 (active)
system 00:06: [mem 0x20000000-0x201fffff] has been reserved
system 00:06: [mem 0x40004000-0x40004fff] has been reserved
system 00:06: Plug and Play ACPI device, IDs PNP0c01 (active)
pnp: PnP ACPI: found 7 devices
clocksource: acpi_pm: mask: 0xffffff max_cycles: 0xffffff, max_idle_ns: 2=
085701024 ns
pci 0000:09:00.0: can't claim BAR 6 [mem 0xffff0000-0xffffffff pref]: no =
compatible bridge window
pci 0000:00:1c.0: PCI bridge to [bus 02]
pci 0000:00:1c.2: PCI bridge to [bus 04]
pci 0000:00:1c.2:   bridge window [io  0x2000-0x2fff]
pci 0000:00:1c.2:   bridge window [mem 0xc0600000-0xc06fffff]
pci 0000:00:1c.2:   bridge window [mem 0xc0400000-0xc04fffff 64bit pref]
pci 0000:09:00.0: BAR 6: assigned [mem 0xc0580000-0xc058ffff pref]
pci 0000:00:1c.7: PCI bridge to [bus 09]
pci 0000:00:1c.7:   bridge window [mem 0xc0500000-0xc05fffff]
pci_bus 0000:00: resource 4 [io  0x0000-0x0cf7 window]
pci_bus 0000:00: resource 5 [io  0x0d00-0xffff window]
pci_bus 0000:00: resource 6 [mem 0x000a0000-0x000bffff window]
pci_bus 0000:00: resource 7 [mem 0xafa00000-0xfeafffff window]
pci_bus 0000:04: resource 0 [io  0x2000-0x2fff]
pci_bus 0000:04: resource 1 [mem 0xc0600000-0xc06fffff]
pci_bus 0000:04: resource 2 [mem 0xc0400000-0xc04fffff 64bit pref]
pci_bus 0000:09: resource 1 [mem 0xc0500000-0xc05fffff]
NET: Registered protocol family 2
TCP established hash table entries: 32768 (order: 6, 262144 bytes)
TCP bind hash table entries: 32768 (order: 7, 524288 bytes)
TCP: Hash tables configured (established 32768 bind 32768)
UDP hash table entries: 2048 (order: 4, 65536 bytes)
UDP-Lite hash table entries: 2048 (order: 4, 65536 bytes)
NET: Registered protocol family 1
pci 0000:00:02.0: Video device with shadowed ROM at [mem 0x000c0000-0x000=
dffff]
PCI: CLS 64 bytes, default 64
Trying to unpack rootfs image as initramfs...
Freeing initrd memory: 171320K (ffff880023154000 - ffff88002d8a2000)
PCI-DMA: Using software bounce buffering for IO (SWIOTLB)
software IO TLB [mem 0xa2abf000-0xa6abf000] (64MB) mapped at [ffff8800a2a=
bf000-ffff8800a6abefff]
RAPL PMU: API unit is 2^-32 Joules, 3 fixed counters, 163840 ms ovfl time=
r
RAPL PMU: hw unit of domain pp0-core 2^-16 Joules
RAPL PMU: hw unit of domain package 2^-16 Joules
RAPL PMU: hw unit of domain pp1-gpu 2^-16 Joules
Scanning for low memory corruption every 60 seconds
futex hash table entries: 2048 (order: 5, 131072 bytes)
audit: initializing netlink subsys (disabled)
audit: type=3D2000 audit(1464802028.988:1): initialized
Initialise system trusted keyrings
workingset: timestamp_bits=3D38 max_order=3D20 bucket_order=3D0
zbud: loaded
fuse init (API version 7.24)
Key type big_key registered
Key type asymmetric registered
Asymmetric key parser 'x509' registered
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 250)
io scheduler noop registered
io scheduler deadline registered (default)
io scheduler cfq registered
pci_hotplug: PCI Hot Plug PCI Core version: 0.5
pciehp: PCI Express Hot Plug Controller Driver version: 0.4
vesafb: mode is 1366x768x32, linelength=3D5504, pages=3D0
vesafb: scrolling: redraw
vesafb: Truecolor: size=3D8:8:8:8, shift=3D24:16:8:0
pmd_set_huge: Cannot satisfy [mem 0xb0000000-0xb0200000] with a huge-page=
 mapping due to MTRR override.
vesafb: framebuffer at 0xb0000000, mapped to 0xffffc90000800000, using 41=
60k, total 4160k
Console: switching to colour frame buffer device 170x48
fb0: VESA VGA frame buffer device
intel_idle: MWAIT substates: 0x21120
intel_idle: v0.4.1 model 0x3A
intel_idle: lapic_timer_reliable_states 0xffffffff
ACPI: AC Adapter [ACAD] (off-line)
input: Power Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0C:00/input/=
input0
ACPI: Power Button [PWRB]
input: Sleep Button as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0E:00/input/=
input1
ACPI: Sleep Button [SLPB]
input: Lid Switch as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0C0D:00/input/in=
put2
ACPI: Lid Switch [LID]
input: Power Button as /devices/LNXSYSTM:00/LNXPWRBN:00/input/input3
ACPI: Power Button [PWRF]
thermal LNXTHERM:00: registered as thermal_zone0
ACPI: Thermal Zone [THRM] (63 C)
GHES: HEST is not enabled!
Serial: 8250/16550 driver, 32 ports, IRQ sharing enabled
ACPI: Battery Slot [BAT1] (battery present)
Linux agpgart interface v0.103
brd: module loaded
loop: module loaded
libphy: Fixed MDIO Bus: probed
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
PPP generic driver version 2.4.2
ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
ehci-pci: EHCI PCI platform driver
ehci-pci 0000:00:1a.0: EHCI Host Controller
ehci-pci 0000:00:1a.0: new USB bus registered, assigned bus number 1
ehci-pci 0000:00:1a.0: debug port 2
ehci-pci 0000:00:1a.0: cache line size of 64 is not supported
ehci-pci 0000:00:1a.0: irq 16, io mem 0xc0719000
ehci-pci 0000:00:1a.0: USB 2.0 started, EHCI 1.00
usb usb1: New USB device found, idVendor=3D1d6b, idProduct=3D0002
usb usb1: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb1: Product: EHCI Host Controller
usb usb1: Manufacturer: Linux 4.7.0-rc1-next-20160530+ ehci_hcd
usb usb1: SerialNumber: 0000:00:1a.0
hub 1-0:1.0: USB hub found
hub 1-0:1.0: 2 ports detected
ehci-pci 0000:00:1d.0: EHCI Host Controller
ehci-pci 0000:00:1d.0: new USB bus registered, assigned bus number 2
ehci-pci 0000:00:1d.0: debug port 2
ehci-pci 0000:00:1d.0: cache line size of 64 is not supported
ehci-pci 0000:00:1d.0: irq 23, io mem 0xc0718000
ehci-pci 0000:00:1d.0: USB 2.0 started, EHCI 1.00
usb usb2: New USB device found, idVendor=3D1d6b, idProduct=3D0002
usb usb2: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb2: Product: EHCI Host Controller
usb usb2: Manufacturer: Linux 4.7.0-rc1-next-20160530+ ehci_hcd
usb usb2: SerialNumber: 0000:00:1d.0
hub 2-0:1.0: USB hub found
hub 2-0:1.0: 2 ports detected
ehci-platform: EHCI generic platform driver
ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
ohci-pci: OHCI PCI platform driver
ohci-platform: OHCI generic platform driver
uhci_hcd: USB Universal Host Controller Interface driver
xhci_hcd 0000:00:14.0: xHCI Host Controller
xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 3
xhci_hcd 0000:00:14.0: hcc params 0x20007181 hci version 0x100 quirks 0x0=
000b930
xhci_hcd 0000:00:14.0: cache line size of 64 is not supported
usb usb3: New USB device found, idVendor=3D1d6b, idProduct=3D0002
usb usb3: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb3: Product: xHCI Host Controller
usb usb3: Manufacturer: Linux 4.7.0-rc1-next-20160530+ xhci-hcd
usb usb3: SerialNumber: 0000:00:14.0
hub 3-0:1.0: USB hub found
hub 3-0:1.0: 4 ports detected
xhci_hcd 0000:00:14.0: xHCI Host Controller
xhci_hcd 0000:00:14.0: new USB bus registered, assigned bus number 4
usb usb4: New USB device found, idVendor=3D1d6b, idProduct=3D0003
usb usb4: New USB device strings: Mfr=3D3, Product=3D2, SerialNumber=3D1
usb usb4: Product: xHCI Host Controller
usb usb4: Manufacturer: Linux 4.7.0-rc1-next-20160530+ xhci-hcd
usb usb4: SerialNumber: 0000:00:14.0
hub 4-0:1.0: USB hub found
hub 4-0:1.0: 4 ports detected
i8042: PNP: PS/2 Controller [PNP0303:PS2K,PNP0f13:PS2M] at 0x60,0x64 irq =
1,12
i8042: Detected active multiplexing controller, rev 1.1
serio: i8042 KBD port at 0x60,0x64 irq 1
serio: i8042 AUX0 port at 0x60,0x64 irq 12
serio: i8042 AUX1 port at 0x60,0x64 irq 12
serio: i8042 AUX2 port at 0x60,0x64 irq 12
serio: i8042 AUX3 port at 0x60,0x64 irq 12
mousedev: PS/2 mouse device common for all mice
rtc_cmos 00:01: RTC can wake from S4
rtc_cmos 00:01: rtc core: registered rtc_cmos as rtc0
rtc_cmos 00:01: alarms up to one month, 242 bytes nvram, hpet irqs
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.34.0-ioctl (2015-10-28) initialised: dm-devel@red=
hat.com
intel_pstate: Intel P-state driver initializing
ledtrig-cpu: registered to indicate activity on CPUs
NET: Registered protocol family 10
NET: Registered protocol family 17
Key type dns_resolver registered
microcode: CPU0 sig=3D0x306a9, pf=3D0x10, revision=3D0x12
microcode: CPU1 sig=3D0x306a9, pf=3D0x10, revision=3D0x12
microcode: CPU2 sig=3D0x306a9, pf=3D0x10, revision=3D0x12
microcode: CPU3 sig=3D0x306a9, pf=3D0x10, revision=3D0x12
microcode: Microcode Update Driver: v2.01 <tigran@aivazian.fsnet.co.uk>, =
Peter Oruba
registered taskstats version 1
Loading compiled-in X.509 certificates
Loaded X.509 cert 'Build time autogenerated kernel key: 4886a352d5af5b320=
9ac3fd30dea3e37a92eb39b'
zswap: loaded using pool lzo/zbud
Key type trusted registered
input: AT Translated Set 2 keyboard as /devices/platform/i8042/serio0/inp=
ut/input4
Key type encrypted registered
AppArmor: AppArmor sha1 policy hashing enabled
ima: No TPM chip found, activating TPM-bypass!
evm: HMAC attrs: 0x1
  Magic number: 4:802:490
rtc_cmos 00:01: setting system clock to 2016-06-01 17:27:10 UTC (14648020=
30)
BIOS EDD facility v0.16 2004-Jun-25, 0 devices found
EDD information not available.
PM: Hibernation image not present or could not be loaded.
Freeing unused kernel memory: 1520K (ffffffff81d40000 - ffffffff81ebc000)=

Write protecting the kernel read-only data: 12288k
Freeing unused kernel memory: 120K (ffff8800017e2000 - ffff880001800000)
Freeing unused kernel memory: 460K (ffff880001b8d000 - ffff880001c00000)
systemd-udevd[151]: starting version 204
rtsx_pci 0000:04:00.0: rtsx_pci_acquire_irq: pcr->msi_en =3D 1, pci->irq =
=3D 25
ahci 0000:00:1f.2: version 3.0
ahci 0000:00:1f.2: AHCI 0001.0300 32 slots 6 ports 6 Gbps 0x21 impl SATA =
mode
ahci 0000:00:1f.2: flags: 64bit ncq pm led clo pio slum part ems apst=20
r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:04:00.2: can't disable ASPM; OS doesn't have ASPM control
r8169 0000:04:00.2 eth0: RTL8411 at 0xffffc90000796000, 04:7d:7b:ce:d2:f1=
, XID 08800800 IRQ 27
r8169 0000:04:00.2 eth0: jumbo features [frames: 9200 bytes, tx checksumm=
ing: ko]
scsi host0: ahci
scsi host1: ahci
scsi host2: ahci
scsi host3: ahci
scsi host4: ahci
scsi host5: ahci
ata1: SATA max UDMA/133 abar m2048@0xc0717000 port 0xc0717100 irq 26
ata2: DUMMY
ata3: DUMMY
ata4: DUMMY
ata5: DUMMY
ata6: SATA max UDMA/133 abar m2048@0xc0717000 port 0xc0717380 irq 26
usb 1-1: new high-speed USB device number 2 using ehci-pci
usb 2-1: new high-speed USB device number 2 using ehci-pci
ata1: SATA link up 3.0 Gbps (SStatus 123 SControl 300)
tsc: Refined TSC clocksource calibration: 2494.333 MHz
clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x23f45085418, max=
_idle_ns: 440795285711 ns
ata1.00: ATA-8: WDC WD5000BPVT-22HXZT3, 01.01A01, max UDMA/133
ata1.00: 976773168 sectors, multi 0: LBA48 NCQ (depth 31/32), AA
ata6: SATA link up 1.5 Gbps (SStatus 113 SControl 300)
ata1.00: configured for UDMA/133
scsi 0:0:0:0: Direct-Access     ATA      WDC WD5000BPVT-2 1A01 PQ: 0 ANSI=
: 5
ata6.00: ATAPI: HL-DT-ST DVDRAM GT70N, YP10, max UDMA/133
ata6.00: configured for UDMA/133
sd 0:0:0:0: [sda] 976773168 512-byte logical blocks: (500 GB/466 GiB)
sd 0:0:0:0: [sda] 4096-byte physical blocks
sd 0:0:0:0: Attached scsi generic sg0 type 0
sd 0:0:0:0: [sda] Write Protect is off
sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't supp=
ort DPO or FUA
scsi 5:0:0:0: CD-ROM            HL-DT-ST DVDRAM GT70N     YP10 PQ: 0 ANSI=
: 5
usb 1-1: New USB device found, idVendor=3D8087, idProduct=3D0024
usb 1-1: New USB device strings: Mfr=3D0, Product=3D0, SerialNumber=3D0
hub 1-1:1.0: USB hub found
hub 1-1:1.0: 6 ports detected
sr 5:0:0:0: [sr0] scsi3-mmc drive: 24x/24x writer dvd-ram cd/rw xa/form2 =
cdda tray
cdrom: Uniform CD-ROM driver Revision: 3.20
sr 5:0:0:0: Attached scsi CD-ROM sr0
sr 5:0:0:0: Attached scsi generic sg1 type 5
usb 2-1: New USB device found, idVendor=3D8087, idProduct=3D0024
usb 2-1: New USB device strings: Mfr=3D0, Product=3D0, SerialNumber=3D0
hub 2-1:1.0: USB hub found
hub 2-1:1.0: 8 ports detected
 sda: sda1 sda2 sda3 < sda5 >
sd 0:0:0:0: [sda] Attached SCSI disk
usb 1-1.1: new high-speed USB device number 3 using ehci-pci
psmouse serio2: synaptics: queried max coordinates: x [..5774], y [..5028=
]
psmouse serio2: synaptics: queried min coordinates: x [1168..], y [880..]=

psmouse serio2: synaptics: Touchpad model: 1, fw: 7.5, id: 0x1c0b1, caps:=
 0xf00e33/0x240000/0xa2400/0x0, board id: 540, fw id: 1063070
usb 1-1.1: New USB device found, idVendor=3D1bcf, idProduct=3D2c18
usb 1-1.1: New USB device strings: Mfr=3D1, Product=3D2, SerialNumber=3D0=

usb 1-1.1: Product: HD WebCam
usb 1-1.1: Manufacturer: NC.21411.00G22537EB0LM0008
input: SynPS/2 Synaptics TouchPad as /devices/platform/i8042/serio2/input=
/input10
EXT4-fs (sda5): mounted filesystem with ordered data mode. Opts: (null)
clocksource: Switched to clocksource tsc
random: init urandom read with 124 bits of entropy available
random: nonblocking pool is initialized
init: plymouth-upstart-bridge main process (233) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (245) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (247) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (248) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (250) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (251) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (253) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (254) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (256) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (257) terminated with status 1=

init: plymouth-upstart-bridge main process ended, respawning
init: plymouth-upstart-bridge main process (259) terminated with status 1=

init: plymouth-upstart-bridge respawning too fast, stopped
init: ureadahead main process (236) terminated with status 5
Adding 7999484k swap on /dev/sda2.  Priority:-1 extents:1 across:7999484k=
 FS
EXT4-fs (sda5): re-mounted. Opts: errors=3Dremount-ro
systemd-udevd[497]: starting version 204
lp: driver loaded but no devices found
ppdev: user-space parallel port driver
wmi: Mapper loaded
shpchp: Standard Hot Plug PCI Controller Driver version: 0.4
ACPI Warning: SystemIO range 0x0000000000000428-0x000000000000042F confli=
cts with OpRegion 0x0000000000000400-0x000000000000047F (\PMIO) (20160422=
/utaddress-255)
ACPI: If an ACPI driver is available for this device, you should use it i=
nstead of the native driver
ACPI Warning: SystemIO range 0x0000000000000540-0x000000000000054F confli=
cts with OpRegion 0x0000000000000500-0x0000000000000563 (\GPIO) (20160422=
/utaddress-255)
ACPI: If an ACPI driver is available for this device, you should use it i=
nstead of the native driver
ACPI Warning: SystemIO range 0x0000000000000530-0x000000000000053F confli=
cts with OpRegion 0x0000000000000500-0x0000000000000563 (\GPIO) (20160422=
/utaddress-255)
ACPI: If an ACPI driver is available for this device, you should use it i=
nstead of the native driver
ACPI Warning: SystemIO range 0x0000000000000500-0x000000000000052F confli=
cts with OpRegion 0x0000000000000500-0x0000000000000563 (\GPIO) (20160422=
/utaddress-255)
ACPI: If an ACPI driver is available for this device, you should use it i=
nstead of the native driver
lpc_ich: Resource conflict(s) found affecting gpio_ich
AVX version of gcm_enc/dec engaged.
AES CTR mode by8 optimization enabled
[drm] Initialized drm 1.1.0 20060810
acer_wmi: Acer Laptop ACPI-WMI Extras
acer_wmi: No or unsupported WMI interface, unable to load
media: Linux media interface: v0.10
audit: type=3D1400 audit(1464782245.187:2): apparmor=3D"STATUS" operation=
=3D"profile_load" name=3D"/sbin/dhclient" pid=3D602 comm=3D"apparmor_pars=
er"
audit: type=3D1400 audit(1464782245.187:3): apparmor=3D"STATUS" operation=
=3D"profile_load" name=3D"/usr/lib/NetworkManager/nm-dhcp-client.action" =
pid=3D602 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782245.187:4): apparmor=3D"STATUS" operation=
=3D"profile_load" name=3D"/usr/lib/connman/scripts/dhclient-script" pid=3D=
602 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782245.187:5): apparmor=3D"STATUS" operation=
=3D"profile_replace" name=3D"/sbin/dhclient" pid=3D603 comm=3D"apparmor_p=
arser"
audit: type=3D1400 audit(1464782245.187:6): apparmor=3D"STATUS" operation=
=3D"profile_replace" name=3D"/usr/lib/NetworkManager/nm-dhcp-client.actio=
n" pid=3D603 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782245.187:7): apparmor=3D"STATUS" operation=
=3D"profile_replace" name=3D"/usr/lib/connman/scripts/dhclient-script" pi=
d=3D603 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782245.187:8): apparmor=3D"STATUS" operation=
=3D"profile_replace" name=3D"/usr/lib/NetworkManager/nm-dhcp-client.actio=
n" pid=3D602 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782245.187:9): apparmor=3D"STATUS" operation=
=3D"profile_replace" name=3D"/usr/lib/connman/scripts/dhclient-script" pi=
d=3D602 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782245.187:10): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/usr/lib/NetworkManager/nm-dhcp-client.acti=
on" pid=3D603 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782245.187:11): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/usr/lib/connman/scripts/dhclient-script" p=
id=3D603 comm=3D"apparmor_parser"
intel_rapl: Found RAPL domain package
intel_rapl: Found RAPL domain core
intel_rapl: Found RAPL domain uncore
intel_rapl: RAPL package 0 domain package locked by BIOS
Linux video capture interface: v2.00
[drm] Memory usable by graphics device =3D 2048M
checking generic (b0000000 410000) vs hw (b0000000 10000000)
fb: switching to inteldrmfb from VESA VGA
Console: switching to colour dummy device 80x25
[drm] Replacing VGA console driver
[drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[drm] Driver supports precise vblank timestamp query.
vgaarb: device changed decodes: PCI:0000:00:02.0,olddecodes=3Dio+mem,deco=
des=3Dio+mem:owns=3Dio+mem
ACPI: Video Device [GFX0] (multi-head: yes  rom: no  post: no)
input: Video Bus as /devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A08:00/LNXVIDEO:=
00/input/input13
[drm] Initialized i915 1.6.0 20160425 for 0000:00:02.0 on minor 0
fbcon: inteldrmfb (fb0) is primary device
uvcvideo: Found UVC 1.00 device HD WebCam (1bcf:2c18)
uvcvideo 1-1.1:1.0: Entity type for entity Extension 4 was not initialize=
d!
uvcvideo 1-1.1:1.0: Entity type for entity Extension 3 was not initialize=
d!
uvcvideo 1-1.1:1.0: Entity type for entity Processing 2 was not initializ=
ed!
uvcvideo 1-1.1:1.0: Entity type for entity Camera 1 was not initialized!
input: HD WebCam as /devices/pci0000:00/0000:00:1a.0/usb1/1-1/1-1.1/1-1.1=
:1.0/input/input14
usbcore: registered new interface driver uvcvideo
USB Video Class driver (1.1.1)
snd_hda_codec_realtek hdaudioC0D0: autoconfig for ALC271X: line_outs=3D1 =
(0x14/0x0/0x0/0x0/0x0) type:speaker
snd_hda_codec_realtek hdaudioC0D0:    speaker_outs=3D0 (0x0/0x0/0x0/0x0/0=
x0)
snd_hda_codec_realtek hdaudioC0D0:    hp_outs=3D1 (0x21/0x0/0x0/0x0/0x0)
snd_hda_codec_realtek hdaudioC0D0:    mono: mono_out=3D0x0
snd_hda_codec_realtek hdaudioC0D0:    inputs:
snd_hda_codec_realtek hdaudioC0D0:      Internal Mic=3D0x19
snd_hda_codec_realtek hdaudioC0D0:      Mic=3D0x18
init: avahi-cups-reload main process (764) terminated with status 1
Console: switching to colour frame buffer device 170x48
snd_hda_intel 0000:00:1b.0: bound 0000:00:02.0 (ops i915_audio_component_=
bind_ops [i915])
i915 0000:00:02.0: fb0: inteldrmfb frame buffer device
input: HDA Intel PCH Mic as /devices/pci0000:00/0000:00:1b.0/sound/card0/=
input15
input: HDA Intel PCH Headphone as /devices/pci0000:00/0000:00:1b.0/sound/=
card0/input16
input: HDA Intel PCH HDMI/DP,pcm=3D3 as /devices/pci0000:00/0000:00:1b.0/=
sound/card0/input17
init: failsafe main process (668) killed by TERM signal
Bluetooth: Core ver 2.21
NET: Registered protocol family 31
Bluetooth: HCI device and connection manager initialized
Bluetooth: HCI socket layer initialized
Bluetooth: L2CAP socket layer initialized
Bluetooth: SCO socket layer initialized
Bluetooth: RFCOMM TTY layer initialized
Bluetooth: RFCOMM socket layer initialized
Bluetooth: RFCOMM ver 1.11
Bluetooth: BNEP (Ethernet Emulation) ver 1.3
Bluetooth: BNEP filters: protocol multicast
Bluetooth: BNEP socket layer initialized
ath: phy0: ASPM enabled: 0x42
ath: EEPROM regdomain: 0x6c
ath: EEPROM indicates we should expect a direct regpair map
ath: Country alpha2 being used: 00
ath: Regpair used: 0x6c
ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'
sudip: 4 ath9k-led
ieee80211 phy0: Atheros AR9462 Rev:2 mem=3D0xffffc90000a00000, irq=3D19
------------[ cut here ]------------
WARNING: CPU: 1 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: arc4 ath9k(+) bnep rfcomm ath9k_common bluetooth ath9k=
_hw snd_hda_codec_hdmi snd_hda_codec_realtek uvcvideo snd_hda_codec_gener=
ic ath snd_hda_intel mac80211 i915 snd_hda_codec videobuf2_vmalloc videob=
uf2_memops videobuf2_v4l2 cfg80211 videobuf2_core snd_hda_core videodev i=
ntel_rapl x86_pkg_temp_thermal intel_powerclamp snd_hwdep snd_pcm coretem=
p media kvm_intel kvm snd_seq_midi snd_seq_midi_event snd_rawmidi drm_kms=
_helper snd_seq snd_seq_device snd_timer irqbypass sparse_keymap crct10di=
f_pclmul drm crc32_pclmul ghash_clmulni_intel snd aesni_intel mei_me mei =
aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf128mul rtsx_pci_ms syscopyarea =
glue_helper sysfillrect ablk_helper soundcore memstick sysimgblt dm_multi=
path lpc_ich cryptd joydev serio_raw shpchp dell_smo8800 wmi mac_hid vide=
o parport_pc ppdev lp parport rtsx_pci_sdmmc psmouse r8169 ahci rtsx_pci =
libahci mii
CPU: 1 PID: 199 Comm: kworker/u16:9 Not tainted 4.7.0-rc1-next-20160530+ =
#5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df30 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: arc4 ath9k bnep rfcomm ath9k_common bluetooth ath9k_hw=
 snd_hda_codec_hdmi snd_hda_codec_realtek uvcvideo snd_hda_codec_generic =
ath snd_hda_intel mac80211 i915 snd_hda_codec videobuf2_vmalloc videobuf2=
_memops videobuf2_v4l2 cfg80211 videobuf2_core snd_hda_core videodev inte=
l_rapl x86_pkg_temp_thermal intel_powerclamp snd_hwdep snd_pcm coretemp m=
edia kvm_intel kvm snd_seq_midi snd_seq_midi_event snd_rawmidi drm_kms_he=
lper snd_seq snd_seq_device snd_timer irqbypass sparse_keymap crct10dif_p=
clmul drm crc32_pclmul ghash_clmulni_intel snd aesni_intel mei_me mei aes=
_x86_64 lrw i2c_algo_bit fb_sys_fops gf128mul rtsx_pci_ms syscopyarea glu=
e_helper sysfillrect ablk_helper soundcore memstick sysimgblt dm_multipat=
h lpc_ich cryptd joydev serio_raw shpchp dell_smo8800 wmi mac_hid video p=
arport_pc ppdev lp parport rtsx_pci_sdmmc psmouse r8169 ahci rtsx_pci lib=
ahci mii
CPU: 1 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df31 ]---
audit_printk_skb: 15 callbacks suppressed
audit: type=3D1400 audit(1464782256.059:17): apparmor=3D"STATUS" operatio=
n=3D"profile_load" name=3D"/usr/sbin/cups-browsed" pid=3D1009 comm=3D"app=
armor_parser"
r8169 0000:04:00.2 eth0: link down
IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
IPv6: ADDRCONF(NETDEV_UP): wlan0: link is not ready
audit: type=3D1400 audit(1464782256.967:18): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/sbin/dhclient" pid=3D1044 comm=3D"apparmor=
_parser"
audit: type=3D1400 audit(1464782256.967:19): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/usr/lib/NetworkManager/nm-dhcp-client.acti=
on" pid=3D1044 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782256.967:20): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/usr/lib/connman/scripts/dhclient-script" p=
id=3D1044 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782256.967:21): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/usr/lib/NetworkManager/nm-dhcp-client.acti=
on" pid=3D1044 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782256.967:22): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/usr/lib/connman/scripts/dhclient-script" p=
id=3D1044 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782256.967:23): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/usr/lib/connman/scripts/dhclient-script" p=
id=3D1044 comm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782257.007:24): apparmor=3D"STATUS" operatio=
n=3D"profile_load" name=3D"/usr/lib/libvirt/virt-aa-helper" pid=3D1047 co=
mm=3D"apparmor_parser"
audit: type=3D1400 audit(1464782257.011:25): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/usr/sbin/cups-browsed" pid=3D1049 comm=3D"=
apparmor_parser"
audit: type=3D1400 audit(1464782257.011:26): apparmor=3D"STATUS" operatio=
n=3D"profile_replace" name=3D"/usr/lib/cups/backend/cups-pdf" pid=3D1050 =
comm=3D"apparmor_parser"
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: arc4 ath9k bnep rfcomm ath9k_common bluetooth ath9k_hw=
 snd_hda_codec_hdmi snd_hda_codec_realtek uvcvideo snd_hda_codec_generic =
ath snd_hda_intel mac80211 i915 snd_hda_codec videobuf2_vmalloc videobuf2=
_memops videobuf2_v4l2 cfg80211 videobuf2_core snd_hda_core videodev inte=
l_rapl x86_pkg_temp_thermal intel_powerclamp snd_hwdep snd_pcm coretemp m=
edia kvm_intel kvm snd_seq_midi snd_seq_midi_event snd_rawmidi drm_kms_he=
lper snd_seq snd_seq_device snd_timer irqbypass sparse_keymap crct10dif_p=
clmul drm crc32_pclmul ghash_clmulni_intel snd aesni_intel mei_me mei aes=
_x86_64 lrw i2c_algo_bit fb_sys_fops gf128mul rtsx_pci_ms syscopyarea glu=
e_helper sysfillrect ablk_helper soundcore memstick sysimgblt dm_multipat=
h lpc_ich cryptd joydev serio_raw shpchp dell_smo8800 wmi mac_hid video p=
arport_pc ppdev lp parport rtsx_pci_sdmmc psmouse r8169 ahci rtsx_pci lib=
ahci mii
CPU: 0 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df32 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: arc4 ath9k bnep rfcomm ath9k_common bluetooth ath9k_hw=
 snd_hda_codec_hdmi snd_hda_codec_realtek uvcvideo snd_hda_codec_generic =
ath snd_hda_intel mac80211 i915 snd_hda_codec videobuf2_vmalloc videobuf2=
_memops videobuf2_v4l2 cfg80211 videobuf2_core snd_hda_core videodev inte=
l_rapl x86_pkg_temp_thermal intel_powerclamp snd_hwdep snd_pcm coretemp m=
edia kvm_intel kvm snd_seq_midi snd_seq_midi_event snd_rawmidi drm_kms_he=
lper snd_seq snd_seq_device snd_timer irqbypass sparse_keymap crct10dif_p=
clmul drm crc32_pclmul ghash_clmulni_intel snd aesni_intel mei_me mei aes=
_x86_64 lrw i2c_algo_bit fb_sys_fops gf128mul rtsx_pci_ms syscopyarea glu=
e_helper sysfillrect ablk_helper soundcore memstick sysimgblt dm_multipat=
h lpc_ich cryptd joydev serio_raw shpchp dell_smo8800 wmi mac_hid video p=
arport_pc ppdev lp parport rtsx_pci_sdmmc psmouse r8169 ahci rtsx_pci lib=
ahci mii
CPU: 0 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df33 ]---
sudip: 11 ath9k-rfkill
wlan0: authenticate with 00:1e:a6:60:e8:20
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
wlan0: send auth to 00:1e:a6:60:e8:20 (try 1/3)
wlan0: authenticated
wlan0: associate with 00:1e:a6:60:e8:20 (try 1/3)
wlan0: RX AssocResp from 00:1e:a6:60:e8:20 (capab=3D0x411 status=3D0 aid=3D=
2)
wlan0: associated
IPv6: ADDRCONF(NETDEV_CHANGE): wlan0: link becomes ready
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcomm ath9k_c=
ommon bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realtek uvcvide=
o snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_codec vid=
eobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf2_core sn=
d_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerclamp snd_=
hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_midi_even=
t snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer irqbypass s=
parse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_intel snd ae=
sni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf128mul rts=
x_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundcore memsti=
ck sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp dell_smo=
8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmmc psmouse=
 r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df34 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcomm ath9k_c=
ommon bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realtek uvcvide=
o snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_codec vid=
eobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf2_core sn=
d_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerclamp snd_=
hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_midi_even=
t snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer irqbypass s=
parse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_intel snd ae=
sni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf128mul rts=
x_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundcore memsti=
ck sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp dell_smo=
8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmmc psmouse=
 r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df35 ]---
Ebtables v2.0 registered
ip_tables: (C) 2000-2006 Netfilter Core Team
ip6_tables: (C) 2000-2006 Netfilter Core Team
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df36 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df37 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df38 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df39 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df3a ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df3b ]---
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
cgroup: systemd-logind (741) created nested cgroup for controller "memory=
" which has incomplete hierarchy support. Nested cgroups may change behav=
ior in the future.
cgroup: "memory" requires setting use_hierarchy to 1 on the root
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
------------[ cut here ]------------
WARNING: CPU: 3 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 3 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df3c ]---
------------[ cut here ]------------
WARNING: CPU: 3 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 3 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df3d ]---
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df3e ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df3f ]---
sudip: 11 ath9k-rfkill
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df40 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df41 ]---
init: anacron main process (1143) killed by TERM signal
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df42 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df43 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df44 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df45 ]---
------------[ cut here ]------------
WARNING: CPU: 3 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 3 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df46 ]---
------------[ cut here ]------------
WARNING: CPU: 3 PID: 194 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 3 PID: 194 Comm: kworker/u16:5 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf07d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf07d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df47 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df48 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df49 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df4a ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df4b ]---
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df4c ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df4d ]---
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df4e ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df4f ]---
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df50 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df51 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df52 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df53 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df54 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df55 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df56 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df57 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df58 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df59 ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df5a ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df5b ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df5c ]---
------------[ cut here ]------------
WARNING: CPU: 2 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 2 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df5d ]---
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
wlan0: authenticate with 00:1e:a6:60:e8:20
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
wlan0: send auth to 00:1e:a6:60:e8:20 (try 1/3)
wlan0: authenticated
wlan0: associate with 00:1e:a6:60:e8:20 (try 1/3)
wlan0: RX AssocResp from 00:1e:a6:60:e8:20 (capab=3D0x411 status=3D0 aid=3D=
2)
wlan0: associated
------------[ cut here ]------------
WARNING: CPU: 3 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 3 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df5e ]---
------------[ cut here ]------------
WARNING: CPU: 3 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 3 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df5f ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df60 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 193 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 0 PID: 193 Comm: kworker/u16:4 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf0bd28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf0bd68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df61 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df62 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df63 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df64 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df65 ]---
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
------------[ cut here ]------------
WARNING: CPU: 1 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2778 a=
th9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000ada00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775b19>] ath9k_hw_gpio_get+0x1a9/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df66 ]---
------------[ cut here ]------------
WARNING: CPU: 1 PID: 199 at ../drivers/net/wireless/ath/ath9k/hw.c:2798 a=
th9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
Modules linked in: ip6table_filter ip6_tables iptable_filter ip_tables eb=
table_nat ebtables x_tables drbg ansi_cprng ctr ccm arc4 ath9k bnep rfcom=
m ath9k_common bluetooth ath9k_hw snd_hda_codec_hdmi snd_hda_codec_realte=
k uvcvideo snd_hda_codec_generic ath snd_hda_intel mac80211 i915 snd_hda_=
codec videobuf2_vmalloc videobuf2_memops videobuf2_v4l2 cfg80211 videobuf=
2_core snd_hda_core videodev intel_rapl x86_pkg_temp_thermal intel_powerc=
lamp snd_hwdep snd_pcm coretemp media kvm_intel kvm snd_seq_midi snd_seq_=
midi_event snd_rawmidi drm_kms_helper snd_seq snd_seq_device snd_timer ir=
qbypass sparse_keymap crct10dif_pclmul drm crc32_pclmul ghash_clmulni_int=
el snd aesni_intel mei_me mei aes_x86_64 lrw i2c_algo_bit fb_sys_fops gf1=
28mul rtsx_pci_ms syscopyarea glue_helper sysfillrect ablk_helper soundco=
re memstick sysimgblt dm_multipath lpc_ich cryptd joydev serio_raw shpchp=
 dell_smo8800 wmi mac_hid video parport_pc ppdev lp parport rtsx_pci_sdmm=
c psmouse r8169 ahci rtsx_pci libahci mii
CPU: 1 PID: 199 Comm: kworker/u16:9 Tainted: G        W       4.7.0-rc1-n=
ext-20160530+ #5
Hardware name: Acer TravelMate P243/BA40_HC, BIOS V1.01 04/20/2012
Workqueue: events_power_efficient rfkill_poll
 0000000000000000 ffff88002cf73d28 ffffffff813b8ddc 0000000000000000
 0000000000000000 ffff88002cf73d68 ffffffff8107a331 00000aee00000086
 ffff880148d9c018 000000000000000b ffff880147e68720 0000000000000200
Call Trace:
 [<ffffffff813b8ddc>] dump_stack+0x63/0x87
 [<ffffffff8107a331>] __warn+0xd1/0xf0
 [<ffffffff8107a41d>] warn_slowpath_null+0x1d/0x20
 [<ffffffffc0775a30>] ath9k_hw_gpio_get+0xc0/0x1b0 [ath9k_hw]
 [<ffffffffc047f3e4>] ath9k_rfkill_poll_state+0x34/0x60 [ath9k]
 [<ffffffffc06dbb53>] ieee80211_rfkill_poll+0x33/0x40 [mac80211]
 [<ffffffffc03ad65a>] cfg80211_rfkill_poll+0x2a/0xc0 [cfg80211]
 [<ffffffff817c5514>] rfkill_poll+0x24/0x50
 [<ffffffff81093183>] process_one_work+0x153/0x3f0
 [<ffffffff8109393b>] worker_thread+0x12b/0x4b0
 [<ffffffff81093810>] ? rescuer_thread+0x340/0x340
 [<ffffffff81099129>] kthread+0xc9/0xe0
 [<ffffffff817d8f1f>] ret_from_fork+0x1f/0x40
 [<ffffffff81099060>] ? kthread_park+0x60/0x60
---[ end trace 05d4a9560035df67 ]---
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill
sudip: 11 ath9k-rfkill

--------------090008070508080508040606--
