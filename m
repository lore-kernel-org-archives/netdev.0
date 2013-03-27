From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] drivers: net: ethernet: ti: sparse
 warning fix for ti ethernet drivers
Date: Wed, 27 Mar 2013 13:08:42 -0400 (EDT)
Message-ID: <20130327.130842.1463605715833541825.davem@davemloft.net>
References: <1364378287-11194-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-omap@vger.kernel.org
To: mugunthanvnm@ti.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1364378287-11194-1-git-send-email-mugunthanvnm@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mugunthan V N <mugunthanvnm@ti.com>
Date: Wed, 27 Mar 2013 15:28:07 +0530

> @@ -179,7 +179,7 @@ cpdma_desc_pool_create(struct device *dev, u32 phys, u32 hw_addr,
>  	} else {
>  		pool->cpumap = dma_alloc_coherent(dev, size, &pool->phys,
>  						  GFP_KERNEL);
> -		pool->iomap = pool->cpumap;
> +		pool->iomap = (void __iomem *) pool->cpumap;

This is bogus.

Either a pointer is to RAM, or it's an IOMEM pointer.  It cannot be both.

This indicates that pool->iomap's usage in this scenerio is not correct
at all.

