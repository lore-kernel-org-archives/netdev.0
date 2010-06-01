From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sock_queue_err_skb() dont mess with
 sk_forward_alloc
Date: Mon, 31 May 2010 23:44:32 -0700 (PDT)
Message-ID: <20100531.234432.191383736.davem@davemloft.net>
References: <1274868776.2672.96.camel@edumazet-laptop>
	<20100529.002124.149815573.davem@davemloft.net>
	<1275321766.3291.100.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752240Ab0FAGoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 02:44:22 -0400
In-Reply-To: <1275321766.3291.100.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 31 May 2010 18:02:46 +0200

> There is also a problem in ip_recv_error(), not called with socket
> locked, skb freed -> potential corruption.
> 
> If current socket is 'owned' by a user thread, then we can still corrupt
> sk_forward_alloc, even if we use bh_lock_sock()
> 
> I dont think we need to have another backlog for such case, maybe we
> could account for skb->truesize in sk_rmem_alloc (this is atomic), and
> not account for sk_mem_charge ?

That sounds fine to me.

> [PATCH] net: sock_queue_err_skb() dont mess with sk_forward_alloc
> 
> Correct sk_forward_alloc handling for error_queue would need to use a
> backlog of frames that softirq handler could not deliver because socket
> is owned by user thread. Or extend backlog processing to be able to
> process normal and error packets.
> 
> Another possibility is to not use mem charge for error queue, this is
> what I implemented in this patch.
> 
> Note: this reverts commit 29030374
> (net: fix sk_forward_alloc corruptions), since we dont need to lock
> socket anymore.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, applied, thanks Eric.
