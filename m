From: Linus =?utf-8?Q?L=C3=BCssing?= <linus.luessing@web.de>
Subject: Re: [PATCH] bridge: multicast: add sanity check for query
 source addresses
Date: Tue, 4 Mar 2014 11:43:55 +0100
Message-ID: <20140304104032.GB5090@Linus-Debian>
References: <1393901855-18231-1-git-send-email-linus.luessing@web.de>
	<20140304090614.GA3952@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tuFXEhzhBeitrIAu"
Cc: netdev@vger.kernel.org, Florian Westphal <fwestpha@redhat.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jan Stancek <jstancek@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20140304090614.GA3952@order.stressinduktion.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--tuFXEhzhBeitrIAu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Mar 04, 2014 at 10:06:14AM +0100, Hannes Frederic Sowa wrote:
> > diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> > index ef66365..fb0e36f 100644
> > --- a/net/bridge/br_multicast.c
> > +++ b/net/bridge/br_multicast.c
> > @@ -1235,6 +1235,12 @@ static int br_ip6_multicast_query(struct net_bri=
dge *br,
> >  	    (port && port->state =3D=3D BR_STATE_DISABLED))
> >  		goto out;
> > =20
> > +	/* RFC2710+RFC3810 (MLDv1+MLDv2) require link-local source addresses =
*/
> > +	if (!(ipv6_addr_type(&ip6h->saddr) & IPV6_ADDR_LINKLOCAL)) {
> > +		err =3D -EINVAL;
> > +		goto out;
> > +	}
> > +
>=20
> Shouldn't we allow empty source address, here?
>=20
> Routers are supposed to drop them but bridges care. Linux uses ::
> as source address as long as no valid LL addresses are available,
> e.g. at boot-up (RFC3810 5.2.13.).

RFC3810, 5.2.13. refers to MLD reports, not queries, so that
shouldn't be relevant, section 5.1.14 should apply. Also the
bridge code only issues queries with a valid link-local source
address (see br_ip6_multicast_alloc_query() in
net/bridge/br_multicast.c). Where does Linux use :: for queries?

Cheers, Linus

--tuFXEhzhBeitrIAu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTFa5qAAoJELxyPiAAt6Uvl1oP+QGdd0aPIJICqYOB0ai007x/
12t0FZGUs/LRfRjPQA2oHuCgnuoLoWEZ06wxZhmrWnb64KgqWsuIYGLAZfOT2M3a
TRkQ9FAGZqxf0386BrnPwL3HI+tHo1QOud2vIJ5Y6Q/4RLwi7aAfkJiyhr+Yi1vs
tORPX+0p7gshIdhNvDF7FsVBN+S2Id0swM00I80KBXcB139MsdVybaWr4eEsvV3d
8K8WmCbH3aSmmmnvkVcr97RZaYtxKhQWDuLucXNmacyTg2MOGoytVK8x0dt+lKBb
C0u+pGF3W7AM16rmqY5Xfiei+IsQeG87xCo0cGFSYUorkh1SqYBvBrLXYRn2U2wT
8odhUfYpupuESUl0D+8jmZx8u8bLAnuT1xop47N43kKOgFo6PNnCy1w2lyWWultE
rh2dY7FiRWWrtug7w+PB3ohxxfcfO0w/MHyK5ebdP7vgIpG4SvgnGA2JdnBC1uiO
EfIpx1HYjqqIuc3MyqVYJOymIxQGJyKm5U4N1GePoBk9RTGGrNF0Laj+2vY11eet
kNfUs169V7m7R6z93FIjsgO+ZQGCbH/w2gHx4kHG8+uKA1mdTW6law2YIzdzpGxJ
XmG+ZPPKVdiM+NTo2PRXqmYPGb6f8b/wzg6tdqP9XPPr0O/0NLMPVDj17+cFqrOR
tXFAwfA2q7ca4atv8IvL
=wzfl
-----END PGP SIGNATURE-----

--tuFXEhzhBeitrIAu--
