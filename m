From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_nat: the checksum of ICMP doesn't have pseudo header
Date: Fri, 30 Jul 2010 22:16:05 +0800
Message-ID: <AANLkTimKXsgmOSVmw-cP6Zw6UoK5CSshK38Oo5tLuAeA@mail.gmail.com>
References: <1280448258-1893-1-git-send-email-xiaosuo@gmail.com>
	<20100730090922.GA7807@gondor.apana.org.au> <AANLkTi=YHvra6DuL7vX=DfQmR6bsw7rNMJ9mRhUzHvj2@mail.gmail.com>
	<20100730102409.GA8590@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100730102409.GA8590@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 30, 2010 at 6:24 PM, Herbert Xu <herbert@gondor.apana.org.a=
u> wrote:
>
> The checksum update is for the inner IP header. =A0netfilter does
> of course update the checksum, it just doesn't do it here which is
> for the outer IP header.
>

I know we need to update the ICMP checksum if we alter the payload(the
inner IP header here) of ICMP. But I doubt if the update is really
necessary if the checksum is partial, as the   checksum will be done
later(by ether skb_checksum_help() or NIC hardware). In fact, as there
isn't any pseudo header, the icmph->checksum should be always ZERO,
otherwise skb_checksum_help() or NIC will give the wrong checksums,
when the checksum is partial.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
