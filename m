From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/7] CAN: Add PF_CAN core module
Date: Thu, 15 Nov 2007 00:04:20 -0800
Message-ID: <1195113860.27113.34.camel@localhost>
References: <20071114121339.25823.0@janus.isnogud.escape.de>
	 <20071114121425.25823.2@janus.isnogud.escape.de>
	 <20071114133837.6b899595@freepuppy.rosehill>
	 <473BF7FD.7010403@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Urs Thuermann <urs.thuermann@gmx.de>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2224 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800AbXKOIEg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 03:04:36 -0500
In-Reply-To: <473BF7FD.7010403@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-11-15 at 08:40 +0100, Oliver Hartkopp wrote:
> Stephen Hemminger wrote:
> >> +#ifdef CONFIG_CAN_DEBUG_CORE
> >> +extern void can_debug_skb(struct sk_buff *skb);
> >> +extern void can_debug_cframe(const char *msg, struct can_frame *cframe);
> >> +#define DBG(fmt, args...)  (DBG_VAR & 1 ? printk( \
> >> +					KERN_DEBUG DBG_PREFIX ": %s: " fmt, \
> >> +					__func__, ##args) : 0)
> >> +#define DBG_FRAME(fmt, cf) (DBG_VAR & 2 ? can_debug_cframe(fmt, cf) : 0)
> >> +#define DBG_SKB(skb)       (DBG_VAR & 4 ? can_debug_skb(skb) : 0)
> >> +#else
> >> +#define DBG(fmt, args...)
> >> +#define DBG_FRAME(fmt, cf)
> >> +#define DBG_SKB(skb)
> >> +#endif

I would prefer the more frequently used macro style:

#define DBG(fmt, args...) \
	do { if (DBG_VAR & 1) printk(KERN_DEBUG DBG_PREFIX ": %s: " fmt, \
				     __func__, ##args); } while (0)

#define DBG_FRAME(fmt, cf) \
	do { if (DBG_VAR & 2) can_debug_cframe(fmt, cf); } while (0)

#define DBG_SKB(skb) \
	do { if (DBG_VAR & 4) can_debug_skb(skb); } while (0)
		

