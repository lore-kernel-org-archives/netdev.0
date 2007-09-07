From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [CORRECTION][PATCH] Fix a potential NULL pointer dereference
 in uli526x_interrupt() in drivers/net/tulip/uli526x.c
Date: Fri, 07 Sep 2007 19:20:56 -0400
Message-ID: <46E1DCD8.9030004@pobox.com>
References: <46DD13CE.6010905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Micah Gruber <micah.gruber@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35061 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750986AbXIGXU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:20:58 -0400
In-Reply-To: <46DD13CE.6010905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Micah Gruber wrote:
> This patch fixes a potential null dereference bug where we dereference dev before a null check. This patch simply moves the dereferencing after the null check.
> 
> Signed-off-by: Micah Gruber <micah.gruber@gmail.com>
> ---
> 
> --- a/drivers/net/tulip/uli526x.c
> +++ b/drivers/net/tulip/uli526x.c
> @@ -663,7 +663,7 @@
>  {
>  	struct net_device *dev = dev_id;
>  	struct uli526x_board_info *db = netdev_priv(dev);
> -	unsigned long ioaddr = dev->base_addr;
> +	unsigned long ioaddr;
>  	unsigned long flags;
>  
>  	if (!dev) {
> @@ -671,6 +671,8 @@
>  		return IRQ_NONE;
>  	}
>  
> +	ioaddr = dev->base_addr;
> +

as satyam noted, just remove the !dev test


