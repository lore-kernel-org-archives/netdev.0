From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] qdisc bulk dequeuing and utilizing
 delayed tailptr updates
Date: Tue, 02 Sep 2014 14:05:20 -0700 (PDT)
Message-ID: <20140902.140520.1169519726923476673.davem@davemloft.net>
References: <20140902143254.1918.8419.stgit@dragon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, hannes@stressinduktion.org,
	dborkman@redhat.com
To: brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58653 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754982AbaIBVFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 17:05:21 -0400
In-Reply-To: <20140902143254.1918.8419.stgit@dragon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 02 Sep 2014 16:35:19 +0200

> Open questions:
> 
> - For now set bulk limit to 8 packets, don't want to stress the driver
>   avail ring_buffer space.

Maybe we can start out with something even lower, like 5.

> - Is the (!skb->next) check in dequeue necessary?
> 
> - Do we need some checks in dev_requeue_skb() as we could be requeuing a SKB list?

The skb->next stuff is to handle GSO software segmented frames.

dev_requeue_skb() naturally handles any list of SKBs already,
GSO software segmented or multi-dequeue, it shouldn't care.
