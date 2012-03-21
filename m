From: <Parav.Pandit-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>
Subject: RE: [PATCH 4/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 12:46:51 -0700
Message-ID: <88B766C272F2C64B944B21AD078333151C964A6415@EXMAIL.ad.emulex.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-2-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-3-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-4-git-send-email-parav.pandit@emulex.com>
 <a5e59a7c-d6ff-4c78-89a7-fad7492260b0@exht1.ad.emulex.com>
 <CAL1RGDWRm7GVCBgAdSvAt72WQAP4a-1xa18Hk-rFjEfKDEHZNg@mail.gmail.com>
 <88B766C272F2C64B944B21AD078333151C964A63FB@EXMAIL.ad.emulex.com>
 <CAL1RGDWrwP3mY2=W42_c5wpefzqx_BnXhnwfy2fPrP=12hrBOw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDWrwP3mY2=W42_c5wpefzqx_BnXhnwfy2fPrP=12hrBOw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Roland Dreier [mailto:roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org]
> Sent: Thursday, March 22, 2012 1:02 AM
> To: Pandit, Parav
> Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [PATCH 4/9] ocrdma: Driver for Emulex OneConnect RDMA
> adapter
> 
> On Wed, Mar 21, 2012 at 12:09 PM,  <Parav.Pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org> wrote:
> > Yes. Driver needs to put QP to flush state. So that appropriate CQEs can be
> returned during poll_cq() phase.
> > So state machine is implemented above.
> 
> Couldn't you just write
> 
>     if (ib_modify_qp_is_ok(...)) {
>         if (new_state == OCRDMA_QPS_ERR)
>             ocrdma_flush_qp(qp);
>     } else {
>         status = -EINVAL;
>     }
> 
> and save about 100 lines of code?
> 
Yes, this can be done. This is one path.
Another path is async_event coming from adapter. So I still need qp_state_machine function but as you suggested, I'll remove the states and will have invoke flush_qp() on error.

>  - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
