From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/6] [BNX2]: Remove the rx_offset field from the bnx2 structure.
Date: Fri, 16 May 2008 21:29:43 +0100
Message-ID: <20080516202942.GJ28241@solarflare.com>
References: <1210973417.5507.19.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, andy@greyhouse.net,
	benli@broadcom.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53605 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757840AbYEPU3x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:29:53 -0400
Content-Disposition: inline
In-Reply-To: <1210973417.5507.19.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan wrote:
> [BNX2]: Remove the rx_offset field from the bnx2 structure.
> 
> The rx_offset field is set to a constant value and initialized
> only once.  By replacing all references to the rx_offset field,
> we can eliminate rx_offset from the bnx2 structure.  This will
> save 4 bytes for every bnx2 instance.

Probably not, since slab will round it up.

[...]
>  	bp->rx_buf_use_size = rx_size;
>  	/* hw alignment */
>  	bp->rx_buf_size = bp->rx_buf_use_size + BNX2_RX_ALIGN;
> -	bp->rx_jumbo_thresh = rx_size - bp->rx_offset;
> +	bp->rx_jumbo_thresh = rx_size - BNX2_RX_OFFSET;
>  	bp->rx_ring_size = size;
>  	bp->rx_max_ring = bnx2_find_max_ring(size, MAX_RX_RINGS);
>  	bp->rx_max_ring_idx = (bp->rx_max_ring * RX_DESC_CNT) - 1;
[...]
> +#define BNX2_RX_OFFSET		sizeof(struct l2_fhdr) + 2

The definition needs parentheses around it.  You would get away this
except for this one place where BNX2_RX_OFFSET is subtracted.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
