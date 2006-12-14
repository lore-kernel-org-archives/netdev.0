From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: make dev_kfree_skb_irq not inline
Date: Thu, 14 Dec 2006 15:00:31 -0800 (PST)
Message-ID: <20061214.150031.68042040.davem@davemloft.net>
References: <20061214204814.631279000@osdl.org>
	<20061214204900.799953000@osdl.org>
	<20061214223009.GA16356@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54160
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751662AbWLNXAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Dec 2006 18:00:52 -0500
To: hch@infradead.org
In-Reply-To: <20061214223009.GA16356@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@infradead.org>
Date: Thu, 14 Dec 2006 22:30:09 +0000

> Maybe you should only move the slowpath out of line ala:
> 
> static inline void dev_kfree_skb_irq(struct sk_buff *skb)
> {
> 	if (atomic_dec_and_test(&skb->users)) 
> 		__dev_kfree_skb_irq(skb);
> }

The atomic operation all by itself is either a function
call or a 6-7 instruction sequence, so the inlining doesn't
make sense even in this case.
