From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Tue, 27 Jan 2015 14:10:18 -0800 (PST)
Message-ID: <20150127.141018.1208673547021029175.davem@davemloft.net>
References: <20150127112304.GA4548@gondor.apana.org.au>
	<20150127114028.GG22262@casper.infradead.org>
	<20150127203924.GB9061@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, David.Laight@ACULAB.COM, ying.xue@windriver.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753842AbbA0WKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 17:10:22 -0500
In-Reply-To: <20150127203924.GB9061@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 28 Jan 2015 07:39:24 +1100

> On Tue, Jan 27, 2015 at 11:40:28AM +0000, Thomas Graf wrote:
>> 
>> This is unrelated to resize run control though, the reason is that
>> I'm converting tcp_hashinfo et al and they require a hybrid approach.
>> The tables may be too big to construct a parallel data structure, we
>> don't want to hold off inserts or deletes while the expensive dump
>> is underway. Even though we can't build a shadow structure while
>> locking everybody else out, we still want to provide a way to somehow
>> achieve consistent information. I think that NLM_F_INTR with fallback
>> to restarting the dump is a good option and very easy to implement. In
>> that case, we want to lock out resize from dumping iterations but
>> still allow parallel insert/delete.
> 
> Well I guess Dave needs to make the call.  Do we want to allow
> lockless walks over the hash table or not?
> 
> Personally I don't think a linked list is that big a deal.  But then
> you guys were agonsing over a single pointer so who knows.

For netlink a linked list is no big deal, but for something like TCP
sockets it really is.
