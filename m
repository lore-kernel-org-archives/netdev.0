From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 1/2] usbnet: changes for upcoming cdc_ncm driver
Date: Tue, 23 Nov 2010 10:58:40 -0800
Message-ID: <1290538720.2529.109.camel@helium>
References: <1290531088-2393-1-git-send-email-alexey.orishko@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	oliver@neukum.org, yauheni.kaliuta@nokia.com,
	felipe.balbi@nokia.com, sjur.brandeland@stericsson.com,
	Alexey Orishko <alexey.orishko@stericsson.com>
To: Alexey Orishko <alexey.orishko@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm4.bullet.mail.ac4.yahoo.com ([98.139.52.201]:37762 "HELO
	nm4.bullet.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753050Ab0KWS6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 13:58:45 -0500
In-Reply-To: <1290531088-2393-1-git-send-email-alexey.orishko@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-23 at 17:51 +0100, Alexey Orishko wrote:

> -		skb_queue_tail (&dev->done, skb);
> +	if (skb->len) {
> +		/* all data was already cloned inside NCM driver */

Fix this comment.  NCM isn't the only framing policy which un-batches
RX packets ... RNDIS has done so for a number of years already, and
more recently EEM needs it too ... plus at least one hardware driver.

Also, check pending patches, since I seem to recall one that supports
some hardware (SMSC?) that batches, and needed to update the calling
convention you're using here (i.e. the original one).


> +		if (dev->driver_info->flags & FLAG_MULTI_PACKET)

except ... you documented this flag as affecting TX paths not RX...
> +			dev_kfree_skb_any(skb);
> +		else
> +			usbnet_skb_return(dev, skb);
> +		return;
>  	}
> +
> +	netif_dbg(dev, rx_err, dev->net, "drop\n");
> +error:
> +	dev->net->stats.rx_errors++;
> +	skb_queue_tail(&dev->done, skb);
>  }
>  


