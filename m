From: David Miller <davem@davemloft.net>
Subject: Re: cxgb3: Fix kernel crash caused by uninitialized l2t_entry.arpq
Date: Fri, 17 Oct 2008 16:31:13 -0700 (PDT)
Message-ID: <20081017.163113.225289906.davem@davemloft.net>
References: <ada63nqsyxp.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, divy@chelsio.com
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44748
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751386AbYJQXbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 19:31:36 -0400
In-Reply-To: <ada63nqsyxp.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <rdreier@cisco.com>
Date: Fri, 17 Oct 2008 14:18:26 -0700

> Commit 147e70e6 ("cxgb3: Use SKB list interfaces instead of home-grown
> implementation.") causes a crash in t3_l2t_send_slow() when an iWARP
> connection request is received.  This is because the new l2t_entry.arpq
> skb queue is never initialized, and therefore trying to add an skb to
> it causes a NULL dereference.  With the old code there was no need to
> initialize the queues because the l2t_entry structures were zeroed,
> and the code used NULL to mean empty.
> 
> Fix this by adding __skb_queue_head_init() when all the l2t_entry
> structures get allocated.
> 
> Signed-off-by: Roland Dreier <rolandd@cisco.com>

Acked-by: David S. Miller <davem@davemloft.net>

> This should probably go to -stable as well, since it looks like the
> commit that broke things went into 2.6.27-rc6.

Indeed.

