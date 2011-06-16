From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: software iwarp stack update
Date: Thu, 16 Jun 2011 10:20:04 -0700
Message-ID: <BANLkTi=2woNzF=GL3cT3NB_hye5JHfodMA@mail.gmail.com>
References: <BANLkTimEGgKEMZd3qppOofN-Vj-u-PH-xA@mail.gmail.com> <OFB7458EEB.BFB8A4EE-ONC12578B1.004026D1-C12578B1.0041190E@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernard Metzler <BMT-OA+xvbQnYDHMbYB6QlFGEg@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <OFB7458EEB.BFB8A4EE-ONC12578B1.004026D1-C12578B1.0041190E-Xeyd2O9EBijQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I was expecting there is an ib_device->uverbs_cmd_mask
> flag which siw does not set... Unfortunately, it is not
> completely clear to me when a command mask bit is available
> and when the OFA core strictly expects a function pointer.
> Maybe there is some redundancy/inconsistency?

The uverbs_cmd_mask controls which commands userspace
can send down.  A kernel consumer does not go through the
code that checks this mask.

It does seem we are missing an IB_MANDATORY_FUNC
entry for modify_port in ib_device_check_mandatory; or on
the flip side we are missing a check of modify_port and a
-ENOSYS return... I guess modify_port does not really make
sense for iWARP so probably the second option is better.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
