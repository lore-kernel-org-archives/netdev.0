From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net 1/2] mpls: Fix mpls_gso handler.
Date: Fri, 31 Oct 2014 15:41:08 +0900
Message-ID: <20141031064105.GA16156@vergenet.net>
References: <1414655397-1541-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:60215 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbaJaGlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 02:41:18 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so6746202pdj.0
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 23:41:18 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1414655397-1541-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2014 at 12:49:57AM -0700, Pravin B Shelar wrote:
> mpls gso handler needs to pull skb after segmenting skb.
> 
> CC: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

Apologies for messing that up, your change does seem to match the comment
above it.

So, assuming that this has been tested:

Acked-by: Simon Horman <simon.horman@netronome.com>

> ---
>  net/mpls/mpls_gso.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> index f0f5309..e3545f2 100644
> --- a/net/mpls/mpls_gso.c
> +++ b/net/mpls/mpls_gso.c
> @@ -59,8 +59,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
>  	 * above pulled.  It will be re-pushed after returning
>  	 * skb_mac_gso_segment(), an indirect caller of this function.
>  	 */
> -	__skb_push(skb, skb->data - skb_mac_header(skb));
> -
> +	__skb_pull(skb, skb->data - skb_mac_header(skb));
>  out:
>  	return segs;
>  }
> -- 
> 1.7.1
> 
