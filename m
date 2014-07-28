From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cdc_subset: deal with a device that needs reset for
 timeout
Date: Sun, 27 Jul 2014 22:31:31 -0700 (PDT)
Message-ID: <20140727.223131.562363351418867070.davem@davemloft.net>
References: <1406203174-13102-1-git-send-email-oneukum@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: oneukum@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaG1Fbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 01:31:31 -0400
In-Reply-To: <1406203174-13102-1-git-send-email-oneukum@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Neukum <oneukum@suse.de>
Date: Thu, 24 Jul 2014 13:59:34 +0200

> @@ -1218,6 +1218,8 @@ void usbnet_tx_timeout (struct net_device *net)
>  
>  	unlink_urbs (dev, &dev->txq);
>  	tasklet_schedule (&dev->bh);
> +	if (dev->driver_info->recover)
> +		(dev->driver_info->recover)(dev);
>  
>  	// FIXME: device recovery -- reset?
>  }

Well, since you're at least providing a way to handle this now, you can
remove this comment completely.
