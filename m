From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH FINAL] Merge the Sonics Silicon Backplane subsystem
Date: Tue, 31 Jul 2007 21:56:50 -0700
Message-ID: <20070731215650.84c7a26b.akpm@linux-foundation.org>
References: <200707291324.58691.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	bcm43xx-dev-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Ralf Baechle <ralf-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200707291324.58691.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, 29 Jul 2007 13:24:54 +0200 Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org> wrote:

> The Sonics Silicon Backplane is a mini-bus used on
> various Broadcom chips and embedded devices.

A few probs with mips allmodconfig:

drivers/ssb/driver_mipscore.c:121: warning: "struct ssb_serial_ports" declared inside parameter list
drivers/ssb/driver_mipscore.c:121: warning: its scope is only this definition or declaration, which is probably not what you want
drivers/ssb/driver_mipscore.c: In function `ssb_mips_serial_init':
drivers/ssb/driver_mipscore.c:166: warning: passing arg 1 of `ssb_extif_serial_init' from incompatible pointer type
drivers/ssb/driver_mipscore.c:166: warning: passing arg 2 of `ssb_extif_serial_init' from incompatible pointer type
drivers/ssb/driver_mipscore.c: At top level:
drivers/ssb/driver_mipscore.c:188: warning: 'ssb_cpu_clock' defined but not used
drivers/ssb/driver_pcicore.c: In function `ssb_fixup_pcibridge':
drivers/ssb/driver_pcicore.c:98: error: implicit declaration of function `pcibios_enable_device'
drivers/ssb/driver_pcicore.c: At top level:
drivers/ssb/driver_pcicore.c:278: warning: integer overflow in expression
drivers/ssb/driver_pcicore.c:278: warning: integer overflow in expression       

the latter is due to .end in

static struct resource ssb_pcicore_mem_resource = {
        .name   = "SSB PCIcore external memory",
        .start  = SSB_PCI_DMA,
        .end    = SSB_PCI_DMA + SSB_PCI_DMA_SZ - 1,
        .flags  = IORESOURCE_MEM,
};

It could be more Kconfig select borkage, of course..
