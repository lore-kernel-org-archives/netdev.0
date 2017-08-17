From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2] i40e/i40evf: use cpumask_copy() for assigning cpumask
Date: Wed, 16 Aug 2017 17:24:31 -0700
Message-ID: <1502929471.32783.2.camel@intel.com>
References: <20170816175257.9647-1-jgross@suse.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-UPWIh3R7uaHWIDYQGnkZ"
Cc: stable@vger.kernel.org
To: Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816175257.9647-1-jgross@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-UPWIh3R7uaHWIDYQGnkZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2017-08-16 at 19:52 +0200, Juergen Gross wrote:
> Using direct assignment for a cpumask is wrong, cpumask_copy() should
> be used instead.
>=20
> Otherwise crashes like the following might happen:
>=20
> [62792.326374] BUG: unable to handle kernel paging request at
> ffff8800049ff000
> [62792.340118] IP: [<ffffffffa2043341>]
> i40e_irq_affinity_notify+0x11/0x20 [i40e]
> ...
> [62792.810770] Call Trace:
> [62792.815722]  [<ffffffff810d77a5>] irq_affinity_notify+0xb5/0xf0
> [62792.827593]  [<ffffffff8109593e>] process_one_work+0x14e/0x410
> [62792.839282]  [<ffffffff81096196>] worker_thread+0x116/0x490
> [62792.850459]  [<ffffffff8109b667>] kthread+0xc7/0xe0
> [62792.860255]  [<ffffffff816094bf>] ret_from_fork+0x3f/0x70
> [62792.871996] DWARF2 unwinder stuck at ret_from_fork+0x3f/0x70
>=20
> Fixes: 96db776a3682 ("i40e/i40evf: fix interrupt affinity bug")
> Cc: <stable@vger.kernel.org> # 4.10+
> Signed-off-by: Juergen Gross <jgross@suse.com>
> ---
> V2: enhance commit message, merge patches
> ---
>  drivers/net/ethernet/intel/i40e/i40e_main.c     | 2 +-
>  drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)

This is already resolved with a previous patch from Jacob Keller, see
the following commit in my tree:

commit f15ac286b0d111499e0fec4b50c8c870ad3b4573
Author: Jacob Keller <jacob.e.keller@intel.com>
Date:   Wed Aug 16 17:12:00 2017 -0700

    i40e: use cpumask_copy instead of direct assignment
   =20
    According to the header file cpumask.h, we shouldn't be directly
copying
    a cpumask_t, since its a bitmap and might not be copied correctly.
Lets
    use the provided cpumask_copy() function instead.
   =20
    Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
--=-UPWIh3R7uaHWIDYQGnkZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlmU4j8ACgkQ5W/vlVpL
7c4c1BAAoq3+4Dg6nuD1L8NgFQQDKbo7rnhxL1Gm4P0ZnsfYvSb1k07IeBhJK9Hd
8GvdVGDiSMOUqnLntlU5nwDxMl79cFv23lnMtGQrHYTeyZs8psINBrZkB0O6BxuP
K30/y7l16R15RnTW9VeZu2PFygkRXAUt9PzB1pbAu46iuzK1s09iPSknMiGGIYmI
Mww7+VUt8eE4MYjU5kD+AhxafN8/WV0tfxW/vpMa+iqDY3XWlWC60XRnUTCMMYZf
PXT1n7odBwOieG+YaAi0CJy0fQK4E5PRYQgVpiVR6EKtxvWY53r5Z50huR/4T1nJ
cnC+MRIAPnYJzJe+oTMuL/AdjSCuDX7V0RyaqLRZZ0ceYM3KeE/k4xgwlYle3s+7
aBnSru1cEU4SXxFHhlp5MVcUWtSNQbWdBlNQN2+4F3Bg4YAi21L6HyMQJgQCWL3z
MOG8RLK+DpZJJgkvZkIDEk/SarZdQDKrdGkvxk5CyF+YQW9a5AdDe/CSHoMRwLEK
Gtqc3XBPXIYkVqgU0aupVcywy2wsbRrNpPIx2uRgfw0RJvrFdKWq5nvYA8b8HhfK
Wojvkp9pcGT+Q0tZQ0Ycz7ti1XSCn2Kcxe8dldjkGKgOS3HfR5UBlQHagRH47s5H
wgSmY99mlihSugq4x7iqnFcoz1kixdRP8UimgIp/yM2erGsovQs=
=Ci1q
-----END PGP SIGNATURE-----

--=-UPWIh3R7uaHWIDYQGnkZ--
