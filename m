From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: 2.6.25rc7 lockdep trace
Date: Wed, 11 Jun 2008 10:40:27 +0000
Message-ID: <20080611104027.GC4171@ff.dom.local>
References: <20080610.224023.116817726.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:51008 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbYFKKgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 06:36:22 -0400
Received: by ug-out-1314.google.com with SMTP id h2so67889ugf.16
        for <netdev@vger.kernel.org>; Wed, 11 Jun 2008 03:36:20 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080610.224023.116817726.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-06-2008 07:40, David Miller wrote:
...
> diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
> index 0dcfc03..d776bcf 100644
> --- a/drivers/net/usb/kaweth.c
> +++ b/drivers/net/usb/kaweth.c
> @@ -706,7 +706,8 @@ static void kaweth_kill_urbs(struct kaweth_device *kaweth)
>  	usb_kill_urb(kaweth->rx_urb);
>  	usb_kill_urb(kaweth->tx_urb);
>  
> -	flush_scheduled_work();
> +	cancel_delayed_work(&kaweth->lowmem_work);
> +	cancel_work_sync(&kaweth->lowmem_work.work);
> 

Why not cancel_delayed_work_sync()?

Jarek P.
