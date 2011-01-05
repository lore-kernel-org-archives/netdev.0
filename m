From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] sched: CHOKe packet scheduler
Date: Wed, 05 Jan 2011 18:25:32 +0100
Message-ID: <1294248332.10633.25.camel@edumazet-laptop>
References: <20110104162930.6fa672e3@nehalam>
	 <1294208375.3420.46.camel@edumazet-laptop>
	 <20110105091718.02f8a00f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:34692 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab1AERZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 12:25:40 -0500
Received: by eye27 with SMTP id 27so6833876eye.19
        for <netdev@vger.kernel.org>; Wed, 05 Jan 2011 09:25:39 -0800 (PST)
In-Reply-To: <20110105091718.02f8a00f@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 janvier 2011 =C3=A0 09:17 -0800, Stephen Hemminger a =C3=
=A9crit :
> On Wed, 05 Jan 2011 07:19:35 +0100
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
> > Le mardi 04 janvier 2011 =C3=A0 16:29 -0800, Stephen Hemminger a =C3=
=A9crit :
> > > +static struct sk_buff *skb_peek_random(struct sk_buff_head *list=
)
> > > +{
> > > +	struct sk_buff *skb =3D list->next;
> > > +	unsigned int idx =3D net_random() % list->qlen;
> > > +
> > > +	while (skb && idx-- > 0)
> > > +		skb =3D skb->next;
> > > +
> > > +	return skb;
> > > +}
> >=20
> > You could avoid the divide op :
> >=20
> > unsigned int idx =3D reciprocal_divide(random32(), list->qlen);
>=20
> How would this work, it is a mod not a divide??
>=20

It works, because random32() provides a 32bit 'random' number.
between 0 and 0xFFFFFFFF

We multiply it by X, get a 64bit number between 0 and 0xFFFFFFFF * X
then we right shift it by 32, get a number between 0 and X - 1=20

We dont need to get the modulus, just a random number between 0 and X -
1

Dont worry, we should add a helper function to do that, since it might
be used in many places.

/* deliver a random number between 0 and N - 1 */
u32 random_N(unsigned int N)
{
	reciprocal_divide(random32(), N);
}




