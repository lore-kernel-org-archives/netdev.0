From: <Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Thu, 22 Mar 2012 13:52:30 -0700
Message-ID: <88B766C272F2C64B944B21AD078333151C964A66EF@EXMAIL.ad.emulex.com>
References: <CAL1RGDVxCE--P78bk0Me5o+ekSzgBYG0UJT6y3O7cK3mUGBjuQ@mail.gmail.com>
 <AE90C24D6B3A694183C094C60CF0A2F6026B6EB4@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>, <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B6EB4-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Laight [mailto:David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org]
> Sent: Wednesday, March 21, 2012 10:02 PM
> To: Roland Dreier; Pandit, Parav
> Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: RE: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA
> adapter
>=20
>=20
> > > - Header file for userspace library and kernel driver interface.
> >
> > > +struct ocrdma_alloc_ucontext_resp {
> > > + =A0 =A0 =A0 u32 dev_id;
> > > + =A0 =A0 =A0 u32 wqe_size;
> > > + =A0 =A0 =A0 u32 max_inline_data;
> > > + =A0 =A0 =A0 u32 dpp_wqe_size;
> > > + =A0 =A0 =A0 u64 ah_tbl_page;
> > > + =A0 =A0 =A0 u32 ah_tbl_len;
> > > + =A0 =A0 =A0 u32 rsvd;
> > > + =A0 =A0 =A0 u8 fw_ver[32];
> > > + =A0 =A0 =A0 u32 rqe_size;
> > > + =A0 =A0 =A0 u64 rsvd1;
> > > +} __packed;
> >
> > If I'm reading this correctly, you have the 8-byte rsvd1 member at =
an
> > offset only aligned to 4 bytes, because of the __packed directive. =
 It
> > would be much better to have these structures laid out so they are
> > naturally the same on both 32-bit and 64-bit ABIs, and get rid of t=
he
> > __packed directive, which wrecks gcc code generation in some cases.
> >
>=20
> gcc also supports defining types that have non-standard alignment
> constraints that can be used to force the same alignment for 64bit fi=
elds
> between i386 and amd64.
> Probably __attribute__((aligned,n)) or similar.
>=20
> This can be used to force 32bit alignment in amd64 code in order to m=
atch
> definitions in 32bit userspace.
> For new things it would make sense to force 64bit alignment of 64bit =
fields
> for 32bit code.

o.k. so I'll use aligned attribute to align user-kernel interface data =
structure to 8 byte boundary.
That should work for 32-bit and 64-bit user and kernel space and does't=
 hurt performance either?

Driver-adapter structures will be aligned to 4 byte boundary using alig=
ned attribute instead of packed.

>=20
> Adding __packed (rather than 32bit alignment) forces the compiler to
> generate byte by byte accesses for all the fields on systems that can=
't do
> misaligned accesses in hardware (eg sparc).
>=20
> 	David
>=20
>=20
> 	David
>=20

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
