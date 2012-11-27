From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] smsc95xx: fix suspend buffer overflow
Date: Tue, 27 Nov 2012 09:42:58 -0800
Message-ID: <1354038178.8028.0.camel@joe-AO722>
References: <1354022623-7317-1-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dan.carpenter@oracle.com
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40349 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755972Ab2K0Rm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2012 12:42:59 -0500
In-Reply-To: <1354022623-7317-1-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 13:23 +0000, Steve Glendinning wrote:
> This patch fixes a buffer overflow introduced by bbd9f9e, where
> the filter_mask array is accessed beyond its bounds.
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Steve Glendinning <steve.glendinning@shawell.net>
> ---
>  drivers/net/usb/smsc95xx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index 79d495d..6cdc504 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -1281,7 +1281,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
>  	}
>  
>  	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
> -		u32 *filter_mask = kzalloc(32, GFP_KERNEL);
> +		u32 *filter_mask = kzalloc(sizeof(u32) * 32, GFP_KERNEL);

It's also unchecked for alloc failure.

>  		u32 command[2];
>  		u32 offset[2];
>  		u32 crc[4];
