From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dev_alloc_skb: avoid using GFP_ATOMIC
Date: Tue, 29 Sep 2009 09:58:42 -0700
Message-ID: <20090929095842.7038ca0e@nehalam>
References: <1254242593-2279-1-git-send-email-swalter@lexmark.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	swalter <swalter@swalter-d630.vyatta.com (none) >,
	Steven Walter <swalter@lexmark.com>
To: swalter@lexmark.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37883 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752398AbZI2Q6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Sep 2009 12:58:43 -0400
In-Reply-To: <1254242593-2279-1-git-send-email-swalter@lexmark.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Sep 2009 12:43:13 -0400
swalter@lexmark.com wrote:

> From: swalter <swalter@swalter-d630.(none)>
> 
> 
> Signed-off-by: Steven Walter <swalter@lpdev.prtdev.lexmark.com>
> ---
>  net/core/skbuff.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9e0597d..58ec625 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -306,7 +306,11 @@ struct sk_buff *dev_alloc_skb(unsigned int length)
>  	 * There is more code here than it seems:
>  	 * __dev_alloc_skb is an inline
>  	 */
> -	return __dev_alloc_skb(length, GFP_ATOMIC);
> +	if (in_interrupt()  ||  in_atomic()  ||  irqs_disabled()) {
> +		return __dev_alloc_skb(length, GFP_ATOMIC);
> +	} else {
> +		return __dev_alloc_skb(length, GFP_KERNEL);
> +	}
>  }
>  EXPORT_SYMBOL(dev_alloc_skb);
>  

No, this should be fixed by caller (using netdev_alloc_skb)
also, it may break cases like swap over NFS that want to get memory
when memory pool is low


-- 
