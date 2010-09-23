From: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Subject: Re: [PATCH 1/2] siw: Fix ib_register_device() for > v2.6.34 kernels
Date: Thu, 23 Sep 2010 17:26:16 +0200
Message-ID: <OF5AB6498C.AF25B239-ONC12577A7.0054B7CD-C12577A7.0054CDCD@ch.ibm.com>
References: <1285187417-10928-1-git-send-email-nab@linux-iscsi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Andi Keen <ak-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicholas Bellinger <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Matthew Wilcox <willy-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
To: "Nicholas A. Bellinger" <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1285187417-10928-1-git-send-email-nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Thanks, Nicholas. Just applied your patch.

Bernard.

linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org wrote on 09/22/2010 10:30:17 PM:

> From: Nicholas Bellinger <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
>
> This patch adds a LINUX_VERSION_CODE > v2.6.34 check inside of
> siw_main.c:siw_register_device()
> around the use of ib_register_device().  In post v2.6.34 kernels
> this function accepts a second
> parameter used a sysfs port callback described here:
>
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;
> a=commitdiff;h=9a6edb60ec10d86b1025a0cdad68fd89f1ddaf02
>
> This patch currently sets this second parameter to NULL.
>
> Signed-off-by: Nicholas A. Bellinger <nab-IzHhD5pYlfBP7FQvKIMDCQ@public.gmane.org>
> ---
>  softiwarp/siw_main.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/softiwarp/siw_main.c b/softiwarp/siw_main.c
> index cacedea..c97adee 100644
> --- a/softiwarp/siw_main.c
> +++ b/softiwarp/siw_main.c
> @@ -233,8 +233,11 @@ int siw_register_device(struct siw_dev *dev)
>     ibdev->iwcm->add_ref = siw_qp_get_ref;
>     ibdev->iwcm->rem_ref = siw_qp_put_ref;
>     ibdev->iwcm->get_qp = siw_get_ofaqp;
> -
> +#if LINUX_VERSION_CODE > KERNEL_VERSION(2, 6, 34)
> +   rv = ib_register_device(ibdev, NULL);
> +#else
>     rv = ib_register_device(ibdev);
> +#endif
>     if (rv) {
>        dprint(DBG_DM|DBG_ON, "(dev=%s): "
>           "ib_register_device failed: rv=%d\n", ibdev->name, rv);
> --
> 1.5.6.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
