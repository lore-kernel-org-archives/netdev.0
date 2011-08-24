From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 1/4] net: convert core to skb paged frag APIs
Date: Wed, 24 Aug 2011 08:49:56 +0100
Message-ID: <1314172196.10283.28.camel@zakaz.uk.xensource.com>
References: <1314092683.10283.21.camel@zakaz.uk.xensource.com>
	 <1314092701-4347-1-git-send-email-ian.campbell@citrix.com>
	 <CAHXqBFJSXB1z6sqEqLg_rc-GnYJBN7b7=mjwsGL8NTf6ga5qaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([62.200.22.115]:4783 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458Ab1HXHuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 03:50:05 -0400
In-Reply-To: <CAHXqBFJSXB1z6sqEqLg_rc-GnYJBN7b7=mjwsGL8NTf6ga5qaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-23 at 19:34 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/8/23 Ian Campbell <ian.campbell@citrix.com>:
> > +               for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++) {
> > +                       skb_frag_t *frag =3D &skb_shinfo(skb)->frag=
s[i];
>=20
> This is a rather common construct, so it might be worth it to
> introduce something like for_each_skb_frag().

I agree. My first stab at this helper (which was untenable for other
reasons, I never posted it) had such a helper. I decided not to tackle
it on this pass since it touches a bunch of places which even this
enormous series doesn't. I've got it on my list to do some time after
this series as a cleanup though.

Some places want the frag nr and others want the skb_frag_t* so I think
you'd end up with
	for_each_skb_frag(skb, frag) { ... }
and
	for_each_skb_frag_nr(skb, i) { ... }
a few places use both frag and i within the loop but not enough to
warrant an explicit helper, I don't think.

An "skb_frag(skb, i)" helper for the &skb_shinfo(skb)->frags[i]
construct might be nice too.

Ian.
