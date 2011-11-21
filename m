From: David Miller <davem@davemloft.net>
Subject: Re: root_lock vs. device's TX lock
Date: Mon, 21 Nov 2011 16:04:28 -0500 (EST)
Message-ID: <20111121.160428.284433780067739645.davem@davemloft.net>
References: <1321547698.2751.68.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1321550786.2751.83.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw6VfGKAk_gBZOjyCCcR0tCSc8PMjOoPv6Qi8m+P1idp4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: dave.taht@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40852 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756674Ab1KUVEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 16:04:31 -0500
In-Reply-To: <CAA93jw6VfGKAk_gBZOjyCCcR0tCSc8PMjOoPv6Qi8m+P1idp4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Taht <dave.taht@gmail.com>
Date: Thu, 17 Nov 2011 19:19:58 +0100

> On Thu, Nov 17, 2011 at 6:26 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>
>> For complex Qdisc / tc setups (potentially touching a lot of cache
>> lines), we could eventually add a small ring buffer so that the cpu
>> doing the ndo_start_xmit() also queues the packets into Qdisc.
>>
>> This ringbuffer could use a lockless algo. (we currently use the
>> secondary 'busylock' to serialize other cpus, but each cpu calls qdisc
>> enqueue itself.)
> 
> I was thinking ringbuffering might also help in adding a 'grouper'
> abstraction to the dequeuing side.

I fully support the idea of batching between these different levels of
the TX path, but keep in mind that this is only really going to work
well for simple qdiscs.
