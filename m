From: Alexander Samad <alex@samad.com.au>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Wed, 24 Mar 2004 14:33:26 +1100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20040324033326.GP3387@samad.com.au>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF17.8090907@trash.net> <20040324021514.GM3387@samad.com.au> <4060F4F6.5020400@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Y5wfsVCgeKAcINk2"
Cc: "David S. Miller" <davem@redhat.com>, herbert@gondor.apana.org.au,
	netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4060F4F6.5020400@trash.net>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org


--Y5wfsVCgeKAcINk2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 24, 2004 at 03:39:50AM +0100, Patrick McHardy wrote:
> Alexander Samad wrote:
> >Hi
> >
> >Think their might be a problem with this patch.
> >
> >Potientially a packet could traverse the pre, forward and the post
> >routing, at which point it can be SNAT'ed or MASQ'ed and then re
> >injected into route_me_harder.  This potiential could allow packets to
> >be rerouted based on the new src/dst addresses differently to the intail
> >packet but this new packet doesn't traverse any of the chains with the
> >new information.
>=20
> This is just as without the patches, SNAT in POST_ROUTING never causes
> a packet to re-traverse the hooks. There is one minor difference,
> packets which match a policy after NAT stop traversing the hooks at
> NF_IP_PRI_NAT_SRC priority. I will fix this this for the final version.

Sorry might not have made myself clear, after an SNAT with your patch
the packet is re injected into route_me_harder, thus the packet is able
to be rerouted (sent out another interface for example)=20

What this would mean is a packet could meet your iptable rules with is
PRE-SNAT details and then actually behave differently once it has been
SNAT'ed (and not get checked)

Alex

>=20
> Regards
> Patrick
>=20
> >
> >Alex
> >
> >On Thu, Mar 18, 2004 at 05:32:23PM +0100, Patrick McHardy wrote:
> >
> >>This patch adds policy lookups to ip_route_me_harder and makes NAT
> >>reroute for any change that affects route/policy lookups.
> >>
> >
> >
> >
>=20
>=20

--Y5wfsVCgeKAcINk2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFAYQGGkZz88chpJ2MRAo0JAJ9BoQrQ6BYCrP97qVL5XelYiwQLYQCdGKxY
r1Z0KbBtH5IxE2ZoHGV0BIU=
=mcmw
-----END PGP SIGNATURE-----

--Y5wfsVCgeKAcINk2--
