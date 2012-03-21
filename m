From: <Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH 3/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 12:04:58 -0700
Message-ID: <88B766C272F2C64B944B21AD078333151C964A63F1@EXMAIL.ad.emulex.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-2-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-3-git-send-email-parav.pandit@emulex.com>
 <339d9e05-38fd-45b1-83ed-f06277bd1326@exht1.ad.emulex.com>
 <CAL1RGDWnc478=ToFQEC51Usn6LLZgLen=CymFZ0C0GnRp9BAsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDWnc478=ToFQEC51Usn6LLZgLen=CymFZ0C0GnRp9BAsw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Roland Dreier [mailto:roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org]
> Sent: Wednesday, March 21, 2012 9:56 PM
> To: Pandit, Parav
> Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH 3/9] ocrdma: Driver for Emulex OneConnect RDMA
> adapter
>=20
> > +/* mailbox cmd response */
> > +struct ocrdma_mbx_rsp {
> > + =A0 =A0 =A0 u32 subsys_op;
> > + =A0 =A0 =A0 u32 status;
> > + =A0 =A0 =A0 u32 rsp_len;
> > + =A0 =A0 =A0 u32 add_rsp_len;
> > +} __packed;
>=20
> ...similar comments about only using __packed where you really need i=
t...
This pack is required as it is shared with hardware and need to be of 1=
6 bytes for 32 and 64 bit architecture. Do not wanted to take risk of d=
ifferent compiler versions. So keeping it packed.

>=20
> > +#define is_cqe_valid(cq, cqe) \
> > + =A0 =A0 =A0 (((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE=
_VALID)\
> > + =A0 =A0 =A0 =3D=3D cq->phase) ? 1 : 0)
> > +#define is_cqe_for_sq(cqe) \
> > + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_=
QTYPE) ?
> > +0 : 1) #define is_cqe_for_rq(cqe) \
> > + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_=
QTYPE) ?
> > +1 : 0) #define is_cqe_invalidated(cqe) \
> > + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) &
> > +OCRDMA_CQE_INVALIDATE) ? \
> > + =A0 =A0 =A0 1 : 0)
> > +#define is_cqe_imm(cqe) \
> > + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) & OCRDMA_CQE_=
IMM) ? 1
> > +: 0) #define is_cqe_wr_imm(cqe) \
> > + =A0 =A0 =A0 ((le32_to_cpu(cqe->flags_status_srcqpn) &
> > +OCRDMA_CQE_WRITE_IMM) ? 1 : 0)
>=20
> ...similar comment about using readable typesafe inline functions ins=
tead of
> macros...

Yes, I'll change to inline function.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
