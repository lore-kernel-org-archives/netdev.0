From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] reduce netfilte sk_buff enlargement
Date: Wed, 20 Jul 2005 09:23:05 -0400
Message-ID: <20050720132305.GA4077@rama>
References: <20050717220451.GB13434@rama.risq.ericsson.ca>
	<20050718.203145.105430424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="huq684BweRXVnRxX"
Cc: netdev@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	netfilter-devel@lists.netfilter.org, wensong@linux-vs.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050718.203145.105430424.davem@davemloft.net>
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


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jul 18, 2005 at 08:31:45PM -0700, David S. Miller wrote:
> From: Harald Welte <laforge@netfilter.org>
> Date: Mon, 18 Jul 2005 00:04:51 +0200
>=20
> > The only real in-tree user of nfcache was IPVS, who only needs a single
> > bit.  Unfortunately I couldn't find some other free bit in sk_buff to
> > stuff that bit into, so I introduced a separate field for them.  Maybe
> > the IPVS guys can resolve that to further save space.
>=20
> I think we must resolve this one before 2.6.14 goes out, which
> gives us a lot of time, but for now I'll eat that one-bit member.

Well, I hope IPVS people will take care of this.  I don't really know
that code too well...

> > Initially I wanted to shrink pkt_type to three bits (PACKET_HOST and
> > alike are only 6 values defined), but unfortunately the bluetooth code
> > overloads pkt_type :(
>=20
> This also must be cured somehow, that really isn't a clean nor nice
> usage of this field.

I just ran into Marcel Holtmann earlier today.  He thinks moving that
data into the cb is fine, though he has to double-check that.

He also said that he really only needs 5 bits, so even if the current
pkt_type overloading would persist, we could probably shrink it to make
space for the IPVS bit.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--huq684BweRXVnRxX
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC3lA4XaXGVTD0i/8RAqy7AJwOmAJqhXJHhHlQTLXR/PD26KgGXgCgrFEf
VqsKwPYpOc3qmlRXoHcV+bY=
=x/rm
-----END PGP SIGNATURE-----

--huq684BweRXVnRxX--
