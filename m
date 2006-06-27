From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [NET]: Added GSO header verification
Date: Tue, 27 Jun 2006 13:46:35 -0700
Message-ID: <1151441195.3543.3.camel@rh4>
References: <20060627120714.GA15270@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:53004 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1161299AbWF0Upi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 16:45:38 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060627120714.GA15270@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-27 at 22:07 +1000, Herbert Xu wrote:

> [NET]: Added GSO header verification
>
> @@ -2166,10 +2166,14 @@ struct sk_buff *tcp_tso_segment(struct s
>         if (!pskb_may_pull(skb, thlen))
>                 goto out;
>  
> +       segs = NULL;
> +       if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST))
> +               goto out;
> +

This logic doesn't look right to me.  Perhaps it's backwards and should
be:

if (!skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST))

