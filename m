From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
Date: Mon, 14 Aug 2006 04:22:06 -0700 (PDT)
Message-ID: <20060814.042206.85411651.davem@davemloft.net>
References: <20060814110359.GA27704@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:28363
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751987AbWHNLWJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 07:22:09 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060814110359.GA27704@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Mon, 14 Aug 2006 15:04:03 +0400

>  	/* These elements must be at the end, see alloc_skb() for details.  */
> -	unsigned int		truesize;
> +	unsigned int		truesize, __tsize;

There is no real need for new member.

> -		kfree(skb->head);
> +		avl_free(skb->head, skb->__tsize);

Just use "skb->end - skb->head + sizeof(struct skb_shared_info)"
as the size argument.

Then, there is no reason for skb->__tsize :-)
