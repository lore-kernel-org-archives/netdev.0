From: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: i386 allmodconfig, current mainline
Date: Tue, 10 Aug 2010 01:32:32 +0100
Message-ID: <1281400352.7143.53.camel@localhost>
References: <20100809164346.6e30cf8c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>, Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>,
	Kevin Curtis <kevin.curtis-AP8L3A0T/wQqdlJmJB21zg@public.gmane.org>,
	Phillip Lougher <phillip-cnXvMjJKhjYG2Il/BtU0GPXRex20P6io@public.gmane.org>,
	Faisal Latif <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Chien Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Samuel Ortiz <samuel.ortiz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100809164346.6e30cf8c.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-08-09 at 16:43 -0700, Andrew Morton wrote:
> 
> drivers/power/olpc_battery.c:387: error: unknown field 'owner' specified in initializer
> drivers/power/olpc_battery.c:387: warning: initialization from incompatible pointer type
> make[2]: *** [drivers/power/olpc_battery.o] Error 1
> make[1]: *** [drivers/power] Error 2

I fixed that today.

> drivers/mtd/maps/gpio-addr-flash.c: In function 'gpio_flash_probe':
> drivers/mtd/maps/gpio-addr-flash.c:212: warning: cast to pointer from integer of different size
> drivers/mtd/maps/gpio-addr-flash.c:224: warning: cast to pointer from integer of different size

Ew. Mike? Is this a nommu driver which is missing an ioremap()? 

> drivers/pci/intel-iommu.c: In function 'dma_pte_addr':
> drivers/pci/intel-iommu.c:239: warning: passing argument 1 of '__cmpxchg64' from incompatible pointer type

-       return  __cmpxchg64(pte, 0ULL, 0ULL) & VTD_PAGE_MASK;
+       return  __cmpxchg64(&pte->val, 0ULL, 0ULL) & VTD_PAGE_MASK;

Will test and push.

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org                              Intel Corporation

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
