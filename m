From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] iphase fix.
Date: Thu, 15 May 2003 02:37:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3EC3359D.5050207@pobox.com>
References: <200305150417.h4F4HTRA025809@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davej@codemonkey.org.uk
In-Reply-To: <200305150417.h4F4HTRA025809@hera.kernel.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List wrote:
> ChangeSet 1.1127, 2003/05/14 20:44:02-07:00, davej@codemonkey.org.uk
> 
> 	[PATCH] iphase fix.
> 	
> 	This went into 2.4 nearly a year back with the wonderfully
> 	descriptive  "Fix from maintainer" comment.

> diff -Nru a/drivers/net/fc/iph5526.c b/drivers/net/fc/iph5526.c
> --- a/drivers/net/fc/iph5526.c	Wed May 14 21:17:37 2003
> +++ b/drivers/net/fc/iph5526.c	Wed May 14 21:17:37 2003
> @@ -2984,8 +2984,7 @@
>  	 */
>  	if ((type == ETH_P_ARP) || (status == 0))
>  		dev_kfree_skb(skb);
> -	else
> -		netif_wake_queue(dev);
> +	netif_wake_queue(dev);
>  	LEAVE("iph5526_send_packet");


This appears to revert a fix.

You only want to wake the queue if you have room to queue another skb.

	Jeff
