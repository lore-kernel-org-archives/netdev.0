From: Neil Horman <nhorman@redhat.com>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 08:05:47 -0400
Message-ID: <20100519120547.GB26584@hmsreliant.think-freely.org>
References: <20100519075721.GA23926@gondor.apana.org.au>
 <1274256582.2766.5.camel@edumazet-laptop>
 <1274257089.2766.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755618Ab0ESMGG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 08:06:06 -0400
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
>=20
But if this happens, then we loose the connection between the packet be=
ing
received and the process doing the reception, so the network cgroup cla=
ssifier
breaks again.

Performance gains are still a big advantage here of course.
Neil

