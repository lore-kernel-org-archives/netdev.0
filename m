From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/14] Spidernet DMA coalescing
Date: Thu, 14 Dec 2006 11:05:17 +0000
Message-ID: <20061214110517.GA13377@infradead.org>
References: <20061213210010.GR4329@austin.ibm.com>
	<20061213210659.GA1915@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	linuxppc-dev@ozlabs.org, Jens Osterkamp <Jens.Osterkamp@gmx.de>,
	jgarzik@pobox.com, James K Lewis <jim@jklewis.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
To: Linas Vepstas <linas@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <20061213210659.GA1915@austin.ibm.com>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 13, 2006 at 03:06:59PM -0600, Linas Vepstas wrote:
> 
> The current driver code performs 512 DMA mappings of a bunch of 
> 32-byte ring descriptor structures. This is silly, as they are 
> all in contiguous memory. This patch changes the code to 
> dma_map_coherent() each rx/tx ring as a whole.

It's acutally dma_alloc_coherent now that you updated the patch :)

> +	chain->ring = dma_alloc_coherent(&card->pdev->dev, alloc_size,
> +		&chain->dma_addr, GFP_KERNEL);
>  
> +	if (!chain->ring)
> +		return -ENOMEM;
>  
> +	descr = chain->ring;
> +	memset(descr, 0, alloc_size);

dma_alloc_coherent is defined to zero the allocated memory, so you
won't need this memset.
