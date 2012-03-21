From: <Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH 6/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 12:10:20 -0700
Message-ID: <88B766C272F2C64B944B21AD078333151C964A63FF@EXMAIL.ad.emulex.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-2-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-3-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-4-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-5-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-6-git-send-email-parav.pandit@emulex.com>
 <5abe3043-81f8-448a-9e55-b29e23f4eb9a@exht1.ad.emulex.com>
 <CAL1RGDVv6y-EOiNv-Vmd+jN1dnSPvA0YK_kamYZwmgUzRmUx=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDVv6y-EOiNv-Vmd+jN1dnSPvA0YK_kamYZwmgUzRmUx=g@mail.gmail.com>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Roland Dreier [mailto:roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org]
> Sent: Wednesday, March 21, 2012 10:13 PM
> To: Pandit, Parav
> Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH 6/9] ocrdma: Driver for Emulex OneConnect RDMA
> adapter
>=20
> > +struct ib_pd *ocrdma_alloc_pd(struct ib_device *ibdev,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ib=
_ucontext *context,
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct ib=
_udata *udata) {
> > + =A0 =A0 =A0 struct ocrdma_dev *dev =3D get_ocrdma_dev(ibdev);
> > + =A0 =A0 =A0 struct ocrdma_pd *pd;
> > + =A0 =A0 =A0 int status;
> > +
> > + =A0 =A0 =A0 pd =3D kzalloc(sizeof(*pd), GFP_KERNEL);
> > + =A0 =A0 =A0 if (!pd)
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ERR_PTR(-ENOMEM);
> > + =A0 =A0 =A0 pd->dev =3D dev;
> > + =A0 =A0 =A0 if (udata && context) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pd->dpp_enabled =3D (dev->nic_info.de=
v_family =3D=3D
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 OCRDMA_GEN2_FAMILY) ? true :
> > + false;
>=20
> Writing
>=20
>     (<bool expr>) ? true : false
>=20
> is pretty silly, since it's just an obfuscated way of writing
>=20
>     <bool expr>
>=20
> IOW, you can just write
>=20
>      pd->dpp_enabled =3D (dev->nic_info.dev_family =3D=3D
> OCRDMA_GEN2_FAMILY);
>=20
>=20
> > +int ocrdma_dealloc_pd(struct ib_pd *ibpd) {
> > + =A0 =A0 =A0 struct ocrdma_pd *pd =3D get_ocrdma_pd(ibpd);
> > + =A0 =A0 =A0 struct ocrdma_dev *dev =3D pd->dev;
> > + =A0 =A0 =A0 int status;
> > + =A0 =A0 =A0 u64 usr_db;
> > +
> > + =A0 =A0 =A0 if (atomic_read(&pd->use_cnt)) {
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 ocrdma_err("%s(%d) pd=3D0x%x is in us=
e.\n",
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, dev-=
>id, pd->id);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 status =3D -EFAULT;
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto dealloc_err;
> > + =A0 =A0 =A0 }
>=20
> all of the use_cnt tracking in this driver seems to duplicate what th=
e rdma
> midlayer already does... is there any reason we need that in the low-=
level
> hardware driver too, or can we just get rid of the various use_cnt me=
mbers?

This use_cnt can be removed from low-level hardware driver. I'll remove=
 it.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
