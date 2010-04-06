From: Xianghua Xiao <xiaoxianghua@gmail.com>
Subject: Re: Increased Latencies when upgrading kernel version
Date: Tue, 6 Apr 2010 09:10:21 -0500
Message-ID: <h2re6bf505b1004060710qee2de604qdbbb4b94380c2a48@mail.gmail.com>
References: <o2vd585dc4f1004011212s65cc2beewed2f19321210a249@mail.gmail.com>
	 <1270156741.2192.14.camel@edumazet-laptop>
	 <r2pd585dc4f1004011853q405eaadcq14b50a9e7a4dcf21@mail.gmail.com>
	 <m2jd585dc4f1004051034ka36301d6xdce95defe6388836@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Taylor Lewick <taylor.lewick@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:38024 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751269Ab0DFOKX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 10:10:23 -0400
In-Reply-To: <m2jd585dc4f1004051034ka36301d6xdce95defe6388836@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 5, 2010 at 12:34 PM, Taylor Lewick <taylor.lewick@gmail.com=
> wrote:
> Okay, don't know what to officially file this under, as a regression
> with regards to performance or what, but here is the data. =C2=A0Agai=
n,
> I've noticed system and network latency appear to have worsened with
> later kernel versions.
>
> I was turned onto this problem via the following links:
> http://www.kernel.org/pub/linux/kernel/people/christoph/ols2009/ols-2=
009-paper.pdf
> and http://kerneltrap.org/mailarchive/linux-netdev/2009/4/16/5491284
>
> So I set up a test on two servers with Identical hardware, servers,
> nics, etc, and used hackbench, udpping, and an internally written app
> to compare latency.
>
> Here are just the hackbench results with just the averages across a 5
> runs for two different hackbench tests. =C2=A0The 2.6.16 and 2.6.27 k=
ernels
> as set up were configured with voluntary preemption, and 250 HZ, so I
> just repeated that initially for 2.6.33.1 test. =C2=A0I also tested n=
o
> preemption at same HZ setting of 250.
>
> I ran 2.6.16.60 on one server, and the other kernel versions on
> another server. =C2=A0These tests are repeatable across different ser=
vers,
> as in I verified I
> don't have a bad server.
>
> Kernel Version =C2=A0 =C2=A0 =C2=A0 =C2=A0 HB1 (25 process 300) =C2=A0=
 =C2=A0HB2 (100 process 300)
