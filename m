From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [linux-usb-devel] drivers/usb/gadget/ether.c: NULL dereference
Date: Sun, 12 Nov 2006 13:23:32 +0100
Message-ID: <20061112122332.GG25057@stusta.de>
References: <20061111160643.GA8809@stusta.de> <200611112235.49931.david-b@pacbell.net> <20061112065008.GF25057@stusta.de> <200611112310.18903.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb-devel@lists.sourceforge.net, greg@kroah.com,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:56326 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1755082AbWKLMX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Nov 2006 07:23:28 -0500
To: David Brownell <david-b@pacbell.net>
Content-Disposition: inline
In-Reply-To: <200611112310.18903.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 11, 2006 at 11:10:17PM -0800, David Brownell wrote:
> 
> > 
> > void dev_kfree_skb_any(struct sk_buff *skb)
> > {
> >         if (in_irq() || irqs_disabled())
> >                 dev_kfree_skb_irq(skb);
> >         else
> >                 dev_kfree_skb(skb);
> > }
> > 
> > 
> > And the first thing dev_kfree_skb_irq() does is to dereference skb...
> 
> Yet dev_kfree_skb() --> kfree_skb() starts with the standard idiom
> 
> 	if (unlikely(!skb))
> 		return
> 
> Seems to me that the finger of blame is more appropriately pointed
> at either dev_kfree_skb_any() or dev_kfree_skb_irq() ...
>...

Adding the net maintainers to the Cc:
Is there any reason why dev_kfree_skb_irq() has no NULL check for "skb"?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

