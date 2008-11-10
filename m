From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] nets: fix problem of using lock
Date: Mon, 10 Nov 2008 13:35:15 -0800 (PST)
Message-ID: <20081110.133515.130695626.davem@davemloft.net>
References: <20081106104103.GA29787@ubuntu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jianjun@zeuux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43237
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752204AbYKJVfP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 16:35:15 -0500
In-Reply-To: <20081106104103.GA29787@ubuntu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianjun Kong <jianjun@zeuux.org>
Date: Thu, 6 Nov 2008 18:41:03 +0800

> net/core/skbuff.c: void skb_queue_purge(struct sk_buff_head *list)
> 
> This function should takes the the list lock, because the operation to
> this list shoule be atomic. And __skb_queue_purge()  (in
> include/linux/skbuff.c) real delete the buffers in the list.
> 
> Signed-off-by: Jianjun Kong <jianjun@zeuux.org>

No, this function is fine.  skb_dequeue() takes the lock so
there cannot be any list corruption.

And this function is called in contexts where the caller knows
that no new packets can be added to the list (closing a socket,
shutting down a device, etc.)  And even if new packets could
appear, taking the lock over the entire function would not
help that problem.

In fact, I suspect that many if not all skb_queue_purge() callers
can be converted to use __skb_queue_purge().
