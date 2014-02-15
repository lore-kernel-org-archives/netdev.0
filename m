From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH 10/13] staging: r8188eu: Remove wrapper
 _enter_critical_mutex()
Date: Sat, 15 Feb 2014 13:41:55 +0300
Message-ID: <20140215104155.GC26776@mwanda>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
 <1392418457-3203-11-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:38911 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496AbaBOKmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Feb 2014 05:42:12 -0500
Content-Disposition: inline
In-Reply-To: <1392418457-3203-11-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 04:54:14PM -0600, Larry Finger wrote:
> diff --git a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
> index 1fa5370..d5f6a32 100644
> --- a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
> +++ b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
> @@ -49,7 +49,9 @@ static int usbctrl_vendorreq(struct intf_hdl *pintfhdl, u8 request, u16 value, u
>  		goto exit;
>  	}
>  
> -	_enter_critical_mutex(&dvobjpriv->usb_vendor_req_mutex, NULL);
> +	if (mutex_lock_interruptible(&dvobjpriv->usb_vendor_req_mutex))
> +		status = -ENOMEM;
> +		goto exit;
>  

Missing curly braces.

regards,
dan carpenter
