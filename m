From: Petko Manolov <petkan@nucleusys.com>
Subject: Re: [PATCH 3/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Sun, 19 May 2013 11:48:13 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305191146130.4537@fry.nucleusys.com>
References: <alpine.DEB.2.02.1305181904110.7518@fry.nucleusys.com> <20130518210958.GB26590@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130518210958.GB26590@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 18 May 2013, Francois Romieu wrote:

> Petko Manolov <petkan@nucleusys.com> :
> [...]
> > diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
> > index 7d1897b..fd4bc2a 100644
> > --- a/drivers/net/usb/rtl8150.c
> > +++ b/drivers/net/usb/rtl8150.c
> [...]
> >  static void rx_fixup(unsigned long data)
> >  {
> >  	struct rtl8150 *dev = (struct rtl8150 *)data;
> >  	struct sk_buff *skb;
> >  	int status;
> >  
> > -	spin_lock_irq(&dev->rx_pool_lock);
> > -	fill_skb_pool(dev);
> > -	spin_unlock_irq(&dev->rx_pool_lock);
> >  	if (test_bit(RX_URB_FAIL, &dev->flags))
> >  		if (dev->rx_skb)
> >  			goto try_again;
> > -	spin_lock_irq(&dev->rx_pool_lock);
> > -	skb = pull_skb(dev);
> > -	spin_unlock_irq(&dev->rx_pool_lock);
> > +	skb = __netdev_alloc_skb_ip_align(dev->netdev, RTL8150_MTU, GFP_ATOMIC);
> 
> You can use plain netdev_alloc_skb_ip_align.

Yep, except for the call in rtl8150_open() (where GFP_KERNEL is more 
appropriate) i should have used the plain version.
