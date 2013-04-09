From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [PATCH 1/3] if.h: add IFF_BRIDGE_RESTRICTED flag
Date: Tue, 9 Apr 2013 15:51:44 +0200
Message-ID: <20130409135143.GA5177@open-mesh.com>
References: <1365442863-32394-1-git-send-email-antonio@open-mesh.com>
 <1365442863-32394-2-git-send-email-antonio@open-mesh.com>
 <CAOaVG17nHuoRsf2Kss6LnpgC-Aojcso_zLYyBa18Vn9CGGY+GA@mail.gmail.com>
 <20130409075606.GB3771@open-mesh.com>
 <51641049.3030100@mojatatu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ZPt4rx8FFjLCG7dd"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ht1.myhostedexchange.com ([69.50.2.37]:12132 "EHLO
	ht1.hostedexchange.local" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1762069Ab3DINxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 09:53:12 -0400
Content-Disposition: inline
In-Reply-To: <51641049.3030100@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--ZPt4rx8FFjLCG7dd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 09, 2013 at 05:57:45 -0700, Jamal Hadi Salim wrote:
> Hi,
>=20
> Consider using tc for this.
> You can tag the packet using skb mark on the receiving end point,
> match them on the bridge and execute actions not to forward them.


Does this work at the bridge level? A packet entering a port and going out =
=66rom
another one can be affected by tc/mark?


>=20
> cheers,
> jamal
>=20
> On 13-04-09 03:56 AM, Antonio Quartulli wrote:
> > On Mon, Apr 08, 2013 at 11:58:48 -0700, Stephen Hemminger wrote:
> >> The standard way to do this is to use netfilter. Considering the
> >> additional device flags and skb flag changes, I am not sure that your
> >> method is better.
> >
> > To make it a bit more clear:
> >
> > 1) the skb flag will be used on the "receiving end-point" by batman-adv=
 to mark
> > received packets and so instruct the bridge to do not forward them to r=
estricted
> > interfaces.
> >
> > 2) the IFF_ flag is used by batman-adv on the "sending side" to determi=
ne
> > whether a packet has been originated by a restricted interface and so i=
nstruct
> > the remote endpoint to mark the skb when received.
> >
> > 3) to make the bridge code general enough, I decided to let it mark pac=
kets
> > coming from restricted interfaces as well so that it can also apply the=
 policy
> > at 1) locally, without any further setting. The logic described in 1) is
> > therefore applied by the bridge even for local packets (not passing thr=
ough
> > batman-adv)
> >
> >
> >
> > Point 3) is the only one where netfilter might help. But using two mech=
anism to
> > achieve one goal looked not sane to me and therefore I decided to to do=
 it this
> > way. And actually the code allowing point 3 is only:
> >
> > +       skb->bridge_restricted =3D !!(skb->dev->flags & IFF_BRIDGE_REST=
RICTED);
> >
> >
> > I hope this summary did not create further confusion :)
> >
>=20

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--ZPt4rx8FFjLCG7dd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRZBzvAAoJEADl0hg6qKeONY0P/jpR5m40jPbt+NMutRwkk0Te
HoCl1evWLx7ZGoZecoyTMfqYBvdRVQauRFgqCxcfVwxnb10jeuXBmcKJ7Lv0UsAi
0TbPgO2dteTnFUK7yEHzen/7DOuUltgMLRx7kq4V8RzTUkBNd0LhKnUAyeZZCb12
uWO4B2GihJsHa5/sKq79C4Klt8PJ9qvMQ/JuyCSb1apKSRJG6/gDQW0cijyWHEaC
N4Gv7hTA0Y7OY4E2WNvlRPZtsFwiJgnyGMuB8JgcFw7VAQlxj8CWb5BQTWzvroxN
zw41GHLb9Hoic1yllBnZRkuUOQziVNAaXnBvjZ0CDg/KWfVqK1lTChRTkOP+PJgp
ji7gS0tDKTF11kR5SzENu4UIw3HgKiqNW7GRvK4wwI03NSXTdBGP6M0PC701ZIo2
G8FYH8jkY16wRzktaKwO49vTP8xB1SPptJsxjc7JzRJYs73Go1KdgNnq0T3MgomX
Fi2cd3E0zvdmmpSjhbdhFjH+B6a4pN0rYgygzJTuQ54shtxjkqJ3Yj5WcyeWKc00
GcNASYJD6JD0/bAQSG43FHk7uLYTNE/MYisVt4k9H7JnzfVrvmy3/8qEgYrYOpff
Y6FGgRPv8EjTr3ksJKa48XtPAFgdhw6UvD2dS+X39efPAvqR3IZc0vKRka7yu2Py
gJgojWl4yFVv0y/FHCJY
=YOan
-----END PGP SIGNATURE-----

--ZPt4rx8FFjLCG7dd--
