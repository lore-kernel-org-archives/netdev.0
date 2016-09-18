From: Leon Romanovsky <leonro@leon.nu>
Subject: Re: [PATCH 2/2] iw_cxgb4: add fast-path for small REG_MR operations
Date: Sun, 18 Sep 2016 17:22:42 +0300
Message-ID: <20160918142242.GJ2923@leon.nu>
References: <cover.1474037695.git.swise@opengridcomputing.com>
 <3153440ff068cc56a517af2ba6be2b0de0f4dd99.1474037695.git.swise@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="hl1kWnBARzJiTscN"
Cc: dledford@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:60610 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755675AbcIROWr (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 10:22:47 -0400
Content-Disposition: inline
In-Reply-To: <3153440ff068cc56a517af2ba6be2b0de0f4dd99.1474037695.git.swise@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--hl1kWnBARzJiTscN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Sep 16, 2016 at 07:54:52AM -0700, Steve Wise wrote:
> When processing a REG_MR work request, if fw supports the
> FW_RI_NSMR_TPTE_WR work request, and if the page list for this
> registration is <= 2 pages, and the current state of the mr is INVALID,
> then use FW_RI_NSMR_TPTE_WR to pass down a fully populated TPTE for FW
> to write.  This avoids FW having to do an async read of the TPTE blocking
> the SQ until the read completes.
>
> To know if the current MR state is INVALID or not, iw_cxgb4 must track the
> state of each fastreg MR.  The c4iw_mr struct state is updated as REG_MR
> and LOCAL_INV WRs are posted and completed, when a reg_mr is destroyed,
> and when RECV completions are processed that include a local invalidation.
>
> This optimization increases small IO IOPS for both iSER and NVMF.
>
> Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> ---

<...>

> +			      struct ib_reg_wr *wr, struct c4iw_mr *mhp,
> +			      u8 *len16)
> +{
> +	__be64 *p = (__be64 *)fr->pbl;
> +
> +	fr->r2 = cpu_to_be32(0);

Is there any difference between the line above and "fr->r2 = 0"?

--hl1kWnBARzJiTscN
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX3qMxAAoJEORje4g2clinH4IQAICs1KcWkf6ez3uvghOp2cLo
wuyfYJpLh2QCP38X7EWYaMC9Go6NqsqiBSHu9ht6cGO1h2E7HGUi7lTVpDXheh2i
0dq1nbhho8UwrJ46bksdlNcny+1EABXfDiVDa8IVrnhCtUNEzRlrxM/TfQz8O5PY
lw1anGZAf9OaxbugS5sKDnvOqrEF6Fjz/rxmq4DS+/WywbGgo4mUDAB3ZT5K06+I
i1yFswgk5WqGysIIHyny2dewlm84lEPqFHyA/xAvQKzqIsiYaOwVTY7iwRhp2WCj
6aokURqm70MFSKvk5KjgYKLSBD0mRbUpj6GOdNTDRdhorWGB66i272W5BVXKarTm
TmrMxpfqmSQWnIMCW6+1gqxok9JsF+KoHBWjUhk/WOnUO8z1JJ9NS51G7cCPs9Bn
tPSFutoWcA/BMMl3QvMMyzk3JiOFDfg8HNMM//NGDgF1NSYtcyhm6hdkH/jt5thJ
V18LR5AZtNEbQ6GeforcSCKd/E2kBvK3Obbb2MiZatPu7Ih2HjQEEEBVBozCIDDM
o7rYrIO/M9U/xcXCf46WsL+IcEzQ3Kou4WBVLW7xAV+MzQ+3DtKi/Xyu1IYa9Dg8
BR7JsoFoWD/JIWFaPLlRnr4crQm2cm0qOfk2SnHjzfQfeUdPjquYL7G1DfK0Q1dC
876eYWwedMMBHD2KgLA/
=8vdJ
-----END PGP SIGNATURE-----

--hl1kWnBARzJiTscN--