> 2.6.16.60 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .54=
02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 1.8946
> 2.6.27.19 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 .61=
9 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2.6268
> 2.6.32.3-voluntary =C2=A0 =C2=A0 .5636 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2.3484
> 2.6.33.1-voluntary =C2=A0 =C2=A0 .5404 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2.2872
> 2.6.33.1-nopreempt =C2=A0 .5606 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 2.3466
>
> So 2.6.16.60 is fast, 2.6.27.19 is slow, and 2.6.33.1 with voluntary
> preemption is the next best, but results didn't hold up well as
> Hackbench tests used larger numbers of groups., for example, 2.6.16.6=
0
> and 2.6.33.1-voluntary were basically the same for HB1, but that
> didn't hold when hackebnch tests used more groups.
>
> At this point, I'm looking for ideas in kernel build to tweak, but I'=
m
> not a developer. =C2=A0So SLAB vs SLUB, sparse vs dense IRQ numbering=
, etc.
> Running a -rt kernel isn't an option at this time. =C2=A0I did test t=
hat as
> well, and latencies were quite a bit worse, but I wasn't adjusting
> code to take advantage of a real time OS.
>
> I can make some changes or repeat tests.
>
> Below is some hardware comparisons betweent the two machines.
> Differences I noticed was more interrupts and CPU flags on later
> kernel version.
>
> HostA 2.6.16.60
> cat /proc/interrupts
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 CPU0 =C2=A0 =C2=A0 =C2=A0 CPU1 =C2=A0 =C2=
=A0 =C2=A0 CPU2 =C2=A0 =C2=A0 =C2=A0 CPU3 =C2=A0 =C2=A0 =C2=A0 CPU4 =C2=
=A0 =C2=A0 =C2=A0 CPU5
> =C2=A0 =C2=A0CPU6 =C2=A0 =C2=A0 =C2=A0 CPU7
> =C2=A00: =C2=A0108509762 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0IO-APIC-edge =C2=A0timer
> =C2=A08: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0IO-APIC-edge =C2=A0rtc
> =C2=A09: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 IO-APIC-level =C2=A0acpi
> =C2=A058: =C2=A0 =C2=A0 =C2=A0 =C2=A0305 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A05157735 =C2=A0 =C2=A0 =C2=A0 =C2=A0220 =C2=A0 =C2=A0=
2980100 =C2=A0 =C2=A0 =C2=A0 5927
> =C2=A0 =C2=A0 =C2=A01187 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 I=
O-APIC-level =C2=A0libata
> 162: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 IO-APIC-level =C2=A0uhci_hcd:usb1
> 170: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 IO-APIC-level =C2=A0uhci_hcd:usb2
> 177: =C2=A0 =C2=A0 =C2=A0 6326 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 229018 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 283=
720 =C2=A0 =C2=A0 =C2=A035597
> =C2=A0 =C2=A0 =C2=A0 367 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 I=
O-APIC-level =C2=A0megasas
> 178: =C2=A0 =C2=A0 =C2=A0 =C2=A0122 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
0 =C2=A0 =C2=A0 =C2=A0 1784 =C2=A0 =C2=A0 =C2=A0 1103 =C2=A0 =C2=A0 =C2=
=A0 3531 =C2=A0 =C2=A0 =C2=A0 =C2=A0 20
> =C2=A0 =C2=A0 =C2=A01457 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 I=
O-APIC-level =C2=A0uhci_hcd:usb3, ehci_hcd:usb6
> 186: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 IO-APIC-level =C2=A0uhci_hcd:usb4
> 194: =C2=A0 =C2=A0 =C2=A0 =C2=A0 22 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
0
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 IO-APIC-level =C2=A0ehci_hcd:usb5
> 210: =C2=A0 =C2=A01790109 =C2=A0 =C2=A0 =C2=A0 =C2=A0577 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 =C2=A0 PCI-MSI-X =C2=A0eth4-0
> 218: =C2=A0 =C2=A0 233811 =C2=A0 =C2=A0 =C2=A0 =C2=A0 93 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 =C2=A0 PCI-MSI-X =C2=A0eth4-1
> NMI: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> LOC: =C2=A0108509683 =C2=A0108509662 =C2=A0108509637 =C2=A0108509614 =
=C2=A0108509588 =C2=A0108509566
> =C2=A0108509541 =C2=A0108509516
> ERR: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A07
> MIS: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>
> lspci
> 00:00.0 Host bridge: Intel Corporation QuickPath Architecture I/O Hub
> to ESI Port (rev 13)
> 00:01.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub
> PCI Express Root Port 1 (rev 13)
> 00:03.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub
> PCI Express Root Port 3 (rev 13)
> 00:07.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub
> PCI Express Root Port 7 (rev 13)
> 00:09.0 PCI bridge: Intel Corporation QuickPath Architecture I/O Hub
> PCI Express Root Port 9 (rev 13)
> 00:14.0 PIC: Intel Corporation QuickPath Architecture I/O Hub System
> Management Registers (rev 13)
> 00:14.1 PIC: Intel Corporation QuickPath Architecture I/O Hub GPIO an=
d
> Scratch Pad Registers (rev 13)
> 00:14.2 PIC: Intel Corporation QuickPath Architecture I/O Hub Control
> Status and RAS Registers (rev 13)
> 00:16.0 System peripheral: Intel Corporation DMA Engine (rev 13)
> 00:16.1 System peripheral: Intel Corporation DMA Engine (rev 13)
> 00:16.2 System peripheral: Intel Corporation DMA Engine (rev 13)
> 00:16.3 System peripheral: Intel Corporation DMA Engine (rev 13)
> 00:16.4 System peripheral: Intel Corporation DMA Engine (rev 13)
> 00:16.5 System peripheral: Intel Corporation DMA Engine (rev 13)
> 00:16.6 System peripheral: Intel Corporation DMA Engine (rev 13)
> 00:16.7 System peripheral: Intel Corporation DMA Engine (rev 13)
> 00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
> UHCI Controller #4 (rev 02)
> 00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
> UHCI Controller #5 (rev 02)
> 00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2
> EHCI Controller #2 (rev 02)
> 00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Expres=
s
> Port 1 (rev 02)
> 00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
> UHCI Controller #1 (rev 02)
> 00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
> UHCI Controller #2 (rev 02)
> 00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2
> EHCI Controller #1 (rev 02)
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
> 00:1f.0 ISA bridge: Intel Corporation 82801IB (ICH9) LPC Interface
> Controller (rev 02)
> 00:1f.2 IDE interface: Intel Corporation 82801IB (ICH9) 2 port SATA
> IDE Controller (rev 02)
> 03:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS
> 1078 (rev 04)
> 04:00.0 PCI bridge: Integrated Device Technology, Inc. Unknown device
> 8018 (rev 0e)
> 05:02.0 PCI bridge: Integrated Device Technology, Inc. Unknown device
> 8018 (rev 0e)
> 05:04.0 PCI bridge: Integrated Device Technology, Inc. Unknown device
> 8018 (rev 0e)
> 06:00.0 Ethernet controller: Intel Corporation 82575GB Gigabit Networ=
k
> Connection (rev 02)
> 06:00.1 Ethernet controller: Intel Corporation 82575GB Gigabit Networ=
k
> Connection (rev 02)
> 07:00.0 Ethernet controller: Intel Corporation 82575GB Gigabit Networ=
k
> Connection (rev 02)
> 07:00.1 Ethernet controller: Intel Corporation 82575GB Gigabit Networ=
k
> Connection (rev 02)
> 08:00.0 Ethernet controller: Solarflare Communications Unknown device
> 0710 (rev 02)
> 09:03.0 VGA compatible controller: Matrox Graphics, Inc. Unknown
> device 0532 (rev 0a)
>
> cat /proc/cpuinfo (just showing first CPU for brevity)
> processor =C2=A0 =C2=A0 =C2=A0 : 0
> vendor_id =C2=A0 =C2=A0 =C2=A0 : GenuineIntel
> cpu family =C2=A0 =C2=A0 =C2=A0: 6
> model =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 26
> model name =C2=A0 =C2=A0 =C2=A0: Intel(R) Xeon(R) CPU =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 X5570 =C2=A0@ 2.93GHz
> stepping =C2=A0 =C2=A0 =C2=A0 =C2=A0: 5
> cpu MHz =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2926.090
> cache size =C2=A0 =C2=A0 =C2=A0: 8192 KB
> physical id =C2=A0 =C2=A0 : 1
> siblings =C2=A0 =C2=A0 =C2=A0 =C2=A0: 4
> core id =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> cpu cores =C2=A0 =C2=A0 =C2=A0 : 4
> fpu =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : yes
> fpu_exception =C2=A0 : yes
> cpuid level =C2=A0 =C2=A0 : 11
> wp =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: yes
> flags =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : fpu vme de pse tsc msr pae=
 mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm syscal=
