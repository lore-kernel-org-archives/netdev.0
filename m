From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 02:43:36 -0700 (PDT)
Message-ID: <20100422.024336.119875321.davem@davemloft.net>
References: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, therbert@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753806Ab0DVJnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 05:43:31 -0400
In-Reply-To: <1271927357-2973-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Thu, 22 Apr 2010 17:09:17 +0800

> +	unsigned int		input_pkt_queue_len;
> +	struct sk_buff		*input_pkt_queue_head;
> +	struct sk_buff		**input_pkt_queue_tailp;
> +

Please do not ignore Stephen Hemminger's feedback.

We already have enough odd SKB queue implementations, we
do not need yet another one in a core location.  This makes
it harder and harder to eventually convert sk_buff to use
"struct list_head".

Instead, use "struct sk_buff_head" and the lockless accessors
(__skb_insert, etc.) and initializer (__skb_queue_head_init).
