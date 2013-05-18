From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 3/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Sat, 18 May 2013 23:09:58 +0200
Message-ID: <20130518210958.GB26590@electric-eye.fr.zoreil.com>
References: <alpine.DEB.2.02.1305181904110.7518@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Petko Manolov <petkan@nucleusys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1305181904110.7518@fry.nucleusys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Petko Manolov <petkan@nucleusys.com> :
[...]
> diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
> index 7d1897b..fd4bc2a 100644
> --- a/drivers/net/usb/rtl8150.c
> +++ b/drivers/net/usb/rtl8150.c
[...]
>  static void rx_fixup(unsigned long data)
>  {
>  	struct rtl8150 *dev = (struct rtl8150 *)data;
>  	struct sk_buff *skb;
>  	int status;
>  
> -	spin_lock_irq(&dev->rx_pool_lock);
> -	fill_skb_pool(dev);
> -	spin_unlock_irq(&dev->rx_pool_lock);
>  	if (test_bit(RX_URB_FAIL, &dev->flags))
>  		if (dev->rx_skb)
>  			goto try_again;
> -	spin_lock_irq(&dev->rx_pool_lock);
> -	skb = pull_skb(dev);
> -	spin_unlock_irq(&dev->rx_pool_lock);
> +	skb = __netdev_alloc_skb_ip_align(dev->netdev, RTL8150_MTU, GFP_ATOMIC);

You can use plain netdev_alloc_skb_ip_align.

-- 
Ueimor
