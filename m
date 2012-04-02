From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: check the length of the data before dereferencing
 it
Date: Sun, 01 Apr 2012 23:57:24 -0400 (EDT)
Message-ID: <20120401.235724.1615627410446519543.davem@davemloft.net>
References: <20120401.232942.1829187970291547571.davem@davemloft.net>
	<CABa6K_HfWckb=sv7oQatv2ZJm3EKJE0mutQQ-OiddXiR6E7eHg@mail.gmail.com>
	<1333338797.2325.6610.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, kaber@trash.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1333338797.2325.6610.camel@edumazet-glaptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Apr 2012 05:53:17 +0200

> On Mon, 2012-04-02 at 11:45 +0800, Changli Gao wrote:
> 
>> Thinking about a malformed tcp segment, which has no data but silly
>> options, and whose last byte is neither TCPOPT_EOL or TCPOPT_NOP, we
>> will try to dereference one byte over the boundary when parsing the
>> options. I know we have skb_shared_info at the end and it won't cause
>> any crash, but should we rely on this fact?
>> 
> 
> No we cant rely on this, kmemcheck might barf on us.

Give me a break.

The code does the right thing, in every possible case, and
in every possible valid state of an SKB.

If we can't make kmemcheck handle that, tough, I'm not adding useless
tests to a function, specifically tests which are always there and
that don't fix anything.
