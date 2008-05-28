From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 12:52:41 +0400
Message-ID: <20080528085241.GA30367@2ka.mipt.ru>
References: <200805270325.24323.opurdila@ixiacom.com> <20080527154710.GA6305@2ka.mipt.ru> <20080527172849.GA14746@2ka.mipt.ru> <200805280259.30931.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59412 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbYE1Iw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 04:52:57 -0400
Content-Disposition: inline
In-Reply-To: <200805280259.30931.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 28, 2008 at 02:59:30AM +0300, Octavian Purdila (opurdila@ixiacom.com) wrote:
> One doubt though: suppose that while we drop the lock the skb gets aggregated 
> with the one after it. If the original skb is fully consumed in the receive 
> actor, then the we will eat the new, aggregated skb, loosing data. 

How can it be aggregated with another skb? It is only possible that some
other reader consumes the data, but in that case sequence number will
not match and we will not find skb.

> Here is a patch, based on your idea, which tries to cope with the above 
> scenario. The !skb check was added for the case in which the actor does not 
> consume anything in the current interration. 

If it does not get any data, then skb will likely exists and will be
consumed in the next run. I preserved old semantic, when we free skb
only if we read it whole or in case of fin. With your changes we can
also free skb, if it was partially consumed and do not free it at all if
skb was not processed becuase it is too old (i.e. it lives in receive
queue, but we already read data siwth sequnce number, which corresponds
to it), no?


-- 
	Evgeniy Polyakov