l
> nx rdtscp lm constant_tsc pni monitor d
> s_cpl vmx est tm2 cx16 xtpr dca popcnt lahf_lm
> bogomips =C2=A0 =C2=A0 =C2=A0 =C2=A0: 5857.34
> clflush size =C2=A0 =C2=A0: 64
> cache_alignment : 64
> address sizes =C2=A0 : 40 bits physical, 48 bits virtual
> power management:
>
> ethtool -c eth4
> Coalesce parameters for eth4:
> Adaptive RX: on =C2=A0TX: off
> stats-block-usecs: 0
> sample-interval: 0
> pkt-rate-low: 0
> pkt-rate-high: 0
>
> rx-usecs: 0
> rx-frames: 0
> rx-usecs-irq: 60
> rx-frames-irq: 0
>
> tx-usecs: 0
> tx-frames: 0
> tx-usecs-irq: 0
> tx-frames-irq: 0
>
> rx-usecs-low: 0
> rx-frame-low: 0
> tx-usecs-low: 0
> tx-frame-low: 0
>
> rx-usecs-high: 0
> rx-frame-high: 0
> tx-usecs-high: 0
> tx-frame-high: 0
>
>
> HostB 2.6.33.1
> =C2=A0 =C2=A0CPU0 =C2=A0 =C2=A0 =C2=A0 CPU1 =C2=A0 =C2=A0 =C2=A0 CPU2=
 =C2=A0 =C2=A0 =C2=A0 CPU3 =C2=A0 =C2=A0 =C2=A0 CPU4 =C2=A0 =C2=A0 =C2=A0=
 CPU5
