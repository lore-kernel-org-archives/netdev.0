From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC] avoid unnecessary alignement overhead in skb->data allocation.
Date: Mon, 7 Aug 2006 10:30:57 +0400
Message-ID: <20060807063054.GA11483@2ka.mipt.ru>
References: <20060807060155.GA6487@2ka.mipt.ru> <20060806.232339.30184217.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:65261 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751114AbWHGGbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 02:31:09 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060806.232339.30184217.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 06, 2006 at 11:23:39PM -0700, David Miller (davem@davemloft.net) wrote:
> > +	if ((1UL << order) > size + sizeof(void *) + sizeof(struct skb_shared_info)) {
> 
> get_order() returns a PAGE_SIZE order not a byte one.  So this test
> here at the end is incorrect.  It should probably be something
> like "if ((PAGE_SIZE << order) > ..."
> 
> I don't know if I want to eat an entire extra allocation for every SKB
> just to handle broken e1000 cards that can't be bothered to support
> non-power-of-2 receive buffer sizes and a proper MTU setting.
> 
> I guess we might have to, but this is extremely unfortunate. :-/

I have even better idea - create alloc_skb_aligned() for those who
knows in advance, that it's size is always aligned to power of 2, so
additional skb_shared_info will 100% require higher order allocation.
Then e1000 can use that instead of usual alloc_skb().

-- 
	Evgeniy Polyakov
