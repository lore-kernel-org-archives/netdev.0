From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcpdump may trace some outbound packets twice.
Date: Tue, 16 May 2006 11:20:46 +1000
Message-ID: <20060516012045.GA13574@gondor.apana.org.au>
References: <E1FfnZP-0003St-00@gondolin.me.apana.org.au> <44692847.4080100@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, shemminger@osdl.org,
	ranjitm@google.com, akpm@osdl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57355 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750970AbWEPBVC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 21:21:02 -0400
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <44692847.4080100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2006 at 03:17:59AM +0200, Patrick McHardy wrote:
>
> 3) Clone the skb and have dev_queue_xmit_nit() consume it.
> 
> That should actually be pretty easy.

Unfortunately that would mean an unconditional copy for all TSO packets
on NICs such as tg3/e1000.  These drivers have to modify the data area
of the skb.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
