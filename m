From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- experimental revert for 2.6.27 failed
Date: Tue, 12 Aug 2008 18:17:15 -0700 (PDT)
Message-ID: <305173.54014.qm@web82101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82101.mail.mud.yahoo.com ([209.191.84.214]:33307 "HELO
	web82101.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753030AbYHMBRP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2008 21:17:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> can you post /proc/iomem?

Gladly.

I wasn't sure which kernel you would like me to use, so I chose a 
sample of 3:

1.  linux-2.6.25 (from git) just before the commit causing the lockups
2.  linux-2.6.26 (with "hpet=disabled")
3.  Debian stock 2.6.26 ("linux-image-2.6.26-1-amd64", also with HPET
disabled)


Using 2.6.25 at the commit before the one that caused lockups:

$ cat /proc/iomem
00000000-0009f3ff : System RAM
0009f400-0009ffff : reserved
000f0000-000fffff : reserved
00100000-77fdffff : System RAM
  00200000-0056ca21 : Kernel code
  0056ca22-006ce3d7 : Kernel data
  00753000-0079a3c7 : Kernel bss
77fe0000-77fe2fff : ACPI Non-volatile Storage
77fe3000-77feffff : ACPI Tables
77ff0000-77ffffff : reserved
78000000-7fffffff : pnp 00:0d
d8000000-dfffffff : PCI Bus #01
  d8000000-dfffffff : 0000:01:05.0
    d8000000-d8ffffff : uvesafb
e0000000-efffffff : PCI MMCONFIG 0
  e0000000-efffffff : reserved
fdc00000-fdcfffff : PCI Bus #02
  fdcff000-fdcff0ff : 0000:02:05.0
    fdcff000-fdcff0ff : r8169
fdd00000-fdefffff : PCI Bus #01
  fdd00000-fddfffff : 0000:01:05.0
  fdee0000-fdeeffff : 0000:01:05.0
  fdefc000-fdefffff : 0000:01:05.2
    fdefc000-fdefffff : ICH HD audio
fdf00000-fdffffff : PCI Bus #02
fe020000-fe023fff : 0000:00:14.2
  fe020000-fe023fff : ICH HD audio
fe029000-fe0290ff : 0000:00:13.5
  fe029000-fe0290ff : ehci_hcd
fe02a000-fe02afff : 0000:00:13.4
  fe02a000-fe02afff : ohci_hcd
fe02b000-fe02bfff : 0000:00:13.3
  fe02b000-fe02bfff : ohci_hcd
fe02c000-fe02cfff : 0000:00:13.2
  fe02c000-fe02cfff : ohci_hcd
fe02d000-fe02dfff : 0000:00:13.1
  fe02d000-fe02dfff : ohci_hcd
fe02e000-fe02efff : 0000:00:13.0
  fe02e000-fe02efff : ohci_hcd
fe02f000-fe02f3ff : 0000:00:12.0
  fe02f000-fe02f3ff : ahci
fec00000-fec00fff : IOAPIC 0
  fec00000-fec00fff : pnp 00:0d
fed00000-fed003ff : HPET 0
  fed00000-fed003ff : 0000:00:14.0
fee00000-fee00fff : Local APIC
fff80000-fffeffff : pnp 00:0d
ffff0000-ffffffff : pnp 00:0d


Using 2.6.26 (custom compiled) with "hpet=disabled"

00000000-0009f3ff : System RAM
0009f400-0009ffff : reserved
000f0000-000fffff : reserved
00100000-77fdffff : System RAM
  00200000-0057358d : Kernel code
  0057358e-006d8e9f : Kernel data
  0076e000-007b7447 : Kernel bss
77fe0000-77fe2fff : ACPI Non-volatile Storage
77fe3000-77feffff : ACPI Tables
77ff0000-77ffffff : reserved
78000000-7fffffff : pnp 00:0d
80000000-800003ff : 0000:00:14.0
d8000000-dfffffff : PCI Bus 0000:01
  d8000000-dfffffff : 0000:01:05.0
    d8000000-d8ffffff : uvesafb
e0000000-efffffff : PCI MMCONFIG 0
  e0000000-efffffff : reserved
fdc00000-fdcfffff : PCI Bus 0000:02
  fdcff000-fdcff0ff : 0000:02:05.0
    fdcff000-fdcff0ff : r8169
fdd00000-fdefffff : PCI Bus 0000:01
  fdd00000-fddfffff : 0000:01:05.0
  fdee0000-fdeeffff : 0000:01:05.0
  fdefc000-fdefffff : 0000:01:05.2
    fdefc000-fdefffff : ICH HD audio
fdf00000-fdffffff : PCI Bus 0000:02
  fdf00000-fdf1ffff : 0000:02:05.0
fe020000-fe023fff : 0000:00:14.2
  fe020000-fe023fff : ICH HD audio
fe029000-fe0290ff : 0000:00:13.5
  fe029000-fe0290ff : ehci_hcd
fe02a000-fe02afff : 0000:00:13.4
  fe02a000-fe02afff : ohci_hcd
fe02b000-fe02bfff : 0000:00:13.3
  fe02b000-fe02bfff : ohci_hcd
fe02c000-fe02cfff : 0000:00:13.2
  fe02c000-fe02cfff : ohci_hcd
fe02d000-fe02dfff : 0000:00:13.1
  fe02d000-fe02dfff : ohci_hcd
fe02e000-fe02efff : 0000:00:13.0
  fe02e000-fe02efff : ohci_hcd
fe02f000-fe02f3ff : 0000:00:12.0
  fe02f000-fe02f3ff : ahci
fec00000-ffffffff : reserved
  fec00000-fec00fff : IOAPIC 0
  fed00000-fed003ff : HPET 0
  fee00000-fee00fff : Local APIC


Using Debian stock kernel

00000000-0009f3ff : System RAM
0009f400-0009ffff : reserved
000f0000-000fffff : reserved
00100000-77fdffff : System RAM
  00200000-0042c443 : Kernel code
  0042c444-0053a677 : Kernel data
  005de000-00673317 : Kernel bss
77fe0000-77fe2fff : ACPI Non-volatile Storage
77fe3000-77feffff : ACPI Tables
77ff0000-77ffffff : reserved
78000000-7fffffff : pnp 00:0d
80000000-800003ff : 0000:00:14.0
d8000000-dfffffff : PCI Bus 0000:01
  d8000000-dfffffff : 0000:01:05.0
e0000000-efffffff : PCI MMCONFIG 0
  e0000000-efffffff : reserved
fdc00000-fdcfffff : PCI Bus 0000:02
  fdcff000-fdcff0ff : 0000:02:05.0
    fdcff000-fdcff0ff : r8169
fdd00000-fdefffff : PCI Bus 0000:01
  fdd00000-fddfffff : 0000:01:05.0
  fdee0000-fdeeffff : 0000:01:05.0
  fdefc000-fdefffff : 0000:01:05.2
    fdefc000-fdefffff : ICH HD audio
fdf00000-fdffffff : PCI Bus 0000:02
  fdf00000-fdf1ffff : 0000:02:05.0
fe020000-fe023fff : 0000:00:14.2
  fe020000-fe023fff : ICH HD audio
fe029000-fe0290ff : 0000:00:13.5
  fe029000-fe0290ff : ehci_hcd
fe02a000-fe02afff : 0000:00:13.4
  fe02a000-fe02afff : ohci_hcd
fe02b000-fe02bfff : 0000:00:13.3
  fe02b000-fe02bfff : ohci_hcd
fe02c000-fe02cfff : 0000:00:13.2
  fe02c000-fe02cfff : ohci_hcd
fe02d000-fe02dfff : 0000:00:13.1
  fe02d000-fe02dfff : ohci_hcd
fe02e000-fe02efff : 0000:00:13.0
  fe02e000-fe02efff : ohci_hcd
fe02f000-fe02f3ff : 0000:00:12.0
  fe02f000-fe02f3ff : ahci
fec00000-ffffffff : reserved
  fec00000-fec00fff : IOAPIC 0
  fed00000-fed003ff : HPET 0
  fee00000-fee00fff : Local APIC


Please let me know anything else I can provide, and which kernels you
would like me to run to provide it.


Dave W.
