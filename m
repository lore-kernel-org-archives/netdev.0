From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2.6.24] ixgb: TX hangs under heavy load
Date: Tue, 30 Oct 2007 09:12:11 -0700
Message-ID: <472757DB.1060308@intel.com>
References: <20071030125055.GA7195@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: zenyowu@tw.ibm.com, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50163 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757330AbXJ3QTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Oct 2007 12:19:10 -0400
In-Reply-To: <20071030125055.GA7195@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andy Gospodarek wrote:
> Auke,
> 
> It has become clear that this patch resolves some tx-lockups on the ixgb
> driver.  IBM did some checking and realized this hunk is in your
> sourceforge driver, but not anywhere else.  Mind if we add it?


I'll quickly double check where this came from in the first place and will post
this to Jeff

Thanks!

Auke


> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> 
> ---
> 
>  ixgb_main.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
> index d444de5..3ec7a41 100644
> --- a/drivers/net/ixgb/ixgb_main.c
> +++ b/drivers/net/ixgb/ixgb_main.c
> @@ -1324,7 +1324,7 @@ ixgb_tx_map(struct ixgb_adapter *adapter, struct sk_buff *skb,
>  
>  			/* Workaround for premature desc write-backs
>  			 * in TSO mode.  Append 4-byte sentinel desc */
> -			if (unlikely(mss && !nr_frags && size == len
> +			if (unlikely(mss && (f == (nr_frags-1)) && size == len
>  			             && size > 8))
>  				size -= 4;
>  
