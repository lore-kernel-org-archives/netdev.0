From: David Miller <davem@davemloft.net>
Subject: Re: panic 2.6.27-rc3-git2, qdisc_dequeue_head
Date: Sun, 17 Aug 2008 15:02:58 -0700 (PDT)
Message-ID: <20080817.150258.117813919.davem@davemloft.net>
References: <20080817133608.GA3584@ami.dom.local>
	<200808172236.17857.denys@visp.net.lb>
	<20080817214752.GA2546@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751546AbYHQWC7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 18:02:59 -0400
In-Reply-To: <20080817214752.GA2546@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sun, 17 Aug 2008 23:47:52 +0200

> @@ -638,9 +638,9 @@ static void notify_and_destroy(struct sk_buff *skb, struct nlmsghdr *n, u32 clid
>  		qdisc_notify(skb, n, clid, old, new);
>  
>  	if (old) {
> -		spin_lock_bh(&old->q.lock);
> +		sch_tree_lock(old);
>  		qdisc_destroy(old);
> -		spin_unlock_bh(&old->q.lock);
> +		sch_tree_unlock(old);
>  	}
>  }
>  

Ok, this makes sense, for the classful qdisc case.

If we really wanted to be super-careful, we could remember the root
qdisc at the top of qdisc_graft() and pass that into
notify_and_destroy().

