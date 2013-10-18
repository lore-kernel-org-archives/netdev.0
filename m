From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Fri, 18 Oct 2013 13:35:55 +0200
Message-ID: <20131018113555.GK2596@neomailbox.net>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com>
 <20131017112857.GA11318@localhost>
 <20131017113735.GB2699@open-mesh.com>
 <20131018111041.GA10964@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="iRjOs3ViPWHdlw/I"
Cc: Antonio Quartulli <antonio@open-mesh.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:10094 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753077Ab3JRLgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 07:36:31 -0400
Content-Disposition: inline
In-Reply-To: <20131018111041.GA10964@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--iRjOs3ViPWHdlw/I
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Oct 18, 2013 at 01:10:41PM +0200, Pablo Neira Ayuso wrote:
> On Thu, Oct 17, 2013 at 01:37:35PM +0200, Antonio Quartulli wrote:
> > On Thu, Oct 17, 2013 at 04:28:57AM -0700, Pablo Neira Ayuso wrote:
> > > Hi,
> > > > +
> > > > +/**
> > > > + * br_netfilter_skb_free - clean the NF bridge data in an skb
> > > > + * @skb: the skb which the data to free belongs to
> > > > + */
> > > > +void br_netfilter_skb_free(struct sk_buff *skb)
> > > > +{
> > > > +	nf_bridge_put(skb->nf_bridge);
> > > > +	skb->nf_bridge =3D NULL;
> > > > +}
> > >=20
> > > This should be nf_reset.
> >=20
> > You think I should directly use nf_reset instead of this function?
> >=20
> > I see that nf_reset() cleans up the conntrack part too: does it also be=
come
> > useless once the packet exits the bridge interface?
>=20
> The conntrack should not attached if it's forwarded to another netif,
> see dev_forward_skb.
>=20
> But I'm not sure what scenario you're trying to handle with this
> change, if you could please elaborate.


This is a sample scenario (nf bridge is on):

[eth0] ---> [br0] ---> [bat0] ---> [br1]

where the relation '[a] ---> [b]' means 'a is enslaved in b' (bat0 is a
batman-adv virtual interface..in this situation it should not matter: it
just removs an header from an incoming skb and delivers it).

The problem I was having was due to an skb entering br0 first and br1 later.
When reaching br1 skb->nf_bridge was !=3D NULL because of the previous proc=
essing
in br0.

To clarify, the packet arriving on eth0 is 'delivered' to br0. It is not
forwarded to another port of the bridge. Therefore I am not sure that we sh=
ould
clean the conntrack part too.

>=20
> Perhaps your fix is more conservative to avoid breaking strange setups
> that have been relying on this behaviour. I know of people deploying
> strange configurations using netfilter bridge.
>=20

could be.

Cheers,

--=20
Antonio Quartulli

--iRjOs3ViPWHdlw/I
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSYR0bAAoJEADl0hg6qKeORcYQAJTgjmkYPfbF17f9sbp+KUq7
c9TOjimW/sPF7LG5GYFZf0WKhtDEstFc7oRsuW/QsuYrAcT8QRqKn3AwuYtIWTRx
jPToNgLH9fvpPXd6X9nAGqjEtGuLB0mQslbofNP5uwPXWqTGVJoRfLKMDxnqG8uo
TH6inYJ3sF7UlBbfRx+bIKpcgExFtCh8z51Dj7pcRXPgjA/9QzeAFG2Lq/Mjmktf
93WWRcIJEQWewkpL3qPXLHWC3O37YOyuXJd66vaQzcmFdka9ckQLf0+3xw2orvSw
7ja796TgdE7atFRleIsauTXff/KGf3veaydw+tOjG9WRo8DTilR/UyuayKIX+2qt
YNpFQKhMjlLjy4/TGxq1zuDhdlLICERUl5zkXHCr91ZxSr9l6Oc61yfzaxemnDaa
tu5zaNc1Rpn7WLaVraJV9N+grK4P0nq9bSdf+wKJg9xJfq6y5VVH5PH5vlrdAIHm
wz9lbo4Ll3QtODw81+g6+bwsGEMXbFQrPUgQezevMPxYkm+jF5XKsiEQx0ggZCud
m2tB/CdQpGZNLuUk2Ca2dTasvZRdnTchqCPJ65QhyemepesWUR0cb/g78OFg1OgD
9Lxq4W7NMT0IsFJg0mjFE78BlEBFkGxxZ2CFcwJ22q3xsm8cbh9rMtsNVAs6JUBm
L6YoRxXqgiZ2V+aWRtvR
=EaBB
-----END PGP SIGNATURE-----

--iRjOs3ViPWHdlw/I--
