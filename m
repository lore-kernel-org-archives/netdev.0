From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [PATCH] SIW: Module initialization
Date: Tue, 5 Oct 2010 12:57:21 +0200
Message-ID: <AANLkTik5=i+A5_OpU0rVyfYi=ibgS9UWMu82vMCmM=PN@mail.gmail.com>
References: <1286261640-5121-1-git-send-email-bmt@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1286261640-5121-1-git-send-email-bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 5, 2010 at 8:54 AM, Bernard Metzler <bmt-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org> wr=
ote:
> +static int loopback_enabled;
> +module_param(loopback_enabled, int, 0644);
> +MODULE_PARM_DESC(loopback_enabled, "enable_loopback");

A minor comment: since kernel 2.6.31 the type "bool" can be used for
boolean kernel module parameters.

> + * TODO: Dynamic device management (network device registration/remo=
val).

The current implementation is such that one siw device is created for
each network device found at kernel module load time. That means that
you force the user to load the siw kernel module after all other
kernel modules that register a network device. I'm not sure that's a
good idea.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!siw_device) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siw_dev=
ice =3D siw_p;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siw_p->=
next =3D NULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siw_p->=
next =3D siw_device->next;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 siw_dev=
ice->next =3D siw_p;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }

Why a custom linked list implementation instead of using <linux/list.h>=
 ?

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
