From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH] add bridging support to nfnetlink_{log,queue}
Date: Mon, 8 Aug 2005 19:36:10 +0200
Message-ID: <20050808173610.GN25303@rama.de.gnumonks.org>
References: <W911141491296841123491979@kostunerix.telenet-ops.be>
	<20050808132413.GA25303@rama.de.gnumonks.org>
	<1123523010.3384.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jWL1oGPK2mPq0rME"
Cc: "bdschuym@pandora.be" <bdschuym@telenet.be>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
In-Reply-To: <1123523010.3384.19.camel@localhost.localdomain>
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


--jWL1oGPK2mPq0rME
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Aug 08, 2005 at 05:43:29PM +0000, Bart De Schuymer wrote:
> Op ma, 08-08-2005 te 15:24 +0200, schreef Harald Welte:
> > > There is one case missing: the brouter case. If br0=3Deth0+eth1 and a
> > > packet arrives at eth0 (not br0) in the IP code (not the bridge code),
> > > then the indev must be eth0, not br0.  How about something like this?
> >=20
> > Ok, I've implemented your suggested modifications now.
>=20
> There's still one small issue: if CONFIG_BRIDGE_NETFILTER isn't set in
> the kernel configuration but ebtables is enabled,=20

Doesn't ebtables attach to netfilter hooks? Ah, BRIDGE_NETFILTER
actually only selects the {ip,ip6,arp}tables emulation, not netfilter
support in bridging. =20

> then the physindev should still be filled in if ebt_ulog is used. I'm
> afraid this will result in more ugly ifdef's.

well, If you can send me a patch for those ugly ifdef's after you get
back from holidays, I'll apply it.  Until then I think we can live
without that missing bit.

> I don't mind making CONFIG_BRIDGE_NETFILTER mandatory for people wanting
> to log the logical {in,out}put device, if you feel it would uglify the
> code too much otherwise...=20

No, I don't think we should force people to use certain config options
if they're technically not required.

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--jWL1oGPK2mPq0rME
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC95gKXaXGVTD0i/8RAqufAJ9pxXO0MDJc0lyV+Swtd59zWYaC2gCePZcf
A5iOtG6a8OwHKBdy4SIjaV8=
=P1HO
-----END PGP SIGNATURE-----

--jWL1oGPK2mPq0rME--
