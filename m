From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH for-next 03/11] IB/hns: Optimize the logic of allocating
 memory using APIs
Date: Wed, 16 Nov 2016 10:36:02 +0200
Message-ID: <20161116083602.GH4240@leon.nu>
References: <20161104163633.141880-1-salil.mehta@huawei.com>
 <20161104163633.141880-4-salil.mehta@huawei.com>
 <20161109072130.GH27883@leon.nu>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A7A2371@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="byLs0wutDcxFdwtm"
Cc: "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Huwei (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linuxarm <linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        "Zhangping (ZP)" <zhangping5-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A7A2371@lhreml503-mbx>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--byLs0wutDcxFdwtm
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Nov 15, 2016 at 03:52:46PM +0000, Salil Mehta wrote:
> > -----Original Message-----
> > From: Leon Romanovsky [mailto:leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org]
> > Sent: Wednesday, November 09, 2016 7:22 AM
> > To: Salil Mehta
> > Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; Huwei (Xavier); oulijun;
> > mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org;
> > netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; Linuxarm;
> > Zhangping (ZP)
> > Subject: Re: [PATCH for-next 03/11] IB/hns: Optimize the logic of
> > allocating memory using APIs
> >
> > On Fri, Nov 04, 2016 at 04:36:25PM +0000, Salil Mehta wrote:
> > > From: "Wei Hu (Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> > >
> > > This patch modified the logic of allocating memory using APIs in
> > > hns RoCE driver. We used kcalloc instead of kmalloc_array and
> > > bitmap_zero. And When kcalloc failed, call vzalloc to alloc
> > > memory.
> > >
> > > Signed-off-by: Wei Hu (Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> > > Signed-off-by: Ping Zhang <zhangping5-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> > > Signed-off-by: Salil Mehta  <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> > > ---
> > >  drivers/infiniband/hw/hns/hns_roce_mr.c |   15 ++++++++-------
> > >  1 file changed, 8 insertions(+), 7 deletions(-)
> > >
> > > diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c
> > b/drivers/infiniband/hw/hns/hns_roce_mr.c
> > > index fb87883..d3dfb5f 100644
> > > --- a/drivers/infiniband/hw/hns/hns_roce_mr.c
> > > +++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
> > > @@ -137,11 +137,12 @@ static int hns_roce_buddy_init(struct
> > hns_roce_buddy *buddy, int max_order)
> > >
> > >  	for (i = 0; i <= buddy->max_order; ++i) {
> > >  		s = BITS_TO_LONGS(1 << (buddy->max_order - i));
> > > -		buddy->bits[i] = kmalloc_array(s, sizeof(long),
> > GFP_KERNEL);
> > > -		if (!buddy->bits[i])
> > > -			goto err_out_free;
> > > -
> > > -		bitmap_zero(buddy->bits[i], 1 << (buddy->max_order - i));
> > > +		buddy->bits[i] = kcalloc(s, sizeof(long), GFP_KERNEL);
> > > +		if (!buddy->bits[i]) {
> > > +			buddy->bits[i] = vzalloc(s * sizeof(long));
> >
> > I wonder, why don't you use directly vzalloc instead of kcalloc
> > fallback?
> As we know we will have physical contiguous pages if the kcalloc
> call succeeds. This will give us a chance to have better performance
> over the allocations which are just virtually contiguous through the
> function vzalloc(). Therefore, later has only been used as a fallback
> when our memory request cannot be entertained through kcalloc.
>
> Are you suggesting that there will not be much performance penalty
> if we use just vzalloc ?

Not exactly,
I asked it, because we have similar code in our drivers and this
construction looks strange to me.

1. If performance is critical, we will use kmalloc.
2. If performance is not critical, we will use vmalloc.

But in this case, such construction shows me that we can live with
vmalloc performance and kmalloc allocation are not really needed.

In your specific case, I'm not sure that kcalloc will ever fail.

Thanks


>
> >
> > > +			if (!buddy->bits[i])
> > > +				goto err_out_free;
> > > +		}
> > >  	}

--byLs0wutDcxFdwtm
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYLBpyAAoJEORje4g2clinZ2oQALLtkDZTqMxHY+Xpg/h21s64
pXMMJn5VTWjmbuX56DfLbCx6/Y3IsPkKNRTfKgID4gNOH7evAupcsiw5gCoSn5nv
2yg8GV3APeu4CunK3/m1kJ3zNexWYOne81gE7dz9IGkKnY+Q2m9rCUDYo+HMV5NN
Fpq5qVpm3VRU1NfD/JKdgSjHpIp/a0dMIyuU0L5LFm7sZO0yxh1kl3qgDPy72+dJ
Qwyj8cv1caNsopLMHx0VLiYvU7Cy6DOeWIvtxRheradJdIalAK37U9bd9OFEEUN4
9YWIhsjPABdsBTRZ87rOz3DZ9Eqnr5Xq1HuJoiRBBnmkGfl0ZM8IWqCoROdGZF1e
lTHkFsBesTnf8VjW+oEifJD07hu6c1hyZbofXzhYCFaZxO7XPODK0ZPcoRP0aN/3
A4ovS6J+kj5AC0vXonFK1xhc5yw4qVV4kWx3k68zJXfWwxeArMMTys5hidwR5nR5
knMy0eo6KwrgKrd+zBE0KDCWk6OT0n/zykV9YxPfV50Uif58zEeZ6IZWV5Jwicba
Hlk3o8Qd6VHq3W5L0zmSgGj3X5hl8pFOmKkJClWozxhRmx1XkNQby+MKuErjS5f/
6lY+9dqs1aF+oWpfWLR0QVtBsnQZLSEnwV+lUE9awNldRQASuOoTrbZ8wTmY2Mos
n3ilokFY4xOnDYsm9K7O
=0xu+
-----END PGP SIGNATURE-----

--byLs0wutDcxFdwtm--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
