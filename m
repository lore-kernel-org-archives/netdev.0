From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] wireless: iwlwifi - add dma_mapping_error() checks to
 avoid warnings
Date: Mon, 05 Nov 2012 17:29:52 +0100
Message-ID: <1352132992.9466.27.camel@jlt4.sipsolutions.net>
References: <1351993233.4369.2.camel@lorien2>
	 (sfid-20121104_024119_271188_5372C13E) <1352020617.10072.0.camel@jlt4.sipsolutions.net>
	 <1352132785.2606.14.camel@lorien2>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: wey-yi.w.guy@intel.com, linville@tuxdriver.com,
	ilw@linux.intel.com, emmanuel.grumbach@intel.com,
	donald.h.fry@intel.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	shuahkhan@gmail.com
To: shuah.khan@hp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352132785.2606.14.camel@lorien2>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-11-05 at 09:26 -0700, Shuah Khan wrote:

> > Thanks for the report. Since I think doing BUG_ON() in such a scenario
> > is a really bad idea, I've applied a different patch with your
> > Reported-by.
> 
> Yeah. I wasn't sure about BUS() either. Did you notice the other cases
> of BUG_ON() in this path in iwl_rx_allocate()? I would think those need
> fixing as well.
> 
>               rxb->page_dma =
>                         dma_map_page(trans->dev, page, 0,
>                                      PAGE_SIZE <<
> trans_pcie->rx_page_order,
>                                      DMA_FROM_DEVICE);
>                 /* dma address must be no more than 36 bits */
>                 BUG_ON(rxb->page_dma & ~DMA_BIT_MASK(36));
>                 /* and also 256 byte aligned! */
>                 BUG_ON(rxb->page_dma & DMA_BIT_MASK(8));

Well, yes, we could convert them, but we can leave them as they are
because these are assertions that the DMA mapping API guarantees. If
this breaks, it's a bug in the DMA mapping code.

In contrast, if it fails to map, it's not a bug in the code, it's just
running out of memory or IO space or whatever.

> Could you please send me commitID for the patch you did. I am interested
> in seeing the failure handling in your patch?

It's here:
http://git.kernel.org/?p=linux/kernel/git/iwlwifi/iwlwifi-fixes.git;a=commit;h=7c34158231b2eda8dcbd297be2bb1559e69cb433

johannes
