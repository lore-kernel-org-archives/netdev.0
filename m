From: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
Subject: Re: [PATCH 1/1] ARC vmac ethernet driver.
Date: Thu, 2 Dec 2010 13:39:30 +0100
Message-ID: <20101202123930.GA23289@biggy>
References: <1287129254-18078-1-git-send-email-andreas.fenkart@streamunlimited.com>
 <1287129254-18078-2-git-send-email-andreas.fenkart@streamunlimited.com>
 <20101019.065317.246538050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.fenkart@streamunlimited.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout-de.gmx.net ([213.165.64.23]:42069 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755394Ab0LBMhm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 07:37:42 -0500
Content-Disposition: inline
In-Reply-To: <20101019.065317.246538050.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 19, 2010 at 06:53:17AM -0700, David Miller wrote:
> From: Andreas Fenkart <andreas.fenkart@streamunlimited.com>
> Date: Fri, 15 Oct 2010 09:54:14 +0200
> 
> > +/* arcvmac private data structures */
> > +struct vmac_buffer_desc {
> > +	unsigned int info;
> > +	dma_addr_t data;
> > +};
> 
> If this is the actual descriptor used by the hardware you
> cannot define it this way.

Changed to this

	/* arcvmac private data structures */
	struct vmac_buffer_desc {
					__le32 info;
					__le32 data;
	};

> 
> dma_addr_t is a variable type, on some platforms it is a
> "u32", on others it is a "u64" but you cannot assume one
> way or another.

Added this check

  if (dma_get_mask(&pdev->dev) > DMA_BIT_MASK(32) ||
      pdev->dev.coherent_dma_mask > DMA_BIT_MASK(32)) {
    dev_err(&pdev->dev, "arcvmac supports only 32-bit DMA addresses\n");
    return -ENODEV;
  }

> 
> Also, are these values big or little endian?  You must use
> the appropriate endian types such as __be32 et al. and then
> access the members using the proper conversion functions.

Using cpu_to_le32 / le32_to_cpu when accessing register map,
buffer descriptors.

Andreas