> CPU6 =C2=A0 =C2=A0 =C2=A0 CPU7
> =C2=A0 0: =C2=A0 =C2=A0 =C2=A0 8637 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-edge =C2=A0 =C2=A0 =C2=A0timer
> =C2=A0 1: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-edge =C2=A0 =C2=A0 =C2=A0i8042
> =C2=A0 3: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-edge
> =C2=A0 4: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-edge
> =C2=A0 8: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A01 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-edge =C2=A0 =C2=A0 =C2=A0rtc0
> =C2=A0 9: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-fasteoi =C2=A0 acpi
> =C2=A012: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A04 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-edge =C2=A0 =C2=A0 =C2=A0i8042
> =C2=A016: =C2=A0 =C2=A0 =C2=A0 7434 =C2=A0 =C2=A0 =C2=A0 =C2=A0683 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-fasteoi =C2=A0 megasas
> =C2=A017: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-fasteoi =C2=A0 uhci_hcd:usb3
> =C2=A018: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-fasteoi =C2=A0 uhci_hcd:usb4
> =C2=A019: =C2=A0 =C2=A0 =C2=A0 =C2=A0 23 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-fasteoi =C2=A0 ehci_hcd:usb1
> =C2=A020: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-fasteoi =C2=A0 uhci_hcd:usb6
> =C2=A021: =C2=A0 =C2=A0 =C2=A0 =C2=A0129 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 15 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-fasteoi =C2=A0 ehci_hcd:usb2,
> uhci_hcd:usb5
> =C2=A023: =C2=A0 =C2=A0 =C2=A0 =C2=A0369 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 IO-APIC-fasteoi =C2=A0 ata_piix
> =C2=A067: =C2=A0 =C2=A0 =C2=A0 2346 =C2=A0 =C2=A0 =C2=A0 =C2=A0731 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 PCI-MSI-edge =C2=A0 =C2=A0 =C2=A0eth4-0
> =C2=A068: =C2=A0 =C2=A0 =C2=A0 1809 =C2=A0 =C2=A0 =C2=A0 =C2=A0404 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 PCI-MSI-edge =C2=A0 =C2=A0 =C2=A0eth4-1
> =C2=A0NMI: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 Non-maskable interrupts
> =C2=A0LOC: =C2=A0 =C2=A0 =C2=A033071 =C2=A0 =C2=A0 =C2=A038348 =C2=A0=
 =C2=A0 =C2=A047397 =C2=A0 =C2=A0 =C2=A023246 =C2=A0 =C2=A0 =C2=A015715
