From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC 0/7] Fixing dma mask setting in various
	network drivers
Date: Mon, 17 Jun 2013 15:01:45 +0100
Message-ID: <20130617140145.GH2718@n2100.arm.linux.org.uk>
References: <20130610230849.GF18614@n2100.arm.linux.org.uk>
	<20130611111230.000062d2@unknown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rasesh Mody <rmody@brocade.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20130611111230.000062d2@unknown>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Tue, Jun 11, 2013 at 11:12:30AM -0700, Jesse Brandeburg wrote:
> This is my proposed change to the intel drivers.  Comments?
> 
> +	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> +		pci_using_dac = true;
> +		/* coherent mask for the same size will always succeed if
> +		 * dma_set_mask does
> +		 */
> +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
> +	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
> +		pci_using_dac = false;
> +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> +	} else {
> +		dev_err(&pdev->dev, "%s: DMA configuration failed: %d\n",
> +			 __func__, err);
> +		err = -EIO;
> +		goto err_dma;
>  	}
> 

So, will you be going with this change rather than mine, which apparantly
Jeff queued?  Please let me know what you decide so I can keep my private
git tree in sync with what you've decided to avoid conflicting with
further dma-mask changes which I'm working on.

Thanks.

------------------------------------------------------------------------------
This SF.net email is sponsored by Windows:

Build for Windows Store.

http://p.sf.net/sfu/windows-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
