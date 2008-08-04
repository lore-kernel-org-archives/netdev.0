From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net_sched: Add qdisc __NET_XMIT_BYPASS flag
Date: Sun, 03 Aug 2008 18:25:24 -0700 (PDT)
Message-ID: <20080803.182524.240976246.davem@davemloft.net>
References: <20080731171431.GA9464@ami.dom.local>
	<4892AA16.40706@trash.net>
	<20080801101929.GA12735@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jussi.kivilinna@mbnet.fi, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33660
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752030AbYHDBZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 21:25:24 -0400
In-Reply-To: <20080801101929.GA12735@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Fri, 1 Aug 2008 10:19:29 +0000

> @@ -331,14 +331,14 @@ static inline unsigned int qdisc_pkt_len(struct sk_buff *skb)
>  	return qdisc_skb_cb(skb)->pkt_len;
>  }
>  
> -#ifdef CONFIG_NET_CLS_ACT
>  /* additional qdisc xmit flags */
>  enum net_xmit_qdisc_t {
> -	__NET_XMIT_STOLEN = NET_XMIT_MASK + 1,
> +	__NET_XMIT_STOLEN = NET_XMIT_MASK + 0x1,
> +	__NET_XMIT_BYPASS = NET_XMIT_MASK + 0x2,
>  };
>  

NET_XMIT_MASK + 0x2 is (0xffff + 2) which is 0x10001 and this is very
much not what you intended.

Please just explicitly spell out the bit mask values instead of trying
to create some false relationship with the mask and these values.

Next, these patches doesn't fix the while problem, in that htb and
friends are still corrupting the enqueue return value so that TCP is
going to do the wrong thing still.
