From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2]: niu: Manage TX backlog in-driver.
Date: Sun, 22 Jun 2008 19:30:43 -0700 (PDT)
Message-ID: <20080622.193043.243787410.davem@davemloft.net>
References: <20080622.161658.115278698.davem@davemloft.net>
	<485F04BD.6090601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vinay@linux.vnet.ibm.com,
	krkumar2@in.ibm.com, matheos.worku@sun.com
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55817
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752854AbYFWCan (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2008 22:30:43 -0400
In-Reply-To: <485F04BD.6090601@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Mon, 23 Jun 2008 10:04:45 +0800

> David Miller said the following on 2008-6-23 7:16:
> > +
> > +		while ((skb = __skb_dequeue(&rp->tx_backlog)) != NULL)
> > +			dev_kfree_skb(skb);
> 
> How about __skb_queue_purge(&rp->tx_backlog);

Sure, I can use that, thanks for the suggestion.

> > +static void __niu_tx_queue_backlog(struct niu *np, struct tx_ring_info *rp,
> > +				   struct sk_buff *skb)
> > +{
> > +	if (skb_queue_len(&rp->tx_backlog) < np->dev->tx_queue_len)
> > +		__skb_queue_tail(&rp->tx_backlog, skb);
> 
> Do we need lock to proteck tx_backlog?
> How about use skb_queue_tail()?

That would just grab another lock (the sk_buff_head one), and the
overall goal of these changes is to decrease the number of locks taken
to TX packets and purge the TX ring during completions.
