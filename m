From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] net/phy/mdio_bus.c: fix a check-after-use
Date: Wed, 20 Feb 2008 11:52:27 -0500
Message-ID: <47BC5ACB.6070203@pobox.com>
References: <20080220001353.GV31955@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48871 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759569AbYBTQwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Feb 2008 11:52:31 -0500
In-Reply-To: <20080220001353.GV31955@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch fixes a check-after-use spotted by the Coverity checker.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 6beeb3ac577d74d72b2f91bd654eecb904c3c17e diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 6e9f619..963630c 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -49,13 +49,13 @@ int mdiobus_register(struct mii_bus *bus)
>  	int i;
>  	int err = 0;
>  
> -	mutex_init(&bus->mdio_lock);
> -
>  	if (NULL == bus || NULL == bus->name ||
>  			NULL == bus->read ||
>  			NULL == bus->write)
>  		return -EINVAL;
>  
> +	mutex_init(&bus->mdio_lock);
> +

applied


