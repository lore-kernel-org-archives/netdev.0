From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 20:45:15 +0800
Message-ID: <20070927124515.GA16706@gondor.apana.org.au>
References: <20070927073446.GA14643@gondor.apana.org.au> <20070927092512.GD29329@2ka.mipt.ru> <20070927093358.GA15357@gondor.apana.org.au> <20070927100753.GA22323@2ka.mipt.ru> <20070927102916.GA15749@gondor.apana.org.au> <20070927124120.GA8897@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1525 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752816AbXI0Mpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 08:45:33 -0400
Content-Disposition: inline
In-Reply-To: <20070927124120.GA8897@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 27, 2007 at 04:41:21PM +0400, Evgeniy Polyakov wrote:
>
> I've attached simple patch which moves checksum helpers out of
> CONFIG_NETFILTER option but still in the same linux/netfilter.h header.
> This should be enough for removing 'select NETFILTER' in your patch.

Close but no cigar :)

> diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
> index 1dd075e..6c3fb10 100644
> --- a/include/linux/netfilter.h
> +++ b/include/linux/netfilter.h
> @@ -40,6 +40,29 @@
>  #endif
>  
>  #ifdef __KERNEL__
> +
> +static inline void nf_csum_replace4(__sum16 *sum, __be32 from, __be32 to)
> +{
> +	__be32 diff[] = { ~from, to };
> +
> +	*sum = csum_fold(csum_partial((char *)diff, sizeof(diff), ~csum_unfold(*sum)));
> +}
> +
> +static inline void nf_csum_replace2(__sum16 *sum, __be16 from, __be16 to)
> +{
> +	nf_csum_replace4(sum, (__force __be32)from, (__force __be32)to);
> +}
> +
> +extern void nf_proto_csum_replace4(__sum16 *sum, struct sk_buff *skb,
> +				      __be32 from, __be32 to, int pseudohdr);

This function won't exist if NETFILTER is off.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
