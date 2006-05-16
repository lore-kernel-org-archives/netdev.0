From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Tue, 16 May 2006 10:37:51 +1000
Message-ID: <E1FfnZP-0003St-00@gondolin.me.apana.org.au>
References: <20060515.170835.126804002.davem@davemloft.net>
Cc: shemminger@osdl.org, ranjitm@google.com, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:523 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1750885AbWEPAiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 20:38:04 -0400
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20060515.170835.126804002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> Other implementation possibility suggestions welcome :-)

I see two possibilities:

1) Move the af_packet hook into the NIC driver.
2) Rethink the lockless tx setup.  If all NICs followed the tg3 and
   replaced spin_lock_irqsave with spin_lock then we should be able
   to go back to just using the xmit_lock.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
