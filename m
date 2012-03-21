From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 4/9] ocrdma: Driver for Emulex OneConnect RDMA adapter
Date: Wed, 21 Mar 2012 12:31:36 -0700
Message-ID: <CAL1RGDWrwP3mY2=W42_c5wpefzqx_BnXhnwfy2fPrP=12hrBOw@mail.gmail.com>
References: <1332283154-16369-1-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-2-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-3-git-send-email-parav.pandit@emulex.com>
 <1332283154-16369-4-git-send-email-parav.pandit@emulex.com>
 <a5e59a7c-d6ff-4c78-89a7-fad7492260b0@exht1.ad.emulex.com>
 <CAL1RGDWRm7GVCBgAdSvAt72WQAP4a-1xa18Hk-rFjEfKDEHZNg@mail.gmail.com> <88B766C272F2C64B944B21AD078333151C964A63FB@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Parav.Pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <88B766C272F2C64B944B21AD078333151C964A63FB-/SwythR3zqxVRK6PHKByhFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 21, 2012 at 12:09 PM,  <Parav.Pandit-laKkSmNT4hbQT0dZR+AlfA@public.gmane.org> wrote:
> Yes. Driver needs to put QP to flush state. So that appropriate CQEs can be returned during poll_cq() phase.
> So state machine is implemented above.

Couldn't you just write

    if (ib_modify_qp_is_ok(...)) {
        if (new_state == OCRDMA_QPS_ERR)
            ocrdma_flush_qp(qp);
    } else {
        status = -EINVAL;
    }

and save about 100 lines of code?

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
