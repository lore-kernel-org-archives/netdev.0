From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 20 Sep 2007 22:27:42 +0200
Message-ID: <1190320062.3085.6.camel@chaos>
References: <20070920184323.3795.0@janus.isnogud.escape.de>
	 <20070920184532.3795.2@janus.isnogud.escape.de>
	 <1190318781.26101.148.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Urs Thuermann <urs@isnogud.escape.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:54986 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751219AbXITU1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Sep 2007 16:27:50 -0400
In-Reply-To: <1190318781.26101.148.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-09-20 at 13:06 -0700, Joe Perches wrote:
> On Thu, 2007-09-20 at 20:43 +0200, Urs Thuermann wrote:
> > +#define DBG(...)       (debug & 1 ? \
> > +                              (printk(KERN_DEBUG "can-%s %s: ", \
> > +                               IDENT, __func__), printk(args)) : 0)
> > +#define DBG_FRAME(args...) (debug & 2 ? can_debug_cframe(args) : 0)
> > +#define DBG_SKB(skb)       (debug & 4 ? can_debug_skb(skb) : 0)
> > +#else
> > +#define DBG(args...)
> > +#define DBG_FRAME(args...)
> > +#define DBG_SKB(skb)
> > +#endif
> 
> Shouldn't these be like the more common
> 
> #define DBG(fmt, args...) \

> I'd prefer something like this, which removes the unnecessary
> kmalloc/kfree pairs or the equivalent conversions to functions.
> 
> #define can_debug_cframe(cf, fmt, arg...) \

That's even worse. If we want to have something better than the DBG
macros, then please convert the whole stuff into inline functions.

#ifdef DEBUG
static inline void debug_skb(struct sk_buff *skb)
{
	if (debug & 4)
		...
}
#else
static inline debug_skb(struct sk_buff *skb) {}
#endif

Thanks,

	tglx


