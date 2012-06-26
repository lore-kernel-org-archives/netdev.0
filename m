From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 00:46:58 -0700 (PDT)
Message-ID: <20120626.004658.2123525722448546355.davem@davemloft.net>
References: <20120626.002124.2220875506847485306.davem@davemloft.net>
	<1340696398.10893.209.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59230 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754808Ab2FZHrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 03:47:00 -0400
In-Reply-To: <1340696398.10893.209.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Jun 2012 09:39:58 +0200

> On Tue, 2012-06-26 at 00:21 -0700, David Miller wrote:
>> IPv4 routing cache entries no longer use dst->expires, because the
>> metrics, PMTU, and redirect information are stored in the inetpeer
>> cache.
>> 
>> Signed-off-by: David S. Miller <davem@davemloft.net>
>> ---
>> 
>> Eric, when you did commit 9f28a2fc0bd77511f649c0a788c7bf9a5fd04edb
>> (ipv4: reintroduce route cache garbage collector) do you remember
>> if the thing we needed was the real expiry or both the
>> rt_is_expired() and the rt_may_expire() cases?
>> 
>> I really want to remove rt_may_expire() from this conditional because
>> it results in absolutely stupid behavior.  If your system is idle
>> for 5 minutes, all of your input routing cache entries are purged.
> 
> Hmm, after a DDOS, purging all those routing cache entries in 5 minutes
> is good to recover some Mbytes of kernel memory.

And for legitimate traffic it's completely the wrong thing to do.

There is absolutely zero reason to pure valid entries when hash chains
average length of one.

I've been monitoring routing cache activity, and it's the height of
stupidity.  Every 5 minutes we pure, and then they all get regenerated
again.

Routing cache entries are expensive to recreate, it's much easier to
just keep them around then to potentially eat four full trie lookups
because that's what it will cost to reconstitute those guys.

But regardless, could you actually answer the question I asked of you?
