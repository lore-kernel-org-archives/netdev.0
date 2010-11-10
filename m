From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Prevent reading uninitialized memory with socket
 filters
Date: Wed, 10 Nov 2010 10:07:52 -0800 (PST)
Message-ID: <20101110.100752.71107177.davem@davemloft.net>
References: <1289341724.7380.13.camel@dan>
	<20101109.212838.193698340.davem@davemloft.net>
	<1289387567.7380.63.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org, security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38656
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755372Ab0KJSH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 13:07:28 -0500
In-Reply-To: <1289387567.7380.63.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Wed, 10 Nov 2010 06:12:47 -0500

> 
>> 
>> Prove it.
> 
> I hope this was a joke.

It absolutely is not.

You are very much not the first person ever to try and add an
expensive memset() here.

So the onus is really on you to prove this assertion and show the
exact code path by which the user can actually see any uninitialized
kernel stack memory (he can't, he can peek at certain values in a
certain extremely contrived range, making the leak useless), rather
than point us at some web external site archive of a list posting
which we cannot easily quote and reply to here.

I think you cannot do it, really.  Except in the AF_PACKET case, the
sockets can only see "0" or a negative error code, not the actual
sk_run_filter() return value.

In the one exception, AF_PACKET, the range of values the user can
see are in the range of MTU of the device being accessed, which
realistically is 1500 bytes.  This means the user cannot see any
kernel stack value outside of the range 0 to 1500, which isn't
worth using this expensive memset to guard against at all.

I don't even think it's worth adding all of the extra cpu cycles
incurred by Eric Dumazet's scheme of using a bitmap test on every
single memory buffer access.

