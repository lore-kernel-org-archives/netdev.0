From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH 4/3] NETFILTER: New PPTP helper
Date: Thu, 15 Sep 2005 16:59:35 +0200
Message-ID: <20050915145935.GD17121@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Xm/fll+QQv+hsKip"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
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


--Xm/fll+QQv+hsKip
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave, please push this important fix to mainline.  Thanks!


[NETFILTER] Fix oops in conntrack event cache

ip_ct_refresh_acct() can be called without a valid "skb" pointer.  This
used to work, since ct_add_counters() deals with that fact.  However, the
recently-added event cache doesn't handle this at all.

This patch is a quick fix that is supposed to be replaced soon by a cleaner
solution during the pending redesign of the event cache.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 8fc09611c23e90f8d2e85a38850f97f5c615b7da
tree caff72b73bdad20fa4f6832a4d9028a69307b2b6
parent 6a31666e4f67a3eec97274b4aa8c245d06cd4fd3
author Harald Welte <laforge@netfilter.org> Do, 15 Sep 2005 16:58:12 +0200
committer Harald Welte <laforge@netfilter.org> Do, 15 Sep 2005 16:58:12 +02=
00

 net/ipv4/netfilter/ip_conntrack_core.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip=
_conntrack_core.c
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -1143,7 +1143,10 @@ void ip_ct_refresh_acct(struct ip_conntr
 		if (del_timer(&ct->timeout)) {
 			ct->timeout.expires =3D jiffies + extra_jiffies;
 			add_timer(&ct->timeout);
-			ip_conntrack_event_cache(IPCT_REFRESH, skb);
+			/* FIXME: We loose some REFRESH events if this function
+			 * is called without an skb.  I'll fix this later -HW */
+			if (skb)
+				ip_conntrack_event_cache(IPCT_REFRESH, skb);
 		}
 		ct_add_counters(ct, ctinfo, skb);
 		write_unlock_bh(&ip_conntrack_lock);
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--Xm/fll+QQv+hsKip
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFDKYxXXaXGVTD0i/8RArBQAJ4u37JyKWMEmEJSfOduP5FzaP+kFACgmSZL
E67uWSXMbhDJHzwyNdUdVtc=
=HTXG
-----END PGP SIGNATURE-----

--Xm/fll+QQv+hsKip--
