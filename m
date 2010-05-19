From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 18:21:28 +1000
Message-ID: <20100519082128.GB24331@gondor.apana.org.au>
References: <20100519075721.GA23926@gondor.apana.org.au> <1274256582.2766.5.camel@edumazet-laptop> <1274257089.2766.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@redhat.com>,
	Neil Horman <nhorman@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:35116 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752481Ab0ESIVe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 04:21:34 -0400
Content-Disposition: inline
In-Reply-To: <1274257089.2766.7.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 10:18:09AM +0200, Eric Dumazet wrote:
> Le mercredi 19 mai 2010 =E0 10:09 +0200, Eric Dumazet a =E9crit :
>=20
> > Another concern I have is about RPS.
> >=20
> > netif_receive_skb() must be called from process_backlog() context, =
or
> > there is no guarantee the IPI will be sent if this skb is enqueued =
for
> > another cpu.
>=20
> Hmm, I just checked again, and this is wrong.
>=20
> In case we enqueue skb on a remote cpu backlog, we also
> do __raise_softirq_irqoff(NET_RX_SOFTIRQ); so the IPI will be done
> later.

OK your concern is only with the stack usage, right?

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
