From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH for-next 03/11] IB/hns: Optimize the logic of allocating
 memory using APIs
Date: Mon, 21 Nov 2016 19:14:23 +0200
Message-ID: <20161121171423.GA23083@leon.nu>
References: <20161104163633.141880-1-salil.mehta@huawei.com>
 <20161104163633.141880-4-salil.mehta@huawei.com>
 <20161109072130.GH27883@leon.nu>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A7A2371@lhreml503-mbx>
 <20161116083602.GH4240@leon.nu>
 <F4CC6FACFEB3C54C9141D49AD221F7F91A7AD7DF@lhreml503-mbx>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="BOKacYhQ+x31HxR3"
Cc: "dledford@redhat.com" <dledford@redhat.com>,
        "Huwei (Xavier)" <xavier.huwei@huawei.com>,
        oulijun <oulijun@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>,
        "Zhangping (ZP)" <zhangping5@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:59012 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753548AbcKUROa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 12:14:30 -0500
Content-Disposition: inline
In-Reply-To: <F4CC6FACFEB3C54C9141D49AD221F7F91A7AD7DF@lhreml503-mbx>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--BOKacYhQ+x31HxR3
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 21, 2016 at 04:12:38PM +0000, Salil Mehta wrote:
> > -----Original Message-----
> > From: Leon Romanovsky [mailto:leon@kernel.org]
> > Sent: Wednesday, November 16, 2016 8:36 AM
> > To: Salil Mehta
> > Cc: dledford@redhat.com; Huwei (Xavier); oulijun;
> > mehta.salil.lnk@gmail.com; linux-rdma@vger.kernel.org;
> > netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm;
> > Zhangping (ZP)
> > Subject: Re: [PATCH for-next 03/11] IB/hns: Optimize the logic of
> > allocating memory using APIs
> >
> > On Tue, Nov 15, 2016 at 03:52:46PM +0000, Salil Mehta wrote:
> > > > -----Original Message-----
> > > > From: Leon Romanovsky [mailto:leon@kernel.org]
> > > > Sent: Wednesday, November 09, 2016 7:22 AM
> > > > To: Salil Mehta
> > > > Cc: dledford@redhat.com; Huwei (Xavier); oulijun;
> > > > mehta.salil.lnk@gmail.com; linux-rdma@vger.kernel.org;
> > > > netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Linuxarm;
> > > > Zhangping (ZP)
> > > > Subject: Re: [PATCH for-next 03/11] IB/hns: Optimize the logic of
> > > > allocating memory using APIs
> > > >
> > > > On Fri, Nov 04, 2016 at 04:36:25PM +0000, Salil Mehta wrote:
> > > > > From: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
> > > > >
> > > > > This patch modified the logic of allocating memory using APIs in
> > > > > hns RoCE driver. We used kcalloc instead of kmalloc_array and
> > > > > bitmap_zero. And When kcalloc failed, call vzalloc to alloc
> > > > > memory.
> > > > >
> > > > > Signed-off-by: Wei Hu (Xavier) <xavier.huwei@huawei.com>
> > > > > Signed-off-by: Ping Zhang <zhangping5@huawei.com>
> > > > > Signed-off-by: Salil Mehta  <salil.mehta@huawei.com>
> > > > > ---
> > > > >  drivers/infiniband/hw/hns/hns_roce_mr.c |   15 ++++++++-------
> > > > >  1 file changed, 8 insertions(+), 7 deletions(-)
> > > > >
> > > > > diff --git a/drivers/infiniband/hw/hns/hns_roce_mr.c
> > > > b/drivers/infiniband/hw/hns/hns_roce_mr.c
> > > > > index fb87883..d3dfb5f 100644
> > > > > --- a/drivers/infiniband/hw/hns/hns_roce_mr.c
> > > > > +++ b/drivers/infiniband/hw/hns/hns_roce_mr.c
> > > > > @@ -137,11 +137,12 @@ static int hns_roce_buddy_init(struct
> > > > hns_roce_buddy *buddy, int max_order)
> > > > >
> > > > >  	for (i =3D 0; i <=3D buddy->max_order; ++i) {
> > > > >  		s =3D BITS_TO_LONGS(1 << (buddy->max_order - i));
> > > > > -		buddy->bits[i] =3D kmalloc_array(s, sizeof(long),
> > > > GFP_KERNEL);
> > > > > -		if (!buddy->bits[i])
> > > > > -			goto err_out_free;
> > > > > -
> > > > > -		bitmap_zero(buddy->bits[i], 1 << (buddy->max_order -
> > i));
> > > > > +		buddy->bits[i] =3D kcalloc(s, sizeof(long),
> > GFP_KERNEL);
> > > > > +		if (!buddy->bits[i]) {
> > > > > +			buddy->bits[i] =3D vzalloc(s * sizeof(long));
> > > >
> > > > I wonder, why don't you use directly vzalloc instead of kcalloc
> > > > fallback?
> > > As we know we will have physical contiguous pages if the kcalloc
> > > call succeeds. This will give us a chance to have better performance
> > > over the allocations which are just virtually contiguous through the
> > > function vzalloc(). Therefore, later has only been used as a fallback
> > > when our memory request cannot be entertained through kcalloc.
> > >
> > > Are you suggesting that there will not be much performance penalty
> > > if we use just vzalloc ?
> >
> > Not exactly,
> > I asked it, because we have similar code in our drivers and this
> > construction looks strange to me.
> >
> > 1. If performance is critical, we will use kmalloc.
> > 2. If performance is not critical, we will use vmalloc.
> >
> > But in this case, such construction shows me that we can live with
> > vmalloc performance and kmalloc allocation are not really needed.
> >
> > In your specific case, I'm not sure that kcalloc will ever fail.
> Performance is definitely critical here. Though, I agree this is bit
> unusual way of memory allocation. In actual, we were encountering
> memory alloc failures using kmalloc (if you see allocation amount
> is on the higher side and is exponential) so we ended up using
> vmalloc as fall back - It is very na=EFve allocation scheme.

I understand it, we did the same, see our mlx5_vzalloc call.
BTW, we used __GFP_NOWARN flag, which you should consider to use
in your case too.

>
> Maybe we need to rethink this allocation scheme part? Also, I can pull
> back this particular patch for now or just live with vzalloc() till
> we figure out proper solution to this?

It is up to you, I don't think that you should drop it, AFAIK, there is
no other proper solution.

>
> >
> > Thanks
> >
> >
> > >
> > > >
> > > > > +			if (!buddy->bits[i])
> > > > > +				goto err_out_free;
> > > > > +		}
> > > > >  	}

