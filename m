From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 06/11] drivers/net: use printk_ratelimited() instead of
 printk_ratelimit()
Date: Thu, 16 Jun 2011 09:43:52 -0700
Message-ID: <1308242632.9563.12.camel@Joe-Laptop>
References: <cover.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
	 <bbe5954082599bcf65e9fdf565df8b9646ec3e3b.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	David Decotigny <decot@google.com>,
	"Hans J. Koch" <hjk@linutronix.de>, Jiri Kosina <jkosina@suse.cz>,
	Ben Pfaff <blp@cs.stanford.edu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	christian.dietrich@informatik.uni-erlangen.de
To: Manuel Zerpies <manuel.f.zerpies@ww.stud.uni-erlangen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <bbe5954082599bcf65e9fdf565df8b9646ec3e3b.1308142053.git.manuel.f.zerpies@ww.stud.uni-erlangen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-06-16 at 14:12 +0200, Manuel Zerpies wrote:
> Since printk_ratelimit() shouldn't be used anymore (see comment in
> include/linux/printk.h), replace it with printk_ratelimited()
[]
> diff --git a/drivers/net/sc92031.c b/drivers/net/sc92031.c
[]
> @@ -536,8 +537,7 @@ static bool _sc92031_check_media(struct net_device *dev)
>  
>  		netif_carrier_on(dev);
>  
> -		if (printk_ratelimit())
> -			printk(KERN_INFO "%s: link up, %sMbps, %s-duplex\n",
> +		printk_ratelimited(KERN_INFO "%s: link up, %sMbps, %s-duplex\n",
> 				dev->name,
>  				speed_100 ? "100" : "10",
>  				duplex_full ? "full" : "half");
 
All these might be better using net_ratelimit and netdev_<level>

		if (net_ratelimit())
			netdev_info(dev, "link up, %uMbps, %s-duplex\n",
				    speed_100 ? 100 : 10,
				    duplex_full ? "full" : "half");

> @@ -549,8 +549,7 @@ static bool _sc92031_check_media(struct net_device *dev)
>  
>  		_sc92031_disable_tx_rx(dev);
>  
> -		if (printk_ratelimit())
> -			printk(KERN_INFO "%s: link down\n", dev->name);
> +		printk_ratelimited(KERN_INFO "%s: link down\n", dev->name);

etc...

netdev_<level>_ratelimited (and netdev_<level>_once)
could instead be added and used I suppose.
