From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH stable 3.4 1/2] ipv4: move route garbage collector to
 work queue
Date: Tue, 12 Aug 2014 17:46:21 -0700 (PDT)
Message-ID: <20140812.174621.1935425856781215649.davem@davemloft.net>
References: <1407879692.16087.5.camel@localhost>
	<20140812.154255.2235928819945086905.davem@davemloft.net>
	<1407885074.3535486.152056309.7BDE2766@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@redhat.com, eric.dumazet@gmail.com, mleitner@redhat.com,
	netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40234 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbaHMAqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Aug 2014 20:46:23 -0400
In-Reply-To: <1407885074.3535486.152056309.7BDE2766@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 13 Aug 2014 01:11:14 +0200

> On Wed, Aug 13, 2014, at 00:42, David Miller wrote:
>> Just bite the bullet and put a spinlock around the GC operation.
> 
> We had a spinlock around the GC operation at first but still were
> capable to cause softlockups, I don't remember if a complete lockup
> happend.

This much I understand.

What I'm saying is retain this patch #1, in order to make the normal
GCs run asynchronously via a work queue, but on top of that put a
spinlock around the GC function.

> Should be no problem to conditional synchronize with the neighbour
> overflow path.

Once you have the spinlock around the GC it should be just fine.

If we hit the neighbour table overflow condition when an async GC is
operating, the direct GC call from the neighbour table overflow path
will just spin on the lock waiting for the async GC to complete.
