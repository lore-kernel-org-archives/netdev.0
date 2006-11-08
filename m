From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] [2.6.19-rc4-mm2] can't compile
 drivers/acpi/processor_idle.c
Date: Wed, 8 Nov 2006 16:22:35 +0900
Message-ID: <20061108162235.7645bb40.kamezawa.hiroyu@jp.fujitsu.com>
References: <20061108150141.b792fbdb.kamezawa.hiroyu@jp.fujitsu.com>
	<20061107225259.0eff22d2.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org,
	auke-jan.h.kok@intel.com, jeff@garzik.org
Return-path: <linux-ia64-owner@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061107225259.0eff22d2.akpm@osdl.org>
Sender: linux-ia64-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 7 Nov 2006 22:52:59 -0800
Andrew Morton <akpm@osdl.org> wrote:

> On Wed, 8 Nov 2006 15:01:41 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > 
> > While compiling 2.6.19-rc4-mm2 on ia64, I met this compile error.
> > ==
> >   CC [M]  drivers/acpi/processor_idle.o
> > drivers/acpi/processor_idle.c:43:22: asm/apic.h: No such file or directory
> > drivers/acpi/processor_idle.c: In function `acpi_processor_power_seq_show':
> > drivers/acpi/processor_idle.c:1202: warning: long long unsigned int format, u64 arg (arg 5)
> > ==
> > 
> > This is because of acpi-include-apic-h.patch, maybe.
> > ia64 doesn't have asm/acpi.h
> 
> That got fixed (by ugly means).

Ah, okay. I'll move to rc5-mm1. Thank you.

> 
> > my .config is attached.
> 
> But rc5-mm1 remains broken with that .config:
> 
> arch/ia64/pci/pci.c: In function `pci_acpi_scan_root':
> arch/ia64/pci/pci.c:354: warning: implicit declaration of function `pxm_to_node'
> ...
> arch/ia64/pci/built-in.o(.text+0xe92): In function `pci_acpi_scan_root':
> : undefined reference to `pxm_to_node'
> 
> This bug exists in mainline.
> 

How about this ? Maybe ia64 people's review is necessary.

-Kame
==
When ACPI && NUMA, pxm_to_node is used and it exists in drivers/acpi/numa.c

Signed-Off-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>

Index: linux-2.6.19-rc4-mm2/arch/ia64/Kconfig
===================================================================
--- linux-2.6.19-rc4-mm2.orig/arch/ia64/Kconfig	2006-11-08 14:15:21.000000000 +0900
+++ linux-2.6.19-rc4-mm2/arch/ia64/Kconfig	2006-11-08 16:16:40.000000000 +0900
@@ -353,6 +353,7 @@
 	bool "NUMA support"
 	depends on !IA64_HP_SIM && !FLATMEM
 	default y if IA64_SGI_SN2
+	select ACPI_NUMA if ACPI
 	help
 	  Say Y to compile the kernel to support NUMA (Non-Uniform Memory
 	  Access).  This option is for configuring high-end multiprocessor