--BOKacYhQ+x31HxR3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJYMytvAAoJEORje4g2clinTq0QAI1rTTgFDyZ1s2bWcAQ02dbU
CFNb5iCoRqDR8y0C+fDRVz9fONBAP+2B7T1lY/gORIusv2JbFHL0UUWU0luXQXP3
0z9rp+dwZmUPKqyU8JgkSaw+yG0/Z4PEC/6dO9TIw4FrBOlIBZCj2GGyJx3mTisD
XfGjpSRkFacbJjgDO5UXIHZIGcNAzwGZfQ92U5Ng2Ulz4Il2USg5QYpGftsQVsFa
UTvVT4nn/k2gfhRXELtPuZ6zMQsxkMCoegqgdVqk0IAkJ0SUu3BYncTMRZBNOBAm
i2WTjI6ATFXVvIde+wUdc3kc2mtdJMpQMH+kV+47CkvasmKZsB0zP5XSd5uh3Y9Y
D3V/jA6av+AvyS2vaM8Hwh+3+spYYOq56xHJ865bIVxPBqX0hsxX4B0L3jhbk9sv
DCRyrOJ9++izmB8Oejyl+xDCvcJJcEeDK4GqaMSiJkddtUybDu3hCHHyk68A7+Ft
p+ECZihOn1+9l59rPM5Wwq6hA6Eg9i5fgtor7Aq/pt9DRoqq7x3rdCyK9YJJOyoK
gZfv52mKnDLSqTkxoegDN0OjqRgeDaUQbnfwLUDlzE6ebP2ZDLGDPv9irI1r9Ekd
CG3muPReUA4tYAAG5d+zz5kh9aBochjfQYvy4Qk3RlWNR7rPu8FsKoaevUXhqU2z
eZySHg9DajWx30k5cHR4
=Xe0n
-----END PGP SIGNATURE-----

--BOKacYhQ+x31HxR3--
