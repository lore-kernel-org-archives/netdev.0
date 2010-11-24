From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] ethoc: rework interrupt handling
Date: Wed, 24 Nov 2010 11:38:58 -0800 (PST)
Message-ID: <20101124.113858.229724018.davem@davemloft.net>
References: <1290606058-26703-1-git-send-email-jonas@southpole.se>
	<1290606058-26703-7-git-send-email-jonas@southpole.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jonas@southpole.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33240
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755901Ab0KXTid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 14:38:33 -0500
In-Reply-To: <1290606058-26703-7-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jonas Bonn <jonas@southpole.se>
Date: Wed, 24 Nov 2010 14:40:56 +0100

> The old interrupt handling was incorrect in that it did not account for the
> fact that the interrupt source bits get set irregardless of whether or not
> their corresponding mask is set.  This patch fixes that by masking off the
> source bits for masked interrupts.
> 
> Furthermore, the handling of transmission events is moved to the NAPI polling
> handler alongside the reception handler, thus preventing a whole bunch of
> interrupts during heavy traffic.
> 
> Signed-off-by: Jonas Bonn <jonas@southpole.se>

> +			 * and clearing the interrupt source, then we risk 
 ...
> +			 * right away when we reenable it; hence, check 

Trailing whitespace.

> -	if ((priv->cur_tx - priv->dty_tx) <= (priv->num_tx / 2))
> +	if ((priv->cur_tx - priv->dty_tx) <= (priv->num_tx / 2)) {
>  		netif_wake_queue(dev);
> +	}
>  

One-line statement does not require braces.
