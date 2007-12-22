From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] Reduce locking in TX path of forcedth driver
Date: Fri, 21 Dec 2007 18:54:35 -0800
Message-ID: <20071221185435.2884f118@deepthought>
References: <20071222014134.A28994161A0@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:48431 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbXLVCzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Dec 2007 21:55:41 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1J5uWW-0006ZI-Oi
	for netdev@vger.kernel.org; Sat, 22 Dec 2007 02:55:36 +0000
Received: from 069-064-229-129.pdx.net ([69.64.229.129])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 22 Dec 2007 02:55:36 +0000
Received: from shemminger by 069-064-229-129.pdx.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 22 Dec 2007 02:55:36 +0000
In-Reply-To: <20071222014134.A28994161A0@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 21 Dec 2007 17:41:34 -0800 (PST)
therbert@google.com (Tom Herbert) wrote:

> Reduce the amount of locking in the TX path.  Instead of using both netif_tx_lock and dev->priv->lock on transmitting, a single private lock (dev->priv->tx_lock) is used.  This method is similar to that of the e1000 driver, including the logic to stop the queue in the start xmit functions, and the logic to wake the queue in the TX done functions.  We see some performance improvement with this patch.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>


>  
> +	spin_lock_init(&np->tx_lock);
> +
> +	dev->features |= NETIF_F_LLTX;
> +

NAK - lockless transmit is not desirable for real devices.

use netif_tx_lock() instead of your private lock

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

