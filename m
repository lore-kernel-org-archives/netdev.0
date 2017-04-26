From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH net] net: batman-adv: Fix possible
	memleaks when fail to register_netdevice
Date: Wed, 26 Apr 2017 07:57:44 +0200
Message-ID: <3994535.Z9kqCnttI2@bentobox>
References: <1493121800-28066-1-git-send-email-gfree.wind@foxmail.com>
 <1756616.320MP6AHYH@bentobox> <002901d2be25$d9092bd0$8b1b8370$@foxmail.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3772731.Kub63pVygl";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: mareklindner-rVWd3aGhH2z5bpWLKbzFeg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org, a@unstable.cc, 'Gao Feng' <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>,
 davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Gao Feng <gfree.wind-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <002901d2be25$d9092bd0$8b1b8370$@foxmail.com>
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

--nextPart3772731.Kub63pVygl
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

On Mittwoch, 26. April 2017 08:41:30 CEST Gao Feng wrote:
> On Dienstag, 25. April 2017 20:03:20 CEST gfree.wind-H32Fclmsjq1BDgjK7y7TUQ@public.gmane.org wrote:
> > From: Gao Feng <fgao-KlmEoCYek3zQT0dZR+AlfA@public.gmane.org>
> > 
> > Because the func batadv_softif_init_late allocate some resources and
> > it would be invoked in register_netdevice. So we need to invoke the
> > func batadv_softif_free instead of free_netdev to cleanup when fail
> > to register_netdevice.
> 
> I could be wrong, but shouldn't the destructor be replaced with free_netdevice 
> and the batadv_softif_free (without the free_netdev) used as ndo_uninit? The 
> line you've changed should then be kept as free_netdevice.
> 
> At least this seems to be important when using rtnl_newlink() instead of the 
> legacy sysfs netdev stuff from batman-adv. rtnl_newlink() would also only call 
> free_netdevice and thus also not run batadv_softif_free. This seems to be only 
> fixable by calling ndo_uninit.
> 
> Sorry, I don't get you.
> The net_dev is created in this func batadv_softif_create.
> Why couldn't invoke batadv_softif_free to cleanup when fail to
> register_netdevice?
> 

Because it is the legacy way to create the batadv interfaces and there is a 
"new" one. The new way is to use rtnl link (see batadv_link_ops). 

The rtnl linke (rtnl_newlink) would not benefit from your fix and therefore 
still show the old behavior. I think a different fix is necessary to solve the 
problem for both ways to create an batadv interface.

Kind regards,
	Sven
--nextPart3772731.Kub63pVygl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAlkANtgACgkQXYcKB8Em
e0ZVyA//Upbu4Lep+T49diKyjqfthpeUZLYA8UQnJ+NaHsDUV/uo68aGfQXJkdJt
RZ7bubgMee8Qf1FE6qLxi6Tj6b54iapPO2YGf00Owc1EyCgAZpw9XTOcR7Pjt7/o
fvYd5mK4cZoMtJloD+2j7UX4MtdtUGgNDt5Pv4q6Bq75DXs84oooAeJzdvv8PANF
IfpIJ3zxY0tf5FeXkHH4FzuRAoT7dC2RLGtVgoWpjVeM6N8A20L7xnhOF47BGOyi
1UY/Iu5dbU2VQJ6N4Yw4TreVI1kjztcf+yPH0C0SDb0xd131QQRVsCpDa8m06oQV
U6G2AReJFTBUh9sulb4CGcTbLtBLIaxI/4PhuWmuT+dr3j0X2+uHk+cCwxSFz6Hb
Dn6S3oPqDQhyxhUFlG1nofyamPqaAYuinLGegGn20ZD0/QFdTiKmkvYSXsvBQ7dc
Qaor9YCBFdnA6aB01HFKZuZMtEC4bb4t+DCY7gQQWQJjkvlVE0EA8hv7T5rlL5bu
ko9r/QcRkFl+R/hT8VY0GlA7hk55ssQ07AzgNS8ntlWEx0FErwX/ucUgwt+63Ijt
0vc5JbMFkaWP20SDWxRKjr5bd6DDO+dNFFUYx7aXMEwKlBInWe5RaBI+5fPV5eH0
sgL02AE6DTlS5Nf7Ujld4nPLXJgqd3lvPhZs+YshB6zQ5vUe/6A=
=ykFc
-----END PGP SIGNATURE-----

--nextPart3772731.Kub63pVygl--
