From: Harald Welte <laforge@netfilter.org>
Subject: Re: [PATCH/RFC] [NETFILTER]: Fix invalid module autoloading by
	splitting iptable_nat
Date: Sun, 25 Sep 2005 18:44:23 +0200
Message-ID: <20050925164423.GM731@sunbeam.de.gnumonks.org>
References: <20050925150755.GK731@sunbeam.de.gnumonks.org>
	<4336CFB4.6060806@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JGRpDW+vuEVQ9uQb"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4336CFB4.6060806@trash.net>
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


--JGRpDW+vuEVQ9uQb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Sep 25, 2005 at 06:26:28PM +0200, Patrick McHardy wrote:
> Harald Welte wrote:
> >Hi Patrick, Dave,
> >I think we really need a solution for the last (known) remaining
> >dependency problem with 2.6.14.  Please see the description
> >below.  I _think_ the patch is fine, at least I couldn't find any case
> >where we could leak anything by splitting the code in two modules.
> >There's a slight semantic change, though.  If the user unloads
> >iptable_nat, all existing connections (including their configured NAT
> >mappings) will continue to work.  Only when ip_nat.ko is unloaded, the
> >NAT mappings are evicted from the conntrack table.  I like it that way,
> >since it's logical.
>=20
> I agree, its more logical than having the table and the conntrack
> part in one module.

Ok. Gandalf has reviewed the code, too.   This makes three to blame if
something goes wrong ;)

Dave, please apply=20

(sorry for the missing Signed-off-by: Harald Welte <laforge@netfilter.org>)

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--JGRpDW+vuEVQ9uQb
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDNtPnXaXGVTD0i/8RAmMGAJ96otDXXlvfJX7heWin/+rcuoZWKQCgo1gq
21bPicId8o1ta9Z6uFY+TBE=
=qF7F
-----END PGP SIGNATURE-----

--JGRpDW+vuEVQ9uQb--
