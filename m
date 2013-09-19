From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: Fix efx_rx_buf_offset() for recycled
 pages
Date: Thu, 19 Sep 2013 13:43:44 -0400 (EDT)
Message-ID: <20130919.134344.567275739975628700.davem@davemloft.net>
References: <1379607231.1514.13.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1379607231.1514.13.camel@bwh-desktop.uk.level5networks.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 19 Sep 2013 17:13:51 +0100

> This bug fix is only for stable branches older than 3.10.  The bug was
> fixed upstream by commit 2768935a4660 ('sfc: reuse pages to avoid DMA
> mapping/unmapping costs'), but that change is totally unsuitable for
> stable.
> 
> Commit b590ace09d51 ('sfc: Fix efx_rx_buf_offset() in the presence of
> swiotlb') added an explicit page_offset member to struct
> efx_rx_buffer, which must be set consistently with the u.page and
> dma_addr fields.  However, it failed to add the necessary assignment
> in efx_resurrect_rx_buffer().  It also did not correct the calculation
> of efx_rx_buffer::dma_addr in efx_resurrect_rx_buffer(), which assumes
> that DMA-mapping a page will result in a page-aligned DMA address
> (exactly what swiotlb violates).
> 
> Add the assignment of efx_rx_buffer::page_offset and change the
> calculation of dma_addr to make use of it.

No objections.
