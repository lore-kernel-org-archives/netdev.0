From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] Phonet: refuse to send bigger than MTU packets
Date: Sun, 16 Nov 2008 19:49:33 -0800 (PST)
Message-ID: <20081116.194933.193729748.davem@davemloft.net>
References: <1226653710-27642-1-git-send-email-remi.denis-courmont@nokia.com>
	<Pine.LNX.4.64.0811141223370.3930@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40801
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755915AbYKQDtd convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Nov 2008 22:49:33 -0500
In-Reply-To: <Pine.LNX.4.64.0811141223370.3930@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Fri, 14 Nov 2008 12:25:40 +0200 (EET)

> On Fri, 14 Nov 2008, R=E9mi Denis-Courmont wrote:
>=20
> > Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com=
>
> > ---
> >  net/phonet/af_phonet.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> >=20
> > diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> > index defeb7a..7ab30f6 100644
> > --- a/net/phonet/af_phonet.c
> > +++ b/net/phonet/af_phonet.c
> > @@ -144,8 +144,8 @@ static int pn_send(struct sk_buff *skb, struct =
net_device *dev,
> >  	struct phonethdr *ph;
> >  	int err;
> > =20
> > -	if (skb->len + 2 > 0xffff) {
> > -		/* Phonet length field would overflow */
> > +	if (skb->len + 2 > 0xffff /* Phonet length field limit */ ||
>=20
> It would by much better to have a well named constant there rather th=
an=20
> such crazy and messy contruct with a comment.

Sure, but it would need to be "U16_MAX" or whatever, which we don't
have currently, since this is a field overflow check rather than some
specific constant defined by the protocol.

I'm applying R=E9mi's patch.
