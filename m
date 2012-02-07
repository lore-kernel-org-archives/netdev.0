From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tun: use ethtool msglevel bit mask convention
Date: Mon, 06 Feb 2012 16:46:33 -0800
Message-ID: <1328575593.3949.6.camel@joe2Laptop>
References: <20120206163159.77940478@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48054 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751341Ab2BGAqg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Feb 2012 19:46:36 -0500
In-Reply-To: <20120206163159.77940478@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-06 at 16:31 -0800, Stephen Hemminger wrote:
> Replace custom debug printk with standard network device message level
> interface. The messages about open/close/read/write are debug messages which can
> be enabled at compile time or dynamic debug.

Seems sensible.

trivial comments below:

> --- a/drivers/net/tun.c	2012-01-10 10:56:57.027157981 -0800
> @@ -381,7 +355,8 @@ static netdev_tx_t tun_net_xmit(struct s
>  {
>  	struct tun_struct *tun = netdev_priv(dev);
>  
> -	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
> +	netif_info(tun, tx_queued, dev,
> +		   "tun_net_xmit %d\n", skb->len);

Fits on a single line
 

> @@ -1147,7 +1129,7 @@ static int tun_set_iff(struct net *net,
>  			goto failed;
>  	}
>  
> -	tun_debug(KERN_INFO, tun, "tun_set_iff\n");
> +	netif_info(tun, drv, tun->dev, "tun_set_iff flags %#x\n", ifr->ifr_flags);

This one is a little long.
> @@ -1277,7 +1259,8 @@ static long __tun_chr_ioctl(struct file
>  	if (!tun)
>  		goto unlock;
>  
> -	tun_debug(KERN_INFO, tun, "tun_chr_ioctl cmd %d\n", cmd);
> +	netif_info(tun, drv, tun->dev,
> +		   "tun_chr_ioctl cmd %#x\n", cmd);

Another one on a single line.

> @@ -1294,7 +1277,8 @@ static long __tun_chr_ioctl(struct file
>  		/* Disable/Enable checksum */
>  
>  		/* [unimplemented] */
> -		tun_debug(KERN_INFO, tun, "ignored: set checksum %s\n",
> +		netif_info(tun, drv, tun->dev,
> +			   "ignored: set checksum %s\n",
>  			  arg ? "disabled" : "enabled");

I'd write this one on 2 lines as:

		netif_info(tun, drv, tun->dev, "ignored: set checksum %s\n",
			   arg ? "disabled", "Enabled");
