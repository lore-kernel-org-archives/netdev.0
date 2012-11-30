From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/5] smsc95xx: fix suspend buffer overflow
Date: Fri, 30 Nov 2012 08:03:41 -0800
Message-ID: <1354291421.11903.25.camel@joe-AO722>
References: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
	 <1354290952-27109-2-git-send-email-steve.glendinning@shawell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bjorn Mork <bjorn@mork.no>
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52723 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933180Ab2K3QDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2012 11:03:41 -0500
In-Reply-To: <1354290952-27109-2-git-send-email-steve.glendinning@shawell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-30 at 15:55 +0000, Steve Glendinning wrote:
> This patch fixes a buffer overflow introduced by bbd9f9e, where
> the filter_mask array is accessed beyond its bounds.
[]
> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
[]
> @@ -1281,7 +1281,7 @@ static int smsc95xx_suspend(struct usb_interface *intf, pm_message_t message)
>  	}
>  
>  	if (pdata->wolopts & (WAKE_BCAST | WAKE_MCAST | WAKE_ARP | WAKE_UCAST)) {
> -		u32 *filter_mask = kzalloc(32, GFP_KERNEL);
> +		u32 *filter_mask = kzalloc(sizeof(u32) * 32, GFP_KERNEL);

Just get rid of the alloc and use 32 u8's on stack.
It's small enough
No filter value is > FF and the compiler with expand
the u8 to u32 when writing to the card.
