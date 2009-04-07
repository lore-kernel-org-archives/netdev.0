From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 7 Apr 2009 15:26:47 +0800
Message-ID: <20090407072647.GA11480@gondor.apana.org.au>
References: <1238701718.5669.26.camel@bender>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Johann Baudy <johann.baudy@gnu-log.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33487 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751966AbZDGH05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 03:26:57 -0400
Content-Disposition: inline
In-Reply-To: <1238701718.5669.26.camel@bender>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 07:48:38PM +0000, Johann Baudy wrote:
>
> +static void tpacket_destruct_skb(struct sk_buff *skb)
> +{
> +	struct packet_sock *po = pkt_sk(skb->sk);
> +	void * ph;
> +	
> +	BUG_ON(skb == NULL);
> +	
> +	if (likely(po->tx_ring.pg_vec)) {
> +		ph = packet_lookup_frame(po, &po->tx_ring, skb->mark, TP_STATUS_COPY);

What if something modifies skb->mark after it's sent? For now the
only thing I can think of is a tc netfilter action.  So you could
also solve the problem by removing that feature since IMHO it is
pretty dodgy :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
