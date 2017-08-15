From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v4 iproute2 2/7] rdma: Add dev object
Date: Tue, 15 Aug 2017 20:46:54 +0300
Message-ID: <20170815174653.GX24282@mtr-leonro.local>
References: <20170815130020.29509-1-leonro@mellanox.com>
 <20170815130020.29509-3-leonro@mellanox.com>
 <20170815091205.2c39ea91@xeon-e3>
 <063D6719AE5E284EB5DD2968C1650D6DD005604E@AcuExch.aculab.com>
 <20170815164720.GV24282@mtr-leonro.local>
 <063D6719AE5E284EB5DD2968C1650D6DD005613D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="wJeYCwfJgfFvSPOo"
Cc: 'Stephen Hemminger' <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD005613D-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--wJeYCwfJgfFvSPOo
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 15, 2017 at 05:00:54PM +0000, David Laight wrote:
> From: Leon Romanovsky
> > Sent: 15 August 2017 17:47
> > On Tue, Aug 15, 2017 at 04:23:11PM +0000, David Laight wrote:
> > > From: Stephen Hemminger
> > > > Sent: 15 August 2017 17:12
> > > > On Tue, 15 Aug 2017 16:00:15 +0300
> > > > Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> wrote:
> > > >
> > > > > +
> > > > > +static const char *dev_caps_to_str(uint32_t idx)
> > > > > +{
> > > > > +	uint64_t cap = 1 << idx;
> > > > > +
> > > > > +	switch (cap) {
> > > > > +	case RDMA_DEV_RESIZE_MAX_WR: return "RESIZE_MAX_WR";
> > > > > +	case RDMA_DEV_BAD_PKEY_CNTR: return "BAD_PKEY_CNTR";
> > > ...
> > > > > +	case RDMA_DEV_RAW_SCATTER_FCS: return "RAW_SCATTER_FCS";
> > > > > +	case RDMA_DEV_RDMA_NETDEV_OPA_VNIC: return "RDMA_NETDEV_OPA_VNIC";
> > > > > +	default: return "UNKNOWN";
> > > > > +	}
> > > >
> > > > Could this be a table in future versions?
> > >
> > > Potentially you could define the constants using some pre-processor
> > > 'magic' that would create the table for you.
> > > Something like (but not compiled):
> > >
> > > #define RDMA_DEV_FLAGS(x) \
> > > 	x(RESIZE_MAX_WR, 0) \
> > > 	x(BAD_PKEY_CNTR, 1) \
> > > (continue for all the bits)
> > >
> > > #define RDMA_DEV_ENUM(name, bit_no) RDMA_DEV_##name = BIT(bit_no),
> > > enum {RDMA_DEV_FLAGS(RDMA_DEV_ENUM)};
> > > #undef RDMA_DEV_ENUM
> > >
> > > #define RDMA_DEV_NAMES(name, bit_no) [bit_no] = #name,
> > > static const char rdma_dev_names[] = {RDMA_DEV_FLAGS(RDMA_DEV_NAMES)};
> I missed the #undef
> > >
> >
> > David,
> >
> > How should I handle "uknown" fields without names?
>
> The function that accesses rdma_dev_names[] checks ARRAY_SIZE()
> and for a NULL pointer.

Thanks, I'll definitely try it.

>
> WRT the other comment, the spare pointers consume far less space than
> the code for your switch statement.

I don't think that space is matter for this tool.

>
> 	David
>

--wJeYCwfJgfFvSPOo
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmTM40ACgkQ5GN7iDZy
WKfJ7RAAs/xyWh2cRmysQN6U36j9HKeoR0qPWRGVTblqtfik2hCCGMbr++C5wYWP
w+5hJDI0sNiZgQLUFikX0CEdnbd3+2uKogWjDtKiHYPMWaQPN4RlHteopSfhkwkP
+WMH3RK3v4uHHs2OGJ3+b9O0JG+eQjFn7OsCdqaBFPprytnky6rouK3fDArxY8XC
5MyWHj5fZvCUXDhGRJ1xkFciAihKooDL8Q7N4ds3GCAtyVwafnpPtqsdr9W+0ZNg
8wNn7CD4mPyRHDR9ZC5/l14gaBaweG4VnjvdyrhmYY73JLn9zl/1YqdIJ6ia/Yj0
jAtY0RSmvdphIogpixCGm8duvcVHMAlvfCcMuynCjMeiavCGckbb776fxfe2XJGO
ollRwdpKj6dMtSpPsC7sXH/ZFTVBFJGjl6zWo608P03OETgQ8PIZ50Xd55fAntkX
g1foh9TXnSZnmCynbd+XRv7oVRkKqx0sEPSW39btv4vGXndIQUgbXjatdUv5BbxS
plvxOCCHJIOzm8UAHVh4wE5TBC1BAfrzzhdpFO/7A97nhN94pNsrpXMScEMg7how
OrXB4wkkR4uUgYUr1McOd3+JI8g3dnCXeOn+VqkhKrqE46J7zQfUjj4DoxXa12Ux
TcqykJ5XsblNJoqRr2i/r6IptHedXh09fcWDngXymTDxO8aBVvY=
=vSjw
-----END PGP SIGNATURE-----

--wJeYCwfJgfFvSPOo--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
