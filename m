From: Kyle McMartin <kyle@redhat.com>
Subject: Re: [PATCH 2/3] e1000e: Useset_memory_ro()/set_memory_rw() to
	protect flash memory
Date: Wed, 24 Sep 2008 13:53:58 -0400
Message-ID: <20080924175358.GA2591@phobos.i.cabal.ca>
References: <20080923224535.6869.76210.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, mingo@elte.hu, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	Bruce Allan <bruce.w.allan@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 206-248-169-182.dsl.ncf.ca ([206.248.169.182]:52383 "EHLO
	phobos.cabal.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751899AbYIXRx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 13:53:59 -0400
Content-Disposition: inline
In-Reply-To: <20080923224535.6869.76210.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 03:45:54PM -0700, Jeff Kirsher wrote:
> +#ifdef _ASM_X86_CACHEFLUSH_H
> +	set_memory_rw((unsigned long)hw->flash_address,
> +	              hw->flash_len >> PAGE_SHIFT);
> +#endif
>  	writew(val, hw->flash_address + reg);
> +#ifdef _ASM_X86_CACHEFLUSH_H
> +	set_memory_ro((unsigned long)hw->flash_address,
> +	              hw->flash_len >> PAGE_SHIFT);
> +#endif
>  }

Hi Jeff,

You're making the entire read-only mapping read-write for the single
writel call... why not just limit it to the page that the writel is
targetting?

regards, Kyle
[sorry, I've only been following this at a glance, but it's somewhat
 important for rawhide... does someone have a way to reproduce this at
 whim? Has someone tried catching it using an IOMMU on one of the newer
 Intel boxes, if it is a DMA going awry?]
