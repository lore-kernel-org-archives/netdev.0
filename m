From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH 04/14] SIWv2: Module initialization: siw_main.c
Date: Sat, 18 Jun 2011 19:39:11 +0200
Message-ID: <BANLkTi=E=FQonndVeROSQJkpWRH4sCwEfA@mail.gmail.com>
References: <1308228122-22616-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1308228122-22616-1-git-send-email-bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 16, 2011 at 2:42 PM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> w=
rote:
> ---
> =A0drivers/infiniband/hw/siw/siw_main.c | =A0603 ++++++++++++++++++++=
++++++++++++++
> =A01 files changed, 603 insertions(+), 0 deletions(-)
> =A0create mode 100644 drivers/infiniband/hw/siw/siw_main.c
>
> diff --git a/drivers/infiniband/hw/siw/siw_main.c b/drivers/infiniban=
d/hw/siw/siw_main.c
> [ ... ]
> +static ssize_t show_stats(struct device *dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device_attri=
bute *attr, char *buf)
> +{
> + =A0 =A0 =A0 struct siw_dev *siw_dev =3D container_of(dev, struct si=
w_dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0ofa_dev.dev);
> +
> + =A0 =A0 =A0 return sprintf(buf, "Allocated SIW Objects:\n"
> +#if DPRINT_MASK > 0
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Global =A0 =A0 :\t%s: =
%d\n"
> +#endif
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Device %s:\t"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%s: %d, %s: %d, %s: %d=
, %s: %d, %s: %d, %s: %d\n",
> +#if DPRINT_MASK > 0
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "WQEs", atomic_read(&si=
w_num_wqe),
> +#endif
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siw_dev->ofa_dev.name,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "PDs", atomic_read(&siw=
_dev->num_pd),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "QPs", atomic_read(&siw=
_dev->num_qp),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "CQs", atomic_read(&siw=
_dev->num_cq),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "SRQs", atomic_read(&si=
w_dev->num_srq),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "MRs", atomic_read(&siw=
_dev->num_mem),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "CEPs", atomic_read(&si=
w_dev->num_cep));
> +}

The rules for sysfs, documented in Documentation/ABI/README, are:
- One value per file.
- All new sysfs attributes must be documented in Documentation/ABI.

An alternative to following the above rules is moving attributes from
sysfs to debugfs.

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
