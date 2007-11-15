From: Urs Thuermann <urs.thuermann@gmx.de>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: 15 Nov 2007 12:51:34 +0100
Message-ID: <ygfmytfbubd.fsf@janus.isnogud.escape.de>
References: <20071114121339.25823.0@janus.isnogud.escape.de>
	<20071114121425.25823.2@janus.isnogud.escape.de>
	<20071114133837.6b899595@freepuppy.rosehill>
	<473BF7FD.7010403@hartkopp.net> <1195113860.27113.34.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:39429 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751519AbXKOLzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 06:55:17 -0500
In-Reply-To: <1195113860.27113.34.camel@localhost>; from Joe Perches on Thu, 15 Nov 2007 00:04:20 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> writes:

> On Thu, 2007-11-15 at 08:40 +0100, Oliver Hartkopp wrote:
> > Stephen Hemminger wrote:
> > >> +#ifdef CONFIG_CAN_DEBUG_CORE
> > >> +extern void can_debug_skb(struct sk_buff *skb);
> > >> +extern void can_debug_cframe(const char *msg, struct can_frame *cframe);
> > >> +#define DBG(fmt, args...)  (DBG_VAR & 1 ? printk( \
> > >> +					KERN_DEBUG DBG_PREFIX ": %s: " fmt, \
> > >> +					__func__, ##args) : 0)
> > >> +#define DBG_FRAME(fmt, cf) (DBG_VAR & 2 ? can_debug_cframe(fmt, cf) : 0)
> > >> +#define DBG_SKB(skb)       (DBG_VAR & 4 ? can_debug_skb(skb) : 0)
> > >> +#else
> > >> +#define DBG(fmt, args...)
> > >> +#define DBG_FRAME(fmt, cf)
> > >> +#define DBG_SKB(skb)
> > >> +#endif
> 
> I would prefer the more frequently used macro style:
> 
> #define DBG(fmt, args...) \
> 	do { if (DBG_VAR & 1) printk(KERN_DEBUG DBG_PREFIX ": %s: " fmt, \
> 				     __func__, ##args); } while (0)
> 
> #define DBG_FRAME(fmt, cf) \
> 	do { if (DBG_VAR & 2) can_debug_cframe(fmt, cf); } while (0)
> 
> #define DBG_SKB(skb) \
> 	do { if (DBG_VAR & 4) can_debug_skb(skb); } while (0)

I prefer our code because it is shorter (fits into one line) and can
be used anywhere where an expression is allowed compared to only where
a statement is allowed.  Actually, I first had

        #define DBG( ... )   ((debug & 1) && printk( ... ))

and so on, but that didn't work with can_debug_{cframe,sbk} since they
return void.

Admitted, the benefit of expr vs. statement is really negligible and
since this issue has come up several times I will change these macros
using do-while.

urs
