From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Mon, 17 Jul 2006 08:03:50 +1000
Message-ID: <20060716220350.GB30090@gondor.apana.org.au>
References: <20060714.144855.62664893.davem@davemloft.net> <E1G1kCA-000533-00@gondolin.me.apana.org.au> <20060715.181222.74751444.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, guichaz@yahoo.fr, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:22798 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751309AbWGPWFg
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 18:05:36 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060715.181222.74751444.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 15, 2006 at 06:12:22PM -0700, David Miller wrote:
> 
> But I'm beginning to think that the onus of this may in fact fall upon
> the devices, in fact.  Loopback is one of the few devices where the
> control block might not be cleared out, due to uses in the output
> path.  Devices predominantly provide a zero'd out control block in the
> skb on packet receive.

The thing is qdiscs using cb means that this method of clearing cb
before netif_rx doesn't work anymore.

In particular, even if loopback clears cb before calling netif_rx,
some qdisc could come along between netif_rx and ip_rcv and put
stuff in the cb.

The same thing can happen to any NIC in fact, as long as we allow
qdiscs to use the cb area without clearing it, ip_rcv needs to
clear it itself.

With a little bit of effort we should be able to get away with
clearing just optlen.  Whether this effort is worthwhile I don't
know :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
