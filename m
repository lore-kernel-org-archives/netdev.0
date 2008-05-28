From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 21:51:10 +0400
Message-ID: <20080528175110.GA6210@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <20080528141104.GA5543@2ka.mipt.ru> <200805281820.02143.opurdila@ixiacom.com> <200805282008.02136.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47739 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751919AbYE1RvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 13:51:20 -0400
Content-Disposition: inline
In-Reply-To: <200805282008.02136.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2008 at 08:08:01PM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> Hmm, might have found a problem with this approach: say we drop the lock, 
> queue the data into the pipe, and at the same time tcp_collapse() is called 
> which frees some of the skbs of which data we just queued in the pipe. Later, 
> when we will read from the pipe, we will get random data instead of socket 
> data...
 
We queue data under the lock and clone appropriate skb (and then grab it
multiple times), so even it will be dropped, its data will not freed, and
thus we will be able to read it. Or you are talking about different
skbs?

-- 
	Evgeniy Polyakov
