From: Joe Perches <joe@perches.com>
Subject: Re: [NET-NEXT PATCH 1/2] igb: defeature tx head writeback
Date: Wed, 24 Dec 2008 15:18:29 -0800
Message-ID: <1230160709.9847.10.camel@localhost>
References: <20081224223142.12176.9916.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3977 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbYLXXR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 18:17:57 -0500
In-Reply-To: <20081224223142.12176.9916.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-12-24 at 14:31 -0800, Jeff Kirsher wrote:
> diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
> index 2121b8b..c906325 100644
> --- a/drivers/net/igb/igb.h
> +++ b/drivers/net/igb/igb.h
[]
> @@ -127,7 +125,8 @@ struct igb_buffer {
>  		/* TX */
>  		struct {
>  			unsigned long time_stamp;
> -			u32 length;
> +			u16 length;
> +			u16 next_to_watch;
>  		};
>  		/* RX */
>  		struct {

struct igb_buffer {
	struct sk_buff *skb;
	dma_addr_t dma;
	union {
		/* TX */
		struct {
			unsigned long time_stamp;
			u32 length;
		};
		/* RX */
		struct {
			struct page *page;
			u64 page_dma;
			unsigned int page_offset;
		};
	};
};

anonymous unions with anonymous structs?
That's not used very often in kernel source.
Should it be used here?


