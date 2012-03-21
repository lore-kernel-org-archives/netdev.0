From: "David Laight" <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Subject: RE: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 16:31:50 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EB4@saturn3.aculab.com>
References: <CAL1RGDVxCE--P78bk0Me5o+ekSzgBYG0UJT6y3O7cK3mUGBjuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Roland Dreier" <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-Reply-To: <CAL1RGDVxCE--P78bk0Me5o+ekSzgBYG0UJT6y3O7cK3mUGBjuQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=20
> > - Header file for userspace library and kernel driver interface.
>=20
> > +struct ocrdma_alloc_ucontext_resp {
> > + =A0 =A0 =A0 u32 dev_id;
> > + =A0 =A0 =A0 u32 wqe_size;
> > + =A0 =A0 =A0 u32 max_inline_data;
> > + =A0 =A0 =A0 u32 dpp_wqe_size;
> > + =A0 =A0 =A0 u64 ah_tbl_page;
> > + =A0 =A0 =A0 u32 ah_tbl_len;
> > + =A0 =A0 =A0 u32 rsvd;
> > + =A0 =A0 =A0 u8 fw_ver[32];
> > + =A0 =A0 =A0 u32 rqe_size;
> > + =A0 =A0 =A0 u64 rsvd1;
> > +} __packed;
>=20
> If I'm reading this correctly, you have the 8-byte rsvd1 member at an
> offset only aligned to 4 bytes, because of the __packed directive.  I=
t
> would be much better to have these structures laid out so they are
> naturally the same on both 32-bit and 64-bit ABIs, and get rid of the
> __packed directive, which wrecks gcc code generation in some cases.
>=20

gcc also supports defining types that have non-standard alignment
constraints that can be used to force the same alignment for
64bit fields between i386 and amd64.
Probably __attribute__((aligned,n)) or similar.

This can be used to force 32bit alignment in amd64 code in order
to match definitions in 32bit userspace.
=46or new things it would make sense to force 64bit alignment
of 64bit fields for 32bit code.

Adding __packed (rather than 32bit alignment) forces the compiler
to generate byte by byte accesses for all the fields on systems
that can't do misaligned accesses in hardware (eg sparc).

	David


	David


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
