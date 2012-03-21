From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 1/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 09:14:12 -0700
Message-ID: <CAL1RGDVFTjsF43A9ebXwtgiuY5s1yuhFg2CRajABZ=MTeT0+Pg@mail.gmail.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com> <3f46a051-ee2e-4e18-becf-60f6c023c3c6@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3f46a051-ee2e-4e18-becf-60f6c023c3c6-nbYkmrCdWxmgMrCBcu8zE0EOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> +#define ocrdma_err(format, arg...) printk(KERN_ERR format, ##arg)

I think you'd be better off using pr_err() rather than defining your ow=
n macro.


> +struct ocrdma_cq {
> + =A0 =A0 =A0 struct ib_cq ibcq;
> + =A0 =A0 =A0 struct ocrdma_dev *dev;
> + =A0 =A0 =A0 struct ocrdma_cqe *va;
> + =A0 =A0 =A0 u32 phase;
> + =A0 =A0 =A0 u32 getp; =A0 =A0 =A0 /* pointer to pending wrs to
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* return to stack, w=
rap arounds
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* at max_hw_cqe
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 u32 max_hw_cqe;
> + =A0 =A0 =A0 bool phase_change;
> + =A0 =A0 =A0 bool armed, solicited;
> + =A0 =A0 =A0 bool arm_needed;
> +
> + =A0 =A0 =A0 spinlock_t cq_lock ____cacheline_aligned; /* provide sy=
nchronization
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* to cq polling
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 /* syncronizes cq completion handler invoked from multi=
ple context */
> + =A0 =A0 =A0 spinlock_t comp_handler_lock ____cacheline_aligned;

You have quite a few of these alignment directives in the middle of str=
uctures.
Have you measured that leaving all these gaps gives a reall performance=
 boost?

> + =A0 =A0 =A0 u16 id;
> + =A0 =A0 =A0 u16 eqn;
> +
> + =A0 =A0 =A0 struct ocrdma_ucontext *ucontext;
> + =A0 =A0 =A0 dma_addr_t pa;
> + =A0 =A0 =A0 u32 len;
> + =A0 =A0 =A0 atomic_t use_cnt;
> +
> + =A0 =A0 =A0 /* head of all qp's sq and rq for which cqes need to be=
 flushed
> + =A0 =A0 =A0 =A0* by the software.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 struct list_head sq_head, rq_head;
> +};


> +#define OCRDMA_GET_NUM_POSTED_SHIFT_VAL(qp) \
> + =A0 =A0 =A0 (((qp->dev->nic_info.dev_family =3D=3D OCRDMA_GEN2_FAMI=
LY) && \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 (qp->id < 64)) ? 24 : 16)

In general it's better to use inline functions when possible
instead of macros, which are less type-safe and harder to read.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
