From: Leon Romanovsky <leonro@leon.nu>
Subject: Re: [PATCH 2/2] iw_cxgb4: add fast-path for small REG_MR operations
Date: Mon, 19 Sep 2016 06:28:44 +0300
Message-ID: <20160919032844.GB3273@leon.nu>
References: <cover.1474037695.git.swise@opengridcomputing.com>
 <3153440ff068cc56a517af2ba6be2b0de0f4dd99.1474037695.git.swise@opengridcomputing.com>
 <20160918142242.GJ2923@leon.nu>
 <0bd501d2120e$6bf5aaf0$43e100d0$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="K8nIJk4ghYZn606h"
Cc: dledford@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:51618 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936454AbcISD2u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 23:28:50 -0400
Content-Disposition: inline
In-Reply-To: <0bd501d2120e$6bf5aaf0$43e100d0$@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--K8nIJk4ghYZn606h
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 18, 2016 at 07:40:29PM -0500, Steve Wise wrote:
> > On Fri, Sep 16, 2016 at 07:54:52AM -0700, Steve Wise wrote:
> > > When processing a REG_MR work request, if fw supports the
> > > FW_RI_NSMR_TPTE_WR work request, and if the page list for this
> > > registration is <= 2 pages, and the current state of the mr is INVALID,
> > > then use FW_RI_NSMR_TPTE_WR to pass down a fully populated TPTE for
> > FW
> > > to write.  This avoids FW having to do an async read of the TPTE
> blocking
> > > the SQ until the read completes.
> > >
> > > To know if the current MR state is INVALID or not, iw_cxgb4 must track
> the
> > > state of each fastreg MR.  The c4iw_mr struct state is updated as REG_MR
> > > and LOCAL_INV WRs are posted and completed, when a reg_mr is
> > destroyed,
> > > and when RECV completions are processed that include a local
> invalidation.
> > >
> > > This optimization increases small IO IOPS for both iSER and NVMF.
> > >
> > > Signed-off-by: Steve Wise <swise@opengridcomputing.com>
> > > ---
> >
> > <...>
> >
> > > +			      struct ib_reg_wr *wr, struct c4iw_mr *mhp,
> > > +			      u8 *len16)
> > > +{
> > > +	__be64 *p = (__be64 *)fr->pbl;
> > > +
> > > +	fr->r2 = cpu_to_be32(0);
> >
> > Is there any difference between the line above and "fr->r2 = 0"?
>
> It makes sparse happy, IIRC...

Strange, but ok :)

>
>
>

--K8nIJk4ghYZn606h
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX31tsAAoJEORje4g2clinBWkP/3z5/CP0yzxktMYhmO8LIOXW
N1YCt9dqNY0jovXzQgcRau4aMAbymwiCw6S4p+s70kKKkcx8l2xmNWBUqoBb22r3
F5r6sB4A6CCWoBAp0//uSEtsLQemjA6Ykmdpeqe3mbzq4+7HO0ncp6OsHxgqQd8U
s21Cb30pSNP4KrDpAeCQ7E+YCqpuL8H9woXBOxn2ily6NTjx6Sz7eDkZdj9K4Q9w
HqhEWGP/5OizHRf0D6yWIYrvU5yFNdmzyP76rnseMz5vjWbDIvDovyH2/GRZRwIr
1N4mUSu5dM/yny/R8mlOSKXpX21xoofZzxpb7MH4jLSOWxHfuhj/2f2Mc+NlkFk7
LLx+DgfB/nzylXeqMaltSns59TCP41lQG8c7TKGmklyoVqK6wIH5M5anTDRFmdSj
bjdljZpr0P00ZBPuxBooC+M8TJlrexCK7j9RI7TzKh+KkV2AGMmNNmHCXhVhQwel
FzRHw6MauNf1pI2RseY5Yt7DcH3o22rrKK4jwsIVBTqo/q+qlKJoBJuW9UVzl+RG
UxYShK1M2yLrFC1E+7/+lu9YJAq3Qb257E/vVxGedFnZu1yruIZyLD7ZvILtjzB9
F9XKsSY2LOjDheVzuM0qPPC2ScGu0ealblsEs+iDBEW71dLaCYazFF87NcCptJC6
WXsK0/iz2A3ysA/7yGLF
=im+3
-----END PGP SIGNATURE-----

--K8nIJk4ghYZn606h--
