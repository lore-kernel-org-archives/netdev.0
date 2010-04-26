From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH 1/4] e1000e: save skb counts in TX to avoid cache misses
Date: Mon, 26 Apr 2010 08:55:06 -0700
Message-ID: <4BD5B75A.3040100@intel.com>
References: <alpine.DEB.1.00.1004231719050.16806@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:32726 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323Ab0DZPzI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Apr 2010 11:55:08 -0400
In-Reply-To: <alpine.DEB.1.00.1004231719050.16806@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
> In e1000_tx_map, precompute number of segements and bytecounts which
> are derived from fields in skb; these are stored in buffer_info.  When
> cleaning tx in e1000_clean_tx_irq use the values in the associated
> buffer_info for statistics counting, this eliminates cache misses
> on skb fields.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
> diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
> index 12648a1..d6da75b 100644
> --- a/drivers/net/e1000e/e1000.h
> +++ b/drivers/net/e1000e/e1000.h
> @@ -188,6 +188,8 @@ struct e1000_buffer {
>  			unsigned long time_stamp;
>  			u16 length;
>  			u16 next_to_watch;
> +			unsigned int segs;
> +			unsigned int bytecount;
>  			u16 mapped_as_page;
>  		};
>  		/* Rx */

Does segs need to be a full int here?  I think you can probably get away 
with either an unsigned short or just define it as a u16, then combine 
it with mapped_as_page to cut down on the overall size.

Thanks,

Alex
