From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] clear skb cb on IP input
Date: Sun, 16 Jul 2006 18:18:09 -0700 (PDT)
Message-ID: <20060716.181809.71092089.davem@davemloft.net>
References: <E1G1kCA-000533-00@gondolin.me.apana.org.au>
	<20060715.181222.74751444.davem@davemloft.net>
	<20060716220350.GB30090@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, guichaz@yahoo.fr, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:1246
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751603AbWGQBRy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jul 2006 21:17:54 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060716220350.GB30090@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 17 Jul 2006 08:03:50 +1000

> The thing is qdiscs using cb means that this method of clearing cb
> before netif_rx doesn't work anymore.
> 
> In particular, even if loopback clears cb before calling netif_rx,
> some qdisc could come along between netif_rx and ip_rcv and put
> stuff in the cb.
> 
> The same thing can happen to any NIC in fact, as long as we allow
> qdiscs to use the cb area without clearing it, ip_rcv needs to
> clear it itself.

Ok, I'm convinced that IPv4 has to clear this out and shouldn't
assume it's contents are anything but garbage.

> With a little bit of effort we should be able to get away with
> clearing just optlen.  Whether this effort is worthwhile I don't
> know :)

It all sits in the same cacheline, so probably not.
