From: David Miller <davem@davemloft.net>
Subject: Re: ppp/l2tp doing oversized allocations ?
Date: Sat, 19 May 2012 02:34:32 -0400 (EDT)
Message-ID: <20120519.023432.358297991561179289.davem@davemloft.net>
References: <20120519.004652.2261671316587735315.davem@davemloft.net>
	<1337403685.7029.63.camel@edumazet-glaptop>
	<1337408730.7029.69.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, netdev@vger.kernel.org,
	kernel-team@fedoraproject.org, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47736 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827Ab2ESGei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 02:34:38 -0400
In-Reply-To: <1337408730.7029.69.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 19 May 2012 08:25:30 +0200

> On Sat, 2012-05-19 at 07:01 +0200, Eric Dumazet wrote:
>> On Sat, 2012-05-19 at 00:46 -0400, David Miller wrote:
>> 
>> > So it's ESP encapsulated IPSEC over L2tp.
>> > 
>> > Eric, I wonder if session->hdr_len can take on undesirable values and
>> > thus trip up the skb COW'ing calculations you added?
>> 
>> I take a look, thanks
>> 
> 
> hdr_len is u16, I have no idea how we can reach MAX_ORDER page
> allocations... (more than 2 Mbytes...)
> 
> Maybe a memory corruption, or a signed/unsigned mismatch.

Yes, the trace looks really weird to me too.

It's also possible that the big length comes accidently from IPSEC
too.

If this can be readily reproduced, we can construct some debugging
patches for the user to try.
