From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Sun, 03 Aug 2008 23:42:00 -0700 (PDT)
Message-ID: <20080803.234200.193697269.davem@davemloft.net>
References: <20080801101929.GA12735@ff.dom.local>
	<20080803.182524.240976246.davem@davemloft.net>
	<20080804062813.GA4570@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48924
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755115AbYHDGmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 02:42:04 -0400
In-Reply-To: <20080804062813.GA4570@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 4 Aug 2008 06:28:13 +0000

> These 2 patches aren't supposed to fix these problems:
> 
> - the __NET_XMIT_STOLEN patch fixes a problem when a qdiscs passed
>   upwards NET_XMIT_SUCCESS when eg. an skb was stolen by an action,
>   to prevent treating this as dropped; then the upper qdiscs couldn't
>   tell it's not the full NET_XMIT_SUCCESS and counted it as queued,
>   which was wrong. (BTW, I especially tried to do it with minimal
>   changes in htb_enqueue() to let you apply your htb patch without
>   much editing.)
> 
> - the __NET_XMIT_BYPASS actually doesn't fix any serious problem, but
>   lets to remove the mapping from dev_queue_xmit(), and BTW it passes
>   better information to upper qdiscs too.

I understand.

But be aware that all of these things are related :-)

> Subject: net_sched: Add qdisc __NET_XMIT_BYPASS flag
> 
> Patrick McHardy <kaber@trash.net> noticed that it would be nice to
> handle NET_XMIT_BYPASS by NET_XMIT_SUCCESS with an internal qdisc flag
> __NET_XMIT_BYPASS and to remove the mapping from dev_queue_xmit().
> 
> David Miller <davem@davemloft.net> spotted a serious bug in the first
> version of this patch.
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
 ...
> @@ -331,14 +331,14 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
>  	return qdisc_skb_cb(skb)->pkt_len;
>  }
>  
> -#ifdef CONFIG_NET_CLS_ACT
> -/* additional qdisc xmit flags */
> +/* additional qdisc xmit flags (NET_XMIT_MASK in linux/netdevice.h) */
>  enum net_xmit_qdisc_t {
> -	__NET_XMIT_STOLEN = NET_XMIT_MASK + 1,
> +	__NET_XMIT_STOLEN = 0x0001FFFF,
> +	__NET_XMIT_BYPASS = 0x0002FFFF,
>  };
>  

Please, respin both patches, so that the "NET_XMIT_MASK + 1"
construct doesn't ever exist in the tree.

Thanks again.
