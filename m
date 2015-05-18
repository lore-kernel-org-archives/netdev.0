From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: preserve geometry of fragment sizes when
 forwarding
Date: Mon, 18 May 2015 16:55:50 -0400 (EDT)
Message-ID: <20150518.165550.359134808190719687.davem@davemloft.net>
References: <20150518200637.GB20709@breakpoint.cc>
	<20150518.162854.1116793790405432801.davem@davemloft.net>
	<20150518204049.GC20709@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	edumazet@google.com, herbert@gondor.apana.org.au
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbbERUz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 16:55:57 -0400
In-Reply-To: <20150518204049.GC20709@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 18 May 2015 22:40:49 +0200

> But, to the best of my understanding, what you ask will push a lot of
> non-trivial code into the kernel for no functional gain over
> what has been proposed.

The functional gain is that we stop linearizing the packet, which
involves memory allocation and copying the entire packet.

I am very confident that the performance gains would be non-trivial
and quite measurable.

You'd also be able to trivially respect the geometry of the original
incoming packet stream.

Every objection has been of the form "this special case" (this time
SIP) is not easy.

If I were doing this, I would implement something that handles the
normal cases properly.  And then take it from there.

If you try to imagine the totality of it and all the edge cases
and details from the beginning, yes it will look impossible.
