From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] net/mlx4: suppress 'may be used uninitialized' warning
Date: Tue, 18 Apr 2017 10:02:19 +0300
Message-ID: <20170418070219.GA14088@mtr-leonro.local>
References: <20170418062135.76698-1-gthelen@google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="y0ulUmNC+osPPQO6"
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170418062135.76698-1-gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Apr 17, 2017 at 11:21:35PM -0700, Greg Thelen wrote:
> gcc 4.8.4 complains that mlx4_SW2HW_MPT_wrapper() uses an uninitialized
> 'mpt' variable:
>   drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'mlx4_SW2HW_MPT_wrapper':
>   drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2802:12: warning: 'mpt' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      mpt->mtt = mtt;
>
> I think this warning is a false complaint.  mpt is only used when
> mr_res_start_move_to() return zero, and in all such cases it initializes
> mpt.
> But apparently gcc cannot see that.
>
> Initialize mpt to avoid the warning.
>
> Signed-off-by: Greg Thelen <gthelen-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> ---

It looks like other callers of mr_res_start_move_to() have the same
"uninitialized" variable.

Thanks

--y0ulUmNC+osPPQO6
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlj1ufsACgkQ5GN7iDZy
WKcYaBAAqDl2pw2RUohGYSWfNig1z0ncrsIEsfurzBoAiEfgMgA21r6IrO3V1PY4
D7PKZwXVfM8E7pY5Q86FKXZ+9quKi+Lkl9xGD7+isaBLAXcZ1OwElMgP79eThV5H
VZqCXS0Nqafe+XN5JMAn/0Egi932S34m2EYlRisJBgVyrFWuQ98RxyAjOKS5NEPo
IFo5uDjkpRYv9mtPtG3WCE2bw3it9rPqHjYfrvvmtybD5Cv+vm4SnA1vG//+fA+3
7BTmYvnXhoHFh4GWWaCOZpCsv/u0fySAXP0s8WsYiZMGZTQ3kdEV35ERj1xa5bC6
3UXJvzXPl8Waes0x5T7xjCmMVPk9Tw/C1iVUzlHvSO6D7GdU/vnI7ws50BkQ2xVL
c/DG02LE455Nb5XllMGq+sEUI713mci9D7RtNpGJcrwj5Z/w88od1jEPyWYcgEtX
8Tux2XXHunSXgYfBFUJ7L65//iX+L7x2EaNegKlfs7FFONUSX3+FHQjhwnVjLEjR
e0gASQreEYvdlCFDb/geW+IompeSE8rEZoQZmXmSBmv8107yfG6dVza4oTO1vBWG
hOaLGw39zvpKn9KI7W8+a/nRX67TZYNFK6hYpXpnIuoftic8YM+mGhws7H/Ohc3E
8xz9i9vdtIVnLuna29D0SL/ctGVtPLc2MK2m5b9Rup4erVnwFPk=
=ngpP
-----END PGP SIGNATURE-----

--y0ulUmNC+osPPQO6--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
