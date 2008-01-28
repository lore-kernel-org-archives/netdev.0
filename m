From: Tony Battersby <tonyb@cybernetics.com>
Subject: Re: sky2: tx hang on dual-port Yukon XL when rx csum disabled
Date: Mon, 28 Jan 2008 15:58:08 -0500
Message-ID: <479E41E0.1030409@cybernetics.com>
References: <479E2247.8080109@cybernetics.com> <20080128124339.4d013d71@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.cybernetics.com ([70.169.137.4]:3401 "EHLO
	mail.cybernetics.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbYA1U6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 15:58:09 -0500
In-Reply-To: <20080128124339.4d013d71@deepthought>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> What bus and chipset is in use on the systems with sky2?
> I have seen problems when using PCI-X on AMD systems (documented in AMD errata)
> due to multiple outstanding transactions.

Motherboard: SuperMicro PDSME
Chipset: Intel E7230
Processor: Intel Pentium D 3.4 GHz
(note: tried both SMP and booting with maxcpus=1)

lspci:

00:00.0 Host bridge: Intel Corporation E7230/3000/3010 Memory Controller Hub (rev 81)
00:01.0 PCI bridge: Intel Corporation E7230/3000/3010 PCI Express Root Port (rev 81)
00:1c.0 PCI bridge: Intel Corporation 82801G (ICH7 Family) PCI Express Port 1 (rev 01)
00:1c.4 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express Port 5 (rev 01)
00:1c.5 PCI bridge: Intel Corporation 82801GR/GH/GHM (ICH7 Family) PCI Express Port 6 (rev 01)
00:1d.0 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #1 (rev 01)
00:1d.1 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #2 (rev 01)
00:1d.2 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #3 (rev 01)
00:1d.3 USB Controller: Intel Corporation 82801G (ICH7 Family) USB UHCI Controller #4 (rev 01)
00:1d.7 USB Controller: Intel Corporation 82801G (ICH7 Family) USB2 EHCI Controller (rev 01)
00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev e1)
00:1f.0 ISA bridge: Intel Corporation 82801GB/GR (ICH7 Family) LPC Interface Bridge (rev 01)
00:1f.1 IDE interface: Intel Corporation 82801G (ICH7 Family) IDE Controller (rev 01)
00:1f.3 SMBus: Intel Corporation 82801G (ICH7 Family) SMBus Controller (rev 01)
01:00.0 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge A (rev 09)
01:00.1 PIC: Intel Corporation 6700/6702PXH I/OxAPIC Interrupt Controller A (rev 09)
01:00.2 PCI bridge: Intel Corporation 6700PXH PCI Express-to-PCI Bridge B (rev 09)
01:00.3 PIC: Intel Corporation 6700PXH I/OxAPIC Interrupt Controller B (rev 09)
04:00.0 Ethernet controller: SysKonnect SK-9E21D 10/100/1000Base-T Adapter, Copper RJ-45 (rev 14)
05:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet Controller (Copper) (rev 03)
06:00.0 Ethernet controller: Intel Corporation 82573E Gigabit Ethernet Controller (Copper) (rev 03)
0a:04.0 VGA compatible controller: ATI Technologies Inc Rage XL (rev 27)

cat /proc/cpuinfo:

processor: 0
vendor_id: GenuineIntel
cpu family: 15
model: 6
model name: Intel(R) Pentium(R) D CPU 3.40GHz
stepping: 4
cpu MHz: 3391.734
cache size: 2048 KB
physical id: 0
siblings: 2
core id: 0
cpu cores: 2
fdiv_bug: no
hlt_bug: no
f00f_bug: no
coma_bug: no
fpu: yes
fpu_exception: yes
cpuid level: 6
wp: yes
flags: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm constant_tsc pebs bts sync_rdtsc pni monitor ds_cpl est cid cx16 xtpr lahf_lm
bogomips: 6789.26
clflush size: 64

processor: 1
vendor_id: GenuineIntel
cpu family: 15
model: 6
model name: Intel(R) Pentium(R) D CPU 3.40GHz
stepping: 4
cpu MHz: 3391.734
cache size: 2048 KB
physical id: 0
siblings: 2
core id: 1
cpu cores: 2
fdiv_bug: no
hlt_bug: no
f00f_bug: no
coma_bug: no
fpu: yes
fpu_exception: yes
cpuid level: 6
wp: yes
flags: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe nx lm constant_tsc pebs bts sync_rdtsc pni monitor ds_cpl est cid cx16 xtpr lahf_lm
bogomips: 6783.57
clflush size: 64

cat /proc/interrupts

CPU0 CPU1
0: 86 0 IO-APIC-edge timer
1: 81 0 IO-APIC-edge i8042
7: 0 0 IO-APIC-edge parport0
8: 1 0 IO-APIC-edge rtc
9: 0 0 IO-APIC-fasteoi acpi
12: 5 0 IO-APIC-edge i8042
14: 412 0 IO-APIC-edge ide0
16: 0 0 IO-APIC-fasteoi uhci_hcd:usb5
18: 0 0 IO-APIC-fasteoi uhci_hcd:usb4
19: 31 0 IO-APIC-fasteoi ehci_hcd:usb1, uhci_hcd:usb2
20: 0 0 IO-APIC-fasteoi uhci_hcd:usb3
219: 1 0 PCI-MSI-edge eth0
NMI: 0 0 Non-maskable interrupts
LOC: 1924 514 Local timer interrupts
RES: 16 20 Rescheduling interrupts
CAL: 19 56 function call interrupts
TLB: 21 41 TLB shootdowns
TRM: 0 0 Thermal event interrupts
SPU: 0 0 Spurious interrupts
ERR: 0
MIS: 0

(note: tried booting with pci=nomsi also)

Tony

