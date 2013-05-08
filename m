From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2 v6 RESEND] usbnet: allow status interrupt URB to
 always be active
Date: Wed, 08 May 2013 13:14:24 -0700 (PDT)
Message-ID: <20130508.131424.165653900409648625.davem@davemloft.net>
References: <1367875763.31762.9.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	epasheva-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rfiler-ywE8TTl5eJHWpu6QEFMNjNBPR1lH4CV8@public.gmane.org, phil-ydcDiazATMQ@public.gmane.org
To: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1367875763.31762.9.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Mon, 06 May 2013 16:29:23 -0500

> Some drivers (sierra_net) need the status interrupt URB
> active even when the device is closed, because they receive
> custom indications from firmware.  Add functions to refcount
> the status interrupt URB submit/kill operation so that
> sub-drivers and the generic driver don't fight over whether
> the status interrupt URB is active or not.
> 
> A sub-driver can call usbnet_status_start() at any time, but
> the URB is only submitted the first time the function is
> called.  Likewise, when the sub-driver is done with the URB,
> it calls usbnet_status_stop() but the URB is only killed when
> all users have stopped it.  The URB is still killed and
> re-submitted for suspend/resume, as before, with the same
> refcount it had at suspend.
> 
> Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
