From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V5 for-next 16/21] RDMA/bnxt_re: Support poll_cq verb
Date: Mon, 13 Feb 2017 07:45:47 +0200
Message-ID: <20170213054547.GL14015@mtr-leonro.local>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
 <1486725593-9872-17-git-send-email-selvin.xavier@broadcom.com>
 <20170212143051.GD14015@mtr-leonro.local>
 <CA+sbYW36txPueFBWFOWigHu_XmnTPY+-Vdu5MmGeOQ7uFjrWag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="pFej7zHSL6C5fFIz"
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Eddie Wai <eddie.wai-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Devesh Sharma <devesh.sharma-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Somnath Kotur <somnath.kotur-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
        Sriharsha Basavapatna <sriharsha.basavapatna-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Selvin Xavier <selvin.xavier-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+sbYW36txPueFBWFOWigHu_XmnTPY+-Vdu5MmGeOQ7uFjrWag-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--pFej7zHSL6C5fFIz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Feb 13, 2017 at 10:47:10AM +0530, Selvin Xavier wrote:
> On Sun, Feb 12, 2017 at 8:00 PM, Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> >> +static u8 __rc_to_ib_wc_status(u8 qstatus)
> >> +{
> >> +     switch (qstatus) {
> >> +     case CQ_RES_RC_STATUS_OK:
> >> +             return IB_WC_SUCCESS;
> >> +     case CQ_RES_RC_STATUS_LOCAL_ACCESS_ERROR:
> >> +             return IB_WC_LOC_ACCESS_ERR;
> >> +     case CQ_RES_RC_STATUS_LOCAL_LENGTH_ERR:
> >> +             return IB_WC_LOC_LEN_ERR;
> >> +     case CQ_RES_RC_STATUS_LOCAL_PROTECTION_ERR:
> >> +             return IB_WC_LOC_PROT_ERR;
> >> +     case CQ_RES_RC_STATUS_LOCAL_QP_OPERATION_ERR:
> >> +             return IB_WC_LOC_QP_OP_ERR;
> >> +     case CQ_RES_RC_STATUS_MEMORY_MGT_OPERATION_ERR:
> >> +             return IB_WC_GENERAL_ERR;
> >> +     case CQ_RES_RC_STATUS_REMOTE_INVALID_REQUEST_ERR:
> >> +             return IB_WC_REM_INV_REQ_ERR;
> >> +     case CQ_RES_RC_STATUS_WORK_REQUEST_FLUSHED_ERR:
> >> +             return IB_WC_WR_FLUSH_ERR;
> >> +     case CQ_RES_RC_STATUS_HW_FLUSH_ERR:
> >> +             return IB_WC_WR_FLUSH_ERR;
> >> +     default:
> >> +             return IB_WC_GENERAL_ERR;
> >> +     }
> >> +}
> >> +
> >
> > Why don't you use these defines directly?
>
> CQ_RES* values are returned by the HW and these values are
> different from the corresponding IB_WC status values.   say,
> CQ_RES_RC_STATUS_HW_FLUSH_ERR is 8 where as
> IB_WC_WR_FLUSH_ERR is 5.
> So we thought it is better to map these values in a function rather
> than having a switch/case in the calling function.
>
> Let me know if you meant something different in your query.

Thanks,
This from_u8 -> to_u8 conversion confused me, because of our similar
function mlx5_handle_error_cqe() which updates wc->status at the same
time as it is called. So I expected to see something similar in your code
where you fill wc.

Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--pFej7zHSL6C5fFIz
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlihSAsACgkQ5GN7iDZy
WKe0RA/9Gtakup4iePDD/d99fzP/3vf6mdllv+nSjoUeT122OLH4/VfvIyAVs/Eh
crq6R3B58arwh2ZFnOk1N+tGQh5Gu/PzDRcdWvYpAvuo81Z1W9Qq38zsRuqRQLqS
1Umo4Z4TigPcfXZhdT1A49dPIyn7RM2R1hvA1I+gCINW89cTWIVyYOL+s7Q65r7P
xLsGB0dxBnVLu11yHAMtuax7QOlM2iGDU59mRi2tf0Ro5MRAJvz1WseVZ/FHyYIr
byzKg8LcRb0aXyJI5/zWYGkPfRAZDOk6HjeAH0lWuR+qVM3awrDZfWIRy41W8aBc
BJ32Jc9lK7QOYg4zCj0Cuu61fzBuIaa6VYe3jUAHlEYmb120fhC0kaOdTT7GHQ6H
ZNmXVVflogNh/yEwey11Zwav4Jfd/NqpfQ0g+PcHgbHYkVuNhZBNUIzdF8BnQRRo
C8GEEC2t1IYV3Q1di/btXyeQ8Hz49LsNsqCrfrUnshIMbCMn55b6JJhYHPYR0J2R
UG9Th0qmRTUfpIAbLGQ7EivQ+F+Lu3ZHSlLczs5JO6A2IzXRhm5xPUNJLy9QKeBu
NXSk8JKllDbZTtx7hnYEALr3bAzttrJ8MZvleVMjsoEyO1AU3L2bkQAkTlqUshLs
NXgKboFV1sc6Of2zlzQycQZA3LrfBVDYrZdKQyd5DAuMajcrhsc=
=btzf
-----END PGP SIGNATURE-----

--pFej7zHSL6C5fFIz--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
