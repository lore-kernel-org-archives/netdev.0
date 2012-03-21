From: <Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 12:02:45 -0700
Message-ID: <88B766C272F2C64B944B21AD078333151C964A63ED@EXMAIL.ad.emulex.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-2-git-send-email-parav.pandit@emulex.com>
 <24c5b654-d6a5-418d-8187-fba4ad47a3ce@exht1.ad.emulex.com>
 <CAL1RGDVxCE--P78bk0Me5o+ekSzgBYG0UJT6y3O7cK3mUGBjuQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDVxCE--P78bk0Me5o+ekSzgBYG0UJT6y3O7cK3mUGBjuQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I see couple of comments on rsvd words.
They were primarily not introduced for alignment. But there are other n=
ew features that we will be adding with new set of hardware and firmwar=
e updates.
I don't want to change the user-kernel interface at such stage by modif=
ying the size of the structure.
=46or some features its under testing stage internally.=20
So once its ready rsvd will be replaced with actual element.
This will avoid abi compatibility issues between library and driver.

I'll consider alignment macro too so that compiler related byte alignme=
nt access issue also gets resolved.

Parav

> -----Original Message-----
> From: Roland Dreier [mailto:roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org]
> Sent: Wednesday, March 21, 2012 9:50 PM
> To: Pandit, Parav
> Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH 2/9] ocrdma: Driver for Emulex OneConnect RDMA
> adapter
>=20
> On Tue, Mar 20, 2012 at 3:39 PM,  <parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org> wrote:
> > From: Parav Pandit <parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org>
> >
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
> If I'm reading this correctly, you have the 8-byte rsvd1 member at an=
 offset
> only aligned to 4 bytes, because of the __packed directive.  It would=
 be much
> better to have these structures laid out so they are naturally the sa=
me on
> both 32-bit and 64-bit ABIs, and get rid of the __packed directive, w=
hich
> wrecks gcc code generation in some cases.
>=20
> In this particular case, it seems you could just move rqe_size into t=
he slot
> where rsvd is, and get rid of rsvd1?
>=20
> > +/* user kernel communication data structures. */ struct
> > +ocrdma_alloc_pd_ureq {
> > + =A0 =A0 =A0 u64 rsvd1;
> > +} __packed;
>=20
> Similar comment -- __packed is silly for a structure with one reserve=
d
> member (and which you don't seem to use anywhere)... why not just del=
ete
> this struct?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
