From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [PATCH v1 1/4] USB: introduce usb_device_no_sg_limit() helper
Date: Sat, 3 Aug 2013 11:53:18 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1308031149110.29946-100000@netrider.rowland.org>
References: <1375497998-7424-2-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netrider.rowland.org ([192.131.102.5]:39509 "HELO
	netrider.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752090Ab3HCPxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Aug 2013 11:53:19 -0400
In-Reply-To: <1375497998-7424-2-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Aug 2013, Ming Lei wrote:

> Some host controllers(such as xHCI) can support building
> packet from discontinuous buffers, so introduce one flag
> and helper for this kind of host controllers, then the
> feature can help some applications(such as, usbnet) by
> supporting arbitrary length of sg buffers.

> diff --git a/include/linux/usb.h b/include/linux/usb.h
> index 84f14e2..5d03074 100644
> --- a/include/linux/usb.h
> +++ b/include/linux/usb.h
> @@ -337,6 +337,7 @@ struct usb_bus {
>  					 * the ep queue on a short transfer
>  					 * with the URB_SHORT_NOT_OK flag set.
>  					 */
> +	unsigned no_sg_limit:1;		/* no sg list limit */

Why do you call this "no_sg_limit"?  It isn't a limit on the SG list; 
the list can be arbitrarily long, provided all the entries except the 
last are divisible by the maxpacket size.

You could call it "no_sg_constraint" if you want.  Or 
"allow_arbitrary_sg", to put a more positive spin on it.

Alan Stern
