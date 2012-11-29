From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH V2 3/9] net: frag, move LRU list maintenance
 outside of rwlock
Date: Thu, 29 Nov 2012 13:05:06 -0500 (EST)
Message-ID: <20121129.130506.329791401604974668.davem@davemloft.net>
References: <1354211004.3299.12.camel@edumazet-glaptop>
	<20121129.124839.963269461515687321.davem@davemloft.net>
	<1354211659.3299.15.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, tgraf@suug.ch, amwang@redhat.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	herbert@gondor.hengli.com.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33898 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab2K2SFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:05:08 -0500
In-Reply-To: <1354211659.3299.15.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Nov 2012 09:54:19 -0800

> One element can hold about 100KB.
> 
> I guess some systems could have some worries if we consume 1024 * 5 *
> 100 KB

That's true.

Replace 1024 in your formula with X and the limit is therefore
controlled by X.

So it seems the high_thresh can be replaced with an appropriate
determination of X to size the hash.

If X is 256, that limits us to ~130MB per cpu.

We could also tweak the chain limit, call it Y, as well.
