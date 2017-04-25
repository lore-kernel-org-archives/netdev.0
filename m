From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH net] net: batman-adv: Fix possible
	memleaks when fail to register_netdevice
Date: Tue, 25 Apr 2017 15:53:19 +0200
Message-ID: <1756616.320MP6AHYH@bentobox>
References: <1493121800-28066-1-git-send-email-gfree.wind@foxmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1829633.f4Iu6E4eP0";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, a@unstable.cc,
 Gao Feng <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gfree.wind-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org
To: b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <1493121800-28066-1-git-send-email-gfree.wind-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org

--nextPart1829633.f4Iu6E4eP0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Dienstag, 25. April 2017 20:03:20 CEST gfree.wind-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org wrote:
> From: Gao Feng <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>
> 
> Because the func batadv_softif_init_late allocate some resources and
> it would be invoked in register_netdevice. So we need to invoke the
> func batadv_softif_free instead of free_netdev to cleanup when fail
> to register_netdevice.

I could be wrong, but shouldn't the destructor be replaced with free_netdevice 
and the batadv_softif_free (without the free_netdev) used as ndo_uninit? The 
line you've changed should then be kept as free_netdevice.

At least this seems to be important when using rtnl_newlink() instead of the 
legacy sysfs netdev stuff from batman-adv. rtnl_newlink() would also only call 
free_netdevice and thus also not run batadv_softif_free. This seems to be only 
fixable by calling ndo_uninit.

Kind regards,
	Sven
--nextPart1829633.f4Iu6E4eP0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAlj/VM8ACgkQXYcKB8Em
e0Z9YhAAw25hf8lye40CPtVfOSvgC3dhUI5IQzSGtYaru0zeGCj0Zz0KExeqrgnI
k/7woi6xS1Cot7UXFHxKEyWkYvZ4/8HnIQlreJBVgVFAghoyjWfiaO76QN3/rcS6
BYCYnbxKlHUyfzMXZFsB6ae2UGW1HbhiBg0hHCZY7GqYn1G7cNywkeAqhCMMbnOJ
DaOSX7cYSL0eJymyWMu3VPeB0+oP+YtJhYa/nRvhGGb+45Q4ETu85vg3lNTTUyxo
onu+PZY5nKZd/WYwMIw1epiKp5GSjHahDZ2fQGtFcaj01XQ0cYrvAM0pb+xm20kD
wA/tbqNVCGqzeM7Kn1ov5wbF8uuRW4Fv7dqCEYuzz23uDbb4gGDPhOErBGgFAv+5
sJV4dNBWvqFUbMntlDYb3kEj+5X0Pgx+A9pJ8N7axNmRQmCkgfL0TPW2LEuQlI2Z
KQavA3suqbSQHBKJGh/jeP3SniJXFDBY3ksW9Y8wSCy3owO4c7bCOGAko3kpHwk5
faXoSIIPcI0qsK6ONdn+ft2B6b20y7egIMmLpY20hwXusUmp4juyZyFrtA4TTA9d
lZQm9ayXY/Ca4dUm150pUEIL+kx76rwz5xGaz7WKGQGXlsnMvOr2WS+Y20I3DQz5
rffehmN75TMNgIHeybOw9IdaMmSzCvi/EfG7EjpJ0MR1AJUwXpg=
=zmrp
-----END PGP SIGNATURE-----

--nextPart1829633.f4Iu6E4eP0--
