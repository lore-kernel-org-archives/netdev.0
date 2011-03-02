From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Wed, 02 Mar 2011 09:04:08 +0100
Message-ID: <1299053048.2930.85.camel@edumazet-laptop>
References: <20110301112759.GK9763@canuck.infradead.org>
	 <1298979909.3284.28.camel@edumazet-laptop>
	 <20110301115305.GA6984@gondor.apana.org.au>
	 <1298984609.3284.98.camel@edumazet-laptop>
	 <20110301131823.GB8028@gondor.apana.org.au>
	 <1298997084.3284.119.camel@edumazet-laptop>
	 <20110302002353.GA15009@gondor.apana.org.au>
	 <1299031203.2930.26.camel@edumazet-laptop>
	 <20110302023920.GA16072@gondor.apana.org.au>
	 <AANLkTim0+7mTYrQF3mttUW+JqOmvTyMoDXOdeCX_SSdp@mail.gmail.com>
	 <20110302073123.GA18443@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tom Herbert <therbert@google.com>,
	Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45621 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab1CBIEP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 03:04:15 -0500
Received: by bwz15 with SMTP id 15so5351651bwz.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 00:04:14 -0800 (PST)
In-Reply-To: <20110302073123.GA18443@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 02 mars 2011 =C3=A0 15:31 +0800, Herbert Xu a =C3=A9crit :
> On Tue, Mar 01, 2011 at 11:12:29PM -0800, Tom Herbert wrote:
> >
> > Probably need to set skb->ooo_okay (for UDP etc.) also so that XPS
> > will change queues.
>=20
> Hmm, not quite.  We still want to maintain packet ordering from
> the same CPU.  That is, if I do two sendmsg calls from the same
> CPU, they should go into the same queue in that order.
>=20
> So this shouldn't just be a knob that says whether we can pick
> queues at random.
>=20

Not sure why two UDP packets from the same cpu should be sent on same
queue.

- Some qdisc do reorder packets anyway.
- Some bonding setups use two links in round-robin mode (link
aggregation)


