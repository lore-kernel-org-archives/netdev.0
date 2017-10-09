From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the cgroup tree with the net-next tree
Date: Mon, 9 Oct 2017 19:38:36 +0100
Message-ID: <20171009183836.cceczuqytzmgqubr@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="wjfxkn52nnmtwy5g"
Cc: netdev@vger.kernel.org,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Tejun Heo <tj@kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Martin KaFai Lau <kafai@fb.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--wjfxkn52nnmtwy5g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Tejun,

Today's linux-next merge of the cgroup tree got a conflict in:

  kernel/cgroup/cgroup.c

between commit:

  324bda9e6c5ad ("bpf: multi program support for cgroup+bpf")

=66rom the net-next tree and commit:

  041cd640b2f3c ("cgroup: Implement cgroup2 basic CPU usage accounting")

=66rom the cgroup tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

diff --cc kernel/cgroup/cgroup.c
index 00f5b358aeac,c3421ee0d230..000000000000
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@@ -4765,8 -4785,9 +4788,11 @@@ static struct cgroup *cgroup_create(str
 =20
  	return cgrp;
 =20
 +out_idr_free:
 +	cgroup_idr_remove(&root->cgroup_idr, cgrp->id);
+ out_stat_exit:
+ 	if (cgroup_on_dfl(parent))
+ 		cgroup_stat_exit(cgrp);
  out_cancel_ref:
  	percpu_ref_exit(&cgrp->self.refcnt);
  out_free_cgrp:

--wjfxkn52nnmtwy5g
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlnbwisACgkQJNaLcl1U
h9A/aAf+P15l27wrdPdRSvnHl7769wnxBeFBwL+l2QkX/FwZpsEUhKQLB6eHPXLk
qO7dfn0XGGGPglm23o4JAgGafnSTlFQmBpKjQP/Id5QBuv9W7A25+zm10bjoC6lA
91V9hNyn3irmuHR1xySlF2ZfOKGfuRdM797MGoQJVbJ5hRG8KiVJj3nC/lgezkQd
o+AL55I1NYHtJqLnyTQ28/967jZP1PZu2jwZCnHIll/S4QkYU3wcyzrUTq8irvaf
NmOKxahgbIw4YfmggvSBJkpnX5CKLEblnD/x7GQpBRLRNk73+qqamTikeOx6lVvl
fP9JNIV0yFqhV+H5BM3piHpm73c0lQ==
=ZuHU
-----END PGP SIGNATURE-----

--wjfxkn52nnmtwy5g--
