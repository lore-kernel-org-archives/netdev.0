From: Harald Welte <laforge@netfilter.org>
Subject: Re: [RFC PATCH] convert ebt_ulog to nfnetlink_log
Date: Sun, 7 Aug 2005 23:33:40 +0200
Message-ID: <20050807213340.GA4508@rama.de.gnumonks.org>
References: <20050730110353.GD6620@rama.de.gnumonks.org>
	<20050730.210423.111177162.davem@davemloft.net>
	<20050731070509.GD3835@rama.de.gnumonks.org>
	<1123241167.3377.15.camel@localhost.localdomain>
	<20050805163709.GF4033@rama.de.gnumonks.org>
	<20050805171028.GA7855@rama.de.gnumonks.org>
	<1123450076.3378.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
In-Reply-To: <1123450076.3378.18.camel@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 07, 2005 at 09:27:56PM +0000, Bart De Schuymer wrote:
> > I really hate to have those CONFIG_BRIDGE_NETFILTER ifdef's all over the
> > code - but for now we have them almost everywhere, so two more doesn't
> > hurt.  At some point we need to get rid of this ugliness and have somet=
hing
> > like an 'input device stack' that can be traversed.
>=20
> I'm not sure if I understand that, how could this be used to know if
> BRIDGE_NETFILTER was configured?

not at all.  It was just my extremely vague idea about something more
generic, like a stack of input devices.  Those ifdefs would basically
disappear, and the history of input devices (let's say the individual
decapsulation layers for tunneling, ...) would be visible via some
common structure that could also be used by bridging.  You can ignore
that comment/rant, it has no practical relevance in the current
discussion ;)

> > +#ifdef CONFIG_BRIDGE_NETFILTER
> > +		if (indev->br_port) {
> > +			tmp_uint =3D htonl(indev->br_port->br->dev->ifindex);
> > +			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
> > +				sizeof(tmp_uint), &tmp_uint);
> > +		}
>=20
> indev->br_port->br->dev->ifindex points to the ifindex of the bridge br0
> when indev is a bridge port (eth0). So you need this to fill in the
> input device (assuming we agree that the bridge is called the input
> device, and the bridge port is called the physical input device).
> Filling in the physical input device is done with indev (in case
> indev->br_port is not NULL).

I'm not sure if I can follow you.  What basically happens is:

ebt_ulog calls nf_log_packet(PF_BRIDGE, hooknr, skb, in, out, ...) where
"in" and "out" are struct net_device as passed to the ebt_ulog function
(which is part of the ebt_watcher). =20

[...]

the code ends up at the function you are quoting above.  "indev"
is "in" and "outdev" is "out", transparently passed from
nf_log_packet().

So I think it should reflect exactly what you currently do in ebt_ulog.
The only diference is that you now get the ifindex and not the device
name string.

Cheers,
	Harald
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC9n40XaXGVTD0i/8RAuH8AJ0dtLz5ijD45mTGrOsIL5JaS1cUVgCeKiVU
Uq7PhH19Hrf273XTPMGiUKQ=
=JjY/
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--
