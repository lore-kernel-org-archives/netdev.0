From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [PATCH] ixgbe: Fix ixgbe_tx_map error path
Date: Tue, 12 Jan 2010 15:27:41 -0800
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F12D49A30A1@orsmsx501.amr.corp.intel.com>
References: <20100112110135.GK12666@kryten>
 <80769D7B14936844A23C0C43D9FBCF0F12D49A2CE7@orsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	Anton Blanchard <anton@samba.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32366 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754547Ab0ALX1n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2010 18:27:43 -0500
In-Reply-To: <80769D7B14936844A23C0C43D9FBCF0F12D49A2CE7@orsmsx501.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Duyck, Alexander H wrote:
> Actually it looks like the bug for ixgbe is in the while (count >= 0)
> check.  It should be just while (count > 0) insead. 
> 
> It also appears there is an issue I may have introduced in igb as
> well.  I will go back through the drivers and see about submitting
> some patches to address these issues.  
> 
> Thanks,
> 
> Alex

It looks like we actually have some other patches in place that are addressing the count >= 0 issue.  This patch addresses the remaining return value of -1 issues for ixgbe. I think we should probably pull it into Jeff's tree for testing, and I will generate a separate patch for the igb issues.

Thanks,

Alex

> -----Original Message-----
> From: Anton Blanchard [mailto:anton@samba.org]
> Sent: Tuesday, January 12, 2010 3:02 AM
> To: Kirsher, Jeffrey T; Brandeburg, Jesse; Allan, Bruce W; Waskiewicz
> Jr, Peter P; Ronciak, John; Skidmore, Donald C; Zou, Yi; Duyck,
> Alexander H  
> Cc: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
> Subject: [PATCH] ixgbe: Fix ixgbe_tx_map error path
> 
> 
> Commit e5a43549f7a58509a91b299a51337d386697b92c (ixgbe: remove
> skb_dma_map/unmap calls from driver) looks to have introduced a bug in
> ixgbe_tx_map. If we get an error from a PCI DMA call, we loop
> backwards 
> through count until it becomes -1 and return that.
> 
> The caller of ixgbe_tx_map expects 0 on error, so return that instead.
> 
> ---
> 
> diff --git a/drivers/net/ixgbe/ixgbe_main.c
> b/drivers/net/ixgbe/ixgbe_main.c 
> index 1a2ea62..af660ba 100644
> --- a/drivers/net/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ixgbe/ixgbe_main.c
> @@ -5174,7 +5174,7 @@ dma_error:
>  		ixgbe_unmap_and_free_tx_resource(adapter, tx_buffer_info);
>  	}
> 
> -	return count;
> +	return 0;
>  }
> 
>  static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,

