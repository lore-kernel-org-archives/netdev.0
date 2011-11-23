From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net-next
 tree related)
Date: Wed, 23 Nov 2011 15:00:04 +1100
Message-ID: <20111123150004.59be04eb36c480ec44edc9d5@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__23_Nov_2011_15_00_04_+1100_HwQkzJ/w/jvY0cw6"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__23_Nov_2011_15_00_04_+1100_HwQkzJ/w/jvY0cw6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc allnoconfig)
failed like this:

In file included from include/linux/netdevice.h:53:0,
                 from include/linux/icmpv6.h:173,
                 from include/linux/ipv6.h:220,
                 from include/net/ipv6.h:16,
                 from include/linux/sunrpc/clnt.h:26,
                 from include/linux/nfs_fs.h:50,
                 from init/do_mounts.c:20:
include/net/netprio_cgroup.h:23:29: error: field 'css' has incomplete type

And several more similar.

Caused by commit 5bc1421e34ec ("net: add network priority cgroup
infrastructure (v4)").

I have added the following (minimal, but probably not optimal) patch for
today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 23 Nov 2011 14:49:49 +1100
Subject: [PATCH] net: fix build error in network priority cgroup
 infrastructure

Fixes this error:

In file included from include/linux/netdevice.h:53:0,
                 from include/linux/icmpv6.h:173,
                 from include/linux/ipv6.h:220,
                 from include/net/ipv6.h:16,
                 from include/linux/sunrpc/clnt.h:26,
                 from include/linux/nfs_fs.h:50,
                 from init/do_mounts.c:20:
include/net/netprio_cgroup.h:23:29: error: field 'css' has incomplete type

When CONFIG_CGROUPS is not set.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 include/net/netprio_cgroup.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
index c432e99..da71b91 100644
--- a/include/net/netprio_cgroup.h
+++ b/include/net/netprio_cgroup.h
@@ -20,7 +20,9 @@
=20
 struct cgroup_netprio_state
 {
+#ifdef CONFIG_CGROUPS
 	struct cgroup_subsys_state css;
+#endif
 	u32 prioidx;
 };
=20
--=20
1.7.7.3

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Wed__23_Nov_2011_15_00_04_+1100_HwQkzJ/w/jvY0cw6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJOzG/EAAoJEECxmPOUX5FE8CoP/iSK5UWvw1Ed2P6C7JCkRkT2
Nk1h+6C8ocC8r7cP0vplLtIYW92J1VyKnEw9FfsTgvxZ7LHfL5dTRDyckLbYJkK0
US9a5t7QLFhlE1RzzJCGZm6731tpSbyapQZrNls0G0MjAG56ChSNcwvh7h5x9IC9
I8HqMGWcA1kgNZoawetJFgUcZnY3sNZ78LpteZ8afW/imQXGLU7OiZUnGx19u7CX
paD/RBKJqqKB5ms4qvFk3QSh46HswrVSpvWwn911GPkYkLzrwwi+CntJ/sdUbAyD
I+Wm4Md20Wo/riPMCYVtGrjr9Ms5Sxa2c2xAU0Foa8p6Ab/IERtHsI6PMO/+dl4Y
hVFPa46u5XEK9uDHFmZK1Wh89pCKdSjDvtGDDStjUg7htPKfJZNYiiYqF9AxW3dE
MOavcFzwOQWNUL2gpaANVy8ao2xsmU0VIuR7sEOjgsd3uRxarrGVz7eAFh1hpgUv
Hzj95FwZ4nL/WJnAneGaJOrG+ljIDcF7S1PmDp1M7KJnzajMEdzXJ1GKdqNCfYg7
frFIKgFfm2bLHG20UYpJezsJdX7xmznUnPNMCK6fPhkpsbC9moxEnSlCEhrNCE6P
DCcO0f8Ww9rKZCeJxnnJXfJnivfv9HEkKmNL65ftP48nVCGmqiGVurK5/XAZuovM
BXgnso3EhwEN3VEERWW2
=937q
-----END PGP SIGNATURE-----

--Signature=_Wed__23_Nov_2011_15_00_04_+1100_HwQkzJ/w/jvY0cw6--
