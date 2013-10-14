From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [RFC net] bridge: clean the nf_bridge status when forwarding the
 skb
Date: Tue, 15 Oct 2013 00:20:10 +0200
Message-ID: <20131014222010.GB3873@neomailbox.net>
References: <1380226790-513-1-git-send-email-antonio@meshcoding.com>
 <20130926141021.3cde0f0f@nehalam.linuxnetplumber.net>
 <20130926211648.GB1228@open-mesh.com>
 <20130926143248.2799b4ea@nehalam.linuxnetplumber.net>
 <20130926220143.GC1228@open-mesh.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="hHWLQfXTYDoKhP50"
Cc: "David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:26230 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756557Ab3JNWUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Oct 2013 18:20:44 -0400
Content-Disposition: inline
In-Reply-To: <20130926220143.GC1228@open-mesh.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Sep 27, 2013 at 12:01:43AM +0200, Antonio Quartulli wrote:
> On Thu, Sep 26, 2013 at 02:32:48PM -0700, Stephen Hemminger wrote:
> > > > > diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
> > > > > index 4b81b14..65864bc 100644
> > > > > --- a/net/bridge/br_forward.c
> > > > > +++ b/net/bridge/br_forward.c
> > > > > @@ -49,6 +49,11 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
> > > > >  	} else {
> > > > >  		skb_push(skb, ETH_HLEN);
> > > > >  		br_drop_fake_rtable(skb);
> > > > > +
> > > > > +		/* clean the NF bridge data */
> > > > > +		nf_bridge_put(skb->nf_bridge);
> > > > > +		skb->nf_bridge =3D NULL;
> > > > > +
> > > > >  		dev_queue_xmit(skb);
> > > > >  	}
> > > > > =20
> > >=20
> > > Regarding CONFIG_BRIDGE_NETFILTER you are right, thanks.
> > >=20
> > > >=20
> > > > I think the header will also be garbage if bridge on bridge with ne=
tfilter is used.
> > > > See nf_bridge_save_header.
> > >=20
> > > What header are you referring to? nf_bridge_save_header() saves the h=
eader in
> > > skb->nf_bridge->data, which is freed during nf_bridge_put() (assuming
> > > ->use reached 0).
> > >=20
> > >=20
> >=20
> > If bridge is stacked the original ether header will get overwritten by =
the second
> > call to save_header.
>=20
> Sorry, but I am not getting what you mean (I am new to the code and it is=
 late here..):
> save_header() will store the Ethernet header in nf_bridge->data for
> later recover (if needed).
>=20
> By freeing nf_bridge I also destroy this header copy.
>=20
> When the skb enters the second bridge, save_header() will save again the =
header
> in nf_bridge->data. But I don't see how this can create a problem.
>=20
> The problem I had before this patch comes from the fact that
> nf_bridge_copy_header() is invoked in the second bridge with the nf_bridg=
e state
> of the first. This was overwriting my the packet Ethernet header with wha=
t the
> first invocation of save_header() stored in nf_bridge->data.
>=20
> But by unsetting nf_bridge I think I am preventing this from happening ag=
ain.
> no?

Hello Stephen,

do you have other comments about this patch? I know it is rather difficult =
that
a generic user hits this issue, but I'd like to see it fixed because other
people using batman-adv may incur in this problem.

Cheers,


--=20
Antonio Quartulli

--hHWLQfXTYDoKhP50
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSXG4aAAoJEADl0hg6qKeO+0MQAJBHFy9l2HITVnSoPAzb41Cz
2IpBZxF3CcN9bVVKskTdRJoEb5jBcSP+R42USipRFQ8ptpJyot2FzElmZh1d5e2D
c0O81GAqqM9Zyzl/rMgrk7E8KmkkW7xYfqSbMytRvlZq6Ur9yKeqVD1py/iPdwoD
fIH97eBSCpuKaEtNTwa1N1ufT6tRaC16f5ZHVJOBUhe18VzcorfJiYd4UCGYqb2f
H8iJNQ6aWTRhaPTU+YCIMCVK1F18R85JyZktwaPAN2RDhJ0yqDkAe8Tq1Sc0QbAG
w3WbCeGVZbCAxh3JNbtT9joLaXlCA8U+OfKyB29ms22ngzDGxirfFySCxD46ljCd
Q8ZqmkIWsycWtvpU0KE/SbkHHBPd22y7tbm+qhyE9XaLdkaVWubfckSMcR2cGPi1
vC6RtVLYTOtIJlFBKm0yE5RlGxukdHWPXu0c728LLaiOIKZnfb3MlTifoYGJ6ToP
7x2AXPEBpIaZXUyayasZMkyqoVr7oUbqVTcoSNEN5HPuLQN4e9F094e577eK1Ah/
h1gkSohmdhGiva1rAWJn1T6/ETsitK/qEHxOC+QpL0STWUgyYdUsWUQCju3g2a/o
hSTVP4jAxYZKUx/GmSDjlbR9e0SFDblq3x0KFpdKomtny2pZnbsHM4FwGCNkGqWr
QDOVLY+WHAdLGCP8nn5y
=acUF
-----END PGP SIGNATURE-----

--hHWLQfXTYDoKhP50--
