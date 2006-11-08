From: Andrew Morton <akpm@osdl.org>
Subject: Re: [BUG] [2.6.19-rc4-mm2] can't compile
 drivers/acpi/processor_idle.c
Date: Tue, 7 Nov 2006 22:52:59 -0800
Message-ID: <20061107225259.0eff22d2.akpm@osdl.org>
References: <20061108150141.b792fbdb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-ia64@vger.kernel.org,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10682 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1754374AbWKHGxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Nov 2006 01:53:45 -0500
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061108150141.b792fbdb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 8 Nov 2006 15:01:41 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> While compiling 2.6.19-rc4-mm2 on ia64, I met this compile error.
> ==
>   CC [M]  drivers/acpi/processor_idle.o
> drivers/acpi/processor_idle.c:43:22: asm/apic.h: No such file or directory
> drivers/acpi/processor_idle.c: In function `acpi_processor_power_seq_show':
> drivers/acpi/processor_idle.c:1202: warning: long long unsigned int format, u64 arg (arg 5)
> ==
> 
> This is because of acpi-include-apic-h.patch, maybe.
> ia64 doesn't have asm/acpi.h

That got fixed (by ugly means).

> my .config is attached.

But rc5-mm1 remains broken with that .config:

arch/ia64/pci/pci.c: In function `pci_acpi_scan_root':
arch/ia64/pci/pci.c:354: warning: implicit declaration of function `pxm_to_node'
...
arch/ia64/pci/built-in.o(.text+0xe92): In function `pci_acpi_scan_root':
: undefined reference to `pxm_to_node'

This bug exists in mainline.




Also,

drivers/built-in.o(.text+0xd9a72): In function `e1000_xmit_frame':
: undefined reference to `csum_ipv6_magic'

I don't know how this got broken.  ia64 seems to be the only architecture
which doesn't have an implementation of csum_ipv6_magic().  This bug
appears to be introduced by git-netdev-all.patch.

