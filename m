From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] usbnet: allow type check of devdbg arguments in non-debug
 build
Date: Wed, 24 Sep 2008 22:14:45 -0400
Message-ID: <48DAF415.8000307@garzik.org>
References: <1221493664-544-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ian Saturley <ian.saturley@smsc.com>,
	David Brownell <dbrownell@users.sourceforge.net>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56512 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753195AbYIYCOt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2008 22:14:49 -0400
In-Reply-To: <1221493664-544-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning wrote:
> improve usbnet's devdbg to always type-check diagnostic arguments,
> like dev_dbg (device.h).  This makes no change to the resulting size of
> usbnet modules.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
> ---
>  include/linux/usb/usbnet.h |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index ba09fe8..7d38222 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -197,7 +197,9 @@ extern int usbnet_nway_reset(struct net_device *net);
>  #define devdbg(usbnet, fmt, arg...) \
>  	printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
>  #else
> -#define devdbg(usbnet, fmt, arg...) do {} while(0)
> +#define devdbg(usbnet, fmt, arg...) \
> +	({ if (0) printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , \
> +		## arg); 0; })
>  #endif

applied


