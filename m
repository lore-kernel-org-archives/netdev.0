From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] act_nat: the checksum of ICMP doesn't have pseudo
	header
Date: Fri, 30 Jul 2010 22:30:16 +0800
Message-ID: <20100730143016.GA10543@gondor.apana.org.au>
References: <1280448258-1893-1-git-send-email-xiaosuo@gmail.com> <20100730090922.GA7807@gondor.apana.org.au> <AANLkTi=YHvra6DuL7vX=DfQmR6bsw7rNMJ9mRhUzHvj2@mail.gmail.com> <20100730102409.GA8590@gondor.apana.org.au> <AANLkTimKXsgmOSVmw-cP6Zw6UoK5CSshK38Oo5tLuAeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTimKXsgmOSVmw-cP6Zw6UoK5CSshK38Oo5tLuAeA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 30, 2010 at 10:16:05PM +0800, Changli Gao wrote:
> 
> I know we need to update the ICMP checksum if we alter the payload(the
> inner IP header here) of ICMP. But I doubt if the update is really
> necessary if the checksum is partial, as the   checksum will be done
> later(by ether skb_checksum_help() or NIC hardware). In fact, as there
> isn't any pseudo header, the icmph->checksum should be always ZERO,
> otherwise skb_checksum_help() or NIC will give the wrong checksums,
> when the checksum is partial.

Actually you are right.  I suppose the only reason this has never
shown up is because CHEKSUM_PARTIAL doesn't usually occur with
forwarded packets.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
