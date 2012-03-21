From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 1/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 09:45:49 -0700
Message-ID: <CAL1RGDVoJVLOLu3CkCh_1eKJw==9ixiE5a1h5hvnZahJUsKcYg@mail.gmail.com>
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

On Tue, Mar 20, 2012 at 3:39 PM,  <parav.pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org> wrote:
> +struct ocrdma_queue_info {
> + =A0 =A0 =A0 void *va;
> + =A0 =A0 =A0 dma_addr_t dma;
> + =A0 =A0 =A0 u32 size;
> + =A0 =A0 =A0 u16 len;
> + =A0 =A0 =A0 u16 entry_size; =A0 =A0 =A0 =A0 /* Size of an element i=
n the queue */
> + =A0 =A0 =A0 u16 id; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* qid, where t=
o ring the doorbell. */
> + =A0 =A0 =A0 u16 head, tail;
> + =A0 =A0 =A0 bool created;
> + =A0 =A0 =A0 atomic_t used; =A0 =A0 =A0 =A0 =A0/* Number of valid el=
ements in the queue */
> +};

=46orgot to mention this before... the only place the used member is to=
uched
that I can find is

> +static inline void ocrdma_mq_inc_head(struct ocrdma_dev *dev)
> +{
> +	dev->mq.sq.head =3D (dev->mq.sq.head + 1) & (OCRDMA_MQ_LEN - 1);
> +	atomic_inc(&dev->mq.sq.used);
> +}

but I don't see anywhere that it gets read.  Can "used" be deleted?

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