> 11065 =C2=A0 =C2=A0 =C2=A0 9004 =C2=A0 =C2=A0 =C2=A010391 =C2=A0 Loca=
l timer interrupts
> =C2=A0SPU: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 Spurious interrupts
> =C2=A0PMI: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 Performance monitoring interrupts
> =C2=A0PND: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 Performance pending work
> =C2=A0RES: =C2=A0 =C2=A0 =C2=A0 2490 =C2=A0 =C2=A0 =C2=A0 2124 =C2=A0=
 =C2=A0 =C2=A0 4187 =C2=A0 =C2=A0 =C2=A0 4974 =C2=A0 =C2=A0 =C2=A0 1724
> 5548 =C2=A0 =C2=A0 =C2=A0 1892 =C2=A0 =C2=A0 =C2=A0 2871 =C2=A0 Resch=
eduling interrupts
> =C2=A0CAL: =C2=A0 =C2=A0 =C2=A0 =C2=A0497 =C2=A0 =C2=A0 =C2=A0 2166 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0141 =C2=A0 =C2=A0 =C2=A0 =C2=A0115 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0133
> 144 =C2=A0 =C2=A0 =C2=A0 =C2=A0140 =C2=A0 =C2=A0 =C2=A0 =C2=A0144 =C2=
=A0 Function call interrupts
> =C2=A0TLB: =C2=A0 =C2=A0 =C2=A0 =C2=A0243 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
244 =C2=A0 =C2=A0 =C2=A0 =C2=A0928 =C2=A0 =C2=A0 =C2=A0 =C2=A0945 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0289
> 187 =C2=A0 =C2=A0 =C2=A0 =C2=A0134 =C2=A0 =C2=A0 =C2=A0 =C2=A0 93 =C2=
=A0 TLB shootdowns
> =C2=A0TRM: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 Thermal event interrupts
> =C2=A0THR: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 Threshold APIC interrupts
> =C2=A0MCE: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
> 0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A00 =C2=A0 Machine check exceptions
> =C2=A0MCP: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02
> 2 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A02 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A02 =C2=A0 Machine check polls
> =C2=A0ERR: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A07
> =C2=A0MIS: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A00
>
> lspci
> 00:00.0 Host bridge: Intel Corporation X58 I/O Hub to ESI Port (rev 1=
3)
> 00:01.0 PCI bridge: Intel Corporation X58 I/O Hub PCI Express Root
> Port 1 (rev 13)
> 00:03.0 PCI bridge: Intel Corporation X58 I/O Hub PCI Express Root
> Port 3 (rev 13)
> 00:07.0 PCI bridge: Intel Corporation X58 I/O Hub PCI Express Root
> Port 7 (rev 13)
> 00:09.0 PCI bridge: Intel Corporation X58 I/O Hub PCI Express Root
> Port 9 (rev 13)
> 00:14.0 PIC: Intel Corporation X58 I/O Hub System Management Register=
s (rev 13)
> 00:14.1 PIC: Intel Corporation X58 I/O Hub GPIO and Scratch Pad
> Registers (rev 13)
> 00:14.2 PIC: Intel Corporation X58 I/O Hub Control Status and RAS
> Registers (rev 13)
> 00:1a.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
> UHCI Controller #4 (rev 02)
> 00:1a.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
> UHCI Controller #5 (rev 02)
> 00:1a.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2
> EHCI Controller #2 (rev 02)
> 00:1c.0 PCI bridge: Intel Corporation 82801I (ICH9 Family) PCI Expres=
s
> Port 1 (rev 02)
> 00:1d.0 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
> UHCI Controller #1 (rev 02)
> 00:1d.1 USB Controller: Intel Corporation 82801I (ICH9 Family) USB
> UHCI Controller #2 (rev 02)
> 00:1d.7 USB Controller: Intel Corporation 82801I (ICH9 Family) USB2
> EHCI Controller #1 (rev 02)
> 00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 92)
> 00:1f.0 ISA bridge: Intel Corporation 82801IB (ICH9) LPC Interface
> Controller (rev 02)
> 00:1f.2 IDE interface: Intel Corporation 82801IB (ICH9) 2 port SATA
> IDE Controller (rev 02)
> 03:00.0 RAID bus controller: LSI Logic / Symbios Logic MegaRAID SAS
> 1078 (rev 04)
> 04:00.0 PCI bridge: Integrated Device Technology, Inc. PES12N3A PCI
> Express Switch (rev 0e)
> 05:02.0 PCI bridge: Integrated Device Technology, Inc. PES12N3A PCI
> Express Switch (rev 0e)
> 05:04.0 PCI bridge: Integrated Device Technology, Inc. PES12N3A PCI
> Express Switch (rev 0e)
> 06:00.0 Ethernet controller: Intel Corporation 82575GB Gigabit Networ=
k
> Connection (rev 02)
> 06:00.1 Ethernet controller: Intel Corporation 82575GB Gigabit Networ=
k
> Connection (rev 02)
> 07:00.0 Ethernet controller: Intel Corporation 82575GB Gigabit Networ=
k
> Connection (rev 02)
> 07:00.1 Ethernet controller: Intel Corporation 82575GB Gigabit Networ=
k
> Connection (rev 02)
> 08:00.0 Ethernet controller: Solarflare Communications SFC4000 rev B
> [Solarstorm] (rev 02)
> 09:03.0 VGA compatible controller: Matrox Graphics, Inc. MGA G200eW
> WPCM450 (rev 0a)
>
> cat /proc/cpuinfo (just showing first CPU for brevity)
> processor =C2=A0 =C2=A0 =C2=A0 : 0
> vendor_id =C2=A0 =C2=A0 =C2=A0 : GenuineIntel
> cpu family =C2=A0 =C2=A0 =C2=A0: 6
> model =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 26
> model name =C2=A0 =C2=A0 =C2=A0: Intel(R) Xeon(R) CPU =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 X5570 =C2=A0@ 2.93GHz
> stepping =C2=A0 =C2=A0 =C2=A0 =C2=A0: 5
> cpu MHz =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 2925.888
> cache size =C2=A0 =C2=A0 =C2=A0: 8192 KB
> physical id =C2=A0 =C2=A0 : 1
> siblings =C2=A0 =C2=A0 =C2=A0 =C2=A0: 4
> core id =C2=A0 =C2=A0 =C2=A0 =C2=A0 : 0
> cpu cores =C2=A0 =C2=A0 =C2=A0 : 4
> apicid =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 16
> initial apicid =C2=A0: 16
> fpu =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : yes
> fpu_exception =C2=A0 : yes
> cpuid level =C2=A0 =C2=A0 : 11
> wp =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: yes
> flags =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 : fpu vme de pse tsc msr pae=
 mce cx8 apic sep mtrr pge
> mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe
> syscall nx rdtscp lm constant_tsc arch_perfmon pebs bt
> s rep_good xtopology nonstop_tsc aperfmperf pni dtes64 monitor ds_cpl
> vmx est tm2 ssse3 cx16 xtpr pdcm dca sse4_1 sse4_2 popcnt lahf_lm ida
> tpr_shadow vnmi flexpriority ept vpid
> bogomips =C2=A0 =C2=A0 =C2=A0 =C2=A0: 5851.77
> clflush size =C2=A0 =C2=A0: 64
> cache_alignment : 64
> address sizes =C2=A0 : 40 bits physical, 48 bits virtual
> power management:
>
> ethtool -c eth4
> Coalesce parameters for eth4:
> Adaptive RX: on =C2=A0TX: off
> stats-block-usecs: 0
> sample-interval: 0
> pkt-rate-low: 0
> pkt-rate-high: 0
>
> rx-usecs: 0
> rx-frames: 0
> rx-usecs-irq: 60
> rx-frames-irq: 0
>
> tx-usecs: 0
> tx-frames: 0
> tx-usecs-irq: 0
> tx-frames-irq: 0
>
> rx-usecs-low: 0
> rx-frame-low: 0
> tx-usecs-low: 0
> tx-frame-low: 0
>
> rx-usecs-high: 0
> rx-frame-high: 0
> tx-usecs-high: 0
> tx-frame-high: 0
>
>
>
> On Thu, Apr 1, 2010 at 8:53 PM, Taylor Lewick <taylor.lewick@gmail.co=
m> wrote:
>> Okay. =C2=A0I will get this info out to the list Monday. =C2=A0Brief=
ly, I'm
>> using identical hardware (server), identical NICs, same drivers,
>> connected to same switch, and using udpping, hackbench, and an
>> internall written app to test latency. =C2=A0Without exception the
>> evolution has looked like the following.
>>
>> 2.6.16.60 latencies for system and network are fast. =C2=A0Meaning
>> hackbench and udpping win, and win by quite a bit.
>>
>> 2.6.27.19 was awful. =C2=A02.6.32.1 and 2.6.331. were better for net=
working
>> (with some tweaks, i.e. disable netfilter, etc), and I was able to g=
et
>> networking latencies to within 1-3 microseconds of 2.6.16.60
>> latencies, but the hackbench results are still pretty bad.
>>
>> Again, I'll post numbers and more detailed hardware info on Monday
>> when I'm back at office...
>>
>> On Thu, Apr 1, 2010 at 4:19 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>>> Le jeudi 01 avril 2010 =C3=A0 14:12 -0500, Taylor Lewick a =C3=A9cr=
it :
>>>> For some time now we've been running an older kernel, 2.6.16.60. =C2=
=A0When
>>>> we tried to upgrade, first going to 2.6.27.19 and then to 2.6.32.1=
 and
