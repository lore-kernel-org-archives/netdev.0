From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethertap can use alloc_etherdev
Date: Tue, 11 Nov 2003 18:52:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB17650.2000408@pobox.com>
References: <20031111144557.38bde052.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031111144557.38bde052.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Can use alloc_etherdev, don't need to call ether_setup.
> Found by viro.
> 
> diff -Nru a/drivers/net/ethertap.c b/drivers/net/ethertap.c
> --- a/drivers/net/ethertap.c	Tue Nov 11 09:36:15 2003
> +++ b/drivers/net/ethertap.c	Tue Nov 11 09:36:15 2003
> @@ -72,8 +72,7 @@
>  	struct net_device *dev;
>  	int err = -ENOMEM;
>  
> -	dev = alloc_netdev(sizeof(struct net_local), "tap%d",
> -			   ether_setup);
> +	dev = alloc_etherdev(sizeof(struct net_local));


Um?  This clearly changes the device's interface name, which 
alloc_etherdev() not ether_setup() assigns.

	Jeff
