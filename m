From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Convert skb->csum_(start|offset) integrity
 BUG_ON() to WARN_ON() & drop
Date: Wed, 13 Feb 2013 19:37:59 -0500 (EST)
Message-ID: <20130213.193759.1094469499685059296.davem@davemloft.net>
References: <20130213234021.GA21829@casper.infradead.org>
	<20130213234843.GB21829@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752940Ab3BNAiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2013 19:38:00 -0500
In-Reply-To: <20130213234843.GB21829@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed, 13 Feb 2013 23:48:43 +0000

> On 02/13/13 at 11:40pm, Thomas Graf wrote:
>> They have been hit with IPoIB which uses a 64K MTU. If a TCP
>> retransmission gets partially ACKed and collapsed multiple times
>> it is possible for the headroom to grow beyond 64K which will
>> overflow the 16bit skb->csum_start.
> 
> On the subject of fixing this, I considered:
> 
>  a) Reallocate the headroom in tcp_trim_head() if it would
>     overflow. I disregarded this idea because replacing the
>     old skb with the new skb on the write queue for such a
>     rare situation seems overkill.
> 
>  b) No longer collapse if the new skb would result in a
>     a headroom + data that exceeds 64K. This seems to be the
>     most trivial fix.
> 
>  c) Increase size of csum_start or store checksum_start_offset
>     differently.
> 
> Other ideas?

"b" is a good idea.

Let's not paper over this, this BUG_ON() is really a BUG_ON()
meaning "FIX ME NOW" :-)
