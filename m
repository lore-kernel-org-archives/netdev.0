From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [BUG REPORT]  Unencrypted packets after SNAT, allthough
 IPSEC-Policies are present
Date: Mon, 15 Sep 2014 14:04:07 +0200
Message-ID: <20140915120407.GQ6390@secunet.com>
References: <541089DD.6060307@sirrix.com>
 <20140911115401.GL6390@secunet.com>
 <54119F75.8090305@sirrix.com>
 <20140912093143.GN6390@secunet.com>
 <20140915080941.GP6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<herbert@gondor.apana.org.au>
To: Konstantinos Kolelis <k.kolelis@sirrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59851 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753886AbaIOMES (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 08:04:18 -0400
Content-Disposition: inline
In-Reply-To: <20140915080941.GP6390@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2014 at 10:09:41AM +0200, Steffen Klassert wrote:
>  
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index beeed60..e041822 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -2138,7 +2138,8 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
>  			xfrm_pols_put(pols, drop_pols);
>  			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTNOSTATES);
>  
> -			return make_blackhole(net, family, dst_orig);
> +			err = -EREMOTE;
> +			goto error;

We must return here, otherwise we drop some refcounts too much.
I'll send an updated patch tomorrow.
