From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: race in skb_splice_bits?
Date: Wed, 28 May 2008 20:08:01 +0300
Message-ID: <200805282008.02136.opurdila@ixiacom.com>
References: <200805270325.24323.opurdila@ixiacom.com> <20080528141104.GA5543@2ka.mipt.ru> <200805281820.02143.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixia01.ro.gtsce.net ([212.146.94.66]:4439 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751644AbYE1RJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2008 13:09:13 -0400
In-Reply-To: <200805281820.02143.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 28 May 2008, Octavian Purdila wrote:
>
> > So yes, your patch is simpler and faster than mine so you should push it
> > upstream. Fortunately David Miller is in copy and will (David, will
> > you?) pick it up and push, likely it is also needed for stable?
>

Hmm, might have found a problem with this approach: say we drop the lock, 
queue the data into the pipe, and at the same time tcp_collapse() is called 
which frees some of the skbs of which data we just queued in the pipe. Later, 
when we will read from the pipe, we will get random data instead of socket 
data...


Thanks,
tavi

