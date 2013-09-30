From: Luis Henriques <luis.henriques@canonical.com>
Subject: Re: [PATCH] sfc: Fix efx_rx_buf_offset() for recycled pages
Date: Mon, 30 Sep 2013 17:48:27 +0100
Message-ID: <87zjqu1cis.fsf@canonical.com>
References: <1379607231.1514.13.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Miller <davem@davemloft.net>,
	stable <stable@vger.kernel.org>, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1379607231.1514.13.camel@bwh-desktop.uk.level5networks.com> (Ben
	Hutchings's message of "Thu, 19 Sep 2013 17:13:51 +0100")
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <bhutchings@solarflare.com> writes:

> [Re-sending with cc to the current stable address.  I still had the old
> address in contacts, though I've definitely sent to the current address
> previously...]
>
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
>
> I'm attaching the patches for 3.0.y, 3.2.y and 3.4.y (the last of which
> should also be applicable to the later unofficial stable branches).
>
> Ben.

Thanks Ben.  I'm queuing it for the 3.5 kernel.

Cheers,
-- 
Luis
