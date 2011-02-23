From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net_sched: long word align struct qdisc_skb_cb data
Date: Wed, 23 Feb 2011 09:30:01 -0800
Message-ID: <20110223093001.28e1a8ef@nehalam>
References: <20110221160306.GA9650@tuxdriver.com>
	<1298308283.2849.5.camel@edumazet-laptop>
	<1298390536.2861.9.camel@edumazet-laptop>
	<1298474091.3301.364.camel@edumazet-laptop>
	<4D6534C3.1080305@trash.net>
	<1298480707.3301.386.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Juliusz Chroboczek <Juliusz.Chroboczek@pps.jussieu.fr>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39888 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752417Ab1BWRaF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 12:30:05 -0500
In-Reply-To: <1298480707.3301.386.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Feb 2011 18:05:07 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mercredi 23 f=E9vrier 2011 =E0 17:24 +0100, Patrick McHardy a =E9c=
rit :
> > Am 23.02.2011 16:14, schrieb Eric Dumazet:
> > > diff --git a/include/net/sch_generic.h b/include/net/sch_generic.=
h
> > > index 16626a0..f40d32e 100644
> > > --- a/include/net/sch_generic.h
> > > +++ b/include/net/sch_generic.h
> > > @@ -218,6 +218,7 @@ struct tcf_proto {
> > > =20
> > >  struct qdisc_skb_cb {
> > >  	unsigned int		pkt_len;
> > > +	unsigned int		sfb_classid;
> > >  	char			data[];
> > >  };
> >=20
> > This could be moved into a SFB specific cb, similar to what netem
> > does.
>=20
> Hmm... well... I want to be sure no other sch will destroy my values.
>=20
> netem seems buggy then.
>=20
> Probably following patch is needed ?

Yes, it was long word aligned when netem was written but
we seem to have bit creep.



--=20
