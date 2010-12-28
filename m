From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] ueagle-atm: fix PHY signal initialization race
Date: Tue, 28 Dec 2010 13:42:01 -0800 (PST)
Message-ID: <20101228.134201.189717347.davem@davemloft.net>
References: <1292782671.5282.20.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, duncan.sands-GANU6spQydw@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hicham.haouari-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1292782671.5282.20.camel-wKZy7rqYPVb5EHUCmHmTqw@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Sun, 19 Dec 2010 12:17:50 -0600

> A race exists when initializing ueagle-atm devices where the generic atm
> device may not yet be created before the driver attempts to initialize
> it's PHY signal state, which checks whether the atm device has been
> created or not.  This often causes the sysfs 'carrier' attribute to be
> '1' even though no signal has actually been found.
> 
> uea_probe
>    usbatm_usb_probe
>       driver->bind (uea_bind)
>          uea_boot
>             kthread_run(uea_kthread)     uea_kthread
>       usbatm_atm_init                       uea_start_reset
>          atm_dev_register                      UPDATE_ATM_SIGNAL
 ...
> Signed-off-by: Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>

Applied, thanks Dan.
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