>>>> 2.6.33.1 we noticed that latencies increased. =C2=A0At first we no=
ticed it
>>>> by doing network tests via udpping, netperf, etc. =C2=A0We made so=
me
>>>> tweaks, and were able to get network latency to within 1 to 2
>>>> microseconds of where we were previously on 2.6.16.60. =C2=A0Then =
we did
>>>> some more testing, and noticed that system latency also seems high=
er.
>>>>
>>>> We've done our tests on identical hardware servers, same NICs,
>>>> connected through same network gear. =C2=A0Basically, we've tried =
to keep
>>>> everything identical except the kernel versions, and we are unable=
 to
>>>> achieve the same performance for system latency on the newer kerne=
ls,
>>>> despite adjusting various kernel settings and recompiling.
>>>>
>>>> The latency differences are about 15 microseconds per transaction.
>>>>
>>>> At this point, I don't know what else to try. =C2=A0I haven't play=
ed around
>>>> with the /proc/sys/kernel/sched_* paramaters under the newer kerne=
ls
>>>> yet. =C2=A0Have tried changing pre-emption modes with little effec=
t, in
>>>> fact, voluntary preemption seems to be peforming the best for us.
>>>>
>>>> At this time the realtime patch isn't really an option for us to
>>>> consider, at least not yet.
>>>>
>>>> Any suggestions? =C2=A0Is this a known issue when upgrading to mor=
e recent
>>>> kernel versions?
>>>>
>>>
>>> Hi Taylor
>>>
>>> Well, this is bit difficult to generically answer to your generic
>>> question. 15 us more latency per transaction seems pretty bad.
>>>
>>> Some inputs would be nice, describing your workload and
>>> software/hardware architecture.
>>>
>>> lspci
>>> cat /proc/cpuinfo
>>> cat /proc/interrupts
>>> dmesg
>>> ethtool -S eth0
>>> ethtool -c eth0
>>>
>>>
>>>
>>>
>>
>
Just want to ack you here, I upgraded a 2.6.18 kernel to 2.6.33.1 on a
shipping product and the performance(hackbench, latency, cpu
usage,etc) is a lot worse on the same hardware platform. We tried
2.6.27 before and it's also bad. I'm tring various CONFIG options and
so far nothing really helped. I'm using the RT patch.
Xianghua
