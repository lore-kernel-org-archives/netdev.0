From: Florian Lohoff <flo@rfc822.org>
Subject: Re: BUG: scheduling while atomic: ifconfig/0x00000002/4170
Date: Thu, 6 Sep 2007 10:38:04 +0200
Message-ID: <20070906083804.GB20644@paradigm.rfc822.org>
References: <20070902184439.GA14306@paradigm.rfc822.org> <6bffcb0e0709021659o3856cd06gabc054c949a84397@mail.gmail.com> <alpine.LFD.0.999.0709060923340.26804@enigma.security.iitk.ac.in> <20070906082301.GB21929@gondor.apana.org.au> <alpine.LFD.0.999.0709061409120.3781@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TakKZr9L6Hm6aLOc"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, linux-wireless@vger.kernel.org,
	Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	ipw3945-devel@lists.sourceforge.net, yi.zhu@intel.com
To: Satyam Sharma <satyam@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756146AbXIFIiT@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709061409120.3781@enigma.security.iitk.ac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--TakKZr9L6Hm6aLOc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 06, 2007 at 02:11:46PM +0530, Satyam Sharma wrote:
> On Thu, 6 Sep 2007, Herbert Xu wrote:
>=20
> > On Thu, Sep 06, 2007 at 10:32:33AM +0530, Satyam Sharma wrote:
> > >=20
> > > > > [  382.529041]  [<c02c8abc>] dev_close+0x24/0x67
> > > > > [  382.529052]  [<e01f402b>] ieee80211_master_stop+0x4a/0x6d [mac=
80211]
> >=20
> > This is where the bug is.  You cannot call dev_close from an
> > atomic context as i33380211_master_stop does it within spin
> > locks.
>=20
> Doh, of course! I must be blind ... and wait_for_completion()'s
> might_sleep() clearly didn't trigger earlier because Florian must've
> had CONFIG_DEBUG_SPINLOCK_SLEEP off in his .config ...

# CONFIG_DEBUG_SPINLOCK_SLEEP is not set

Exactly ...

Flo
--=20
Florian Lohoff                  flo@rfc822.org             +49-171-2280134
	Those who would give up a little freedom to get a little=20
          security shall soon have neither - Benjamin Franklin

--TakKZr9L6Hm6aLOc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFG37xsUaz2rXW+gJcRAi1SAKC7KncTgeJYtwDQFVhjhml5ucKshgCfS5GD
PRtbaTuS2rBmcMMjwKMPjaE=
=fIGc
-----END PGP SIGNATURE-----

--TakKZr9L6Hm6aLOc--
