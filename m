From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] net/core/sock.c remove extra wakeup
Date: Wed, 11 Jun 2008 16:46:12 +1000
Message-ID: <E1K6K60-00061s-00@gondolin.me.apana.org.au>
References: <483F990C0200005A00038001@sinclair.provo.novell.com>
Cc: davem@davemloft.net, PMullaney@novell.com, netdev@vger.kernel.org
To: GHaskins@novell.com (Gregory Haskins)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:46829 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752121AbYFKGqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 02:46:20 -0400
In-Reply-To: <483F990C0200005A00038001@sinclair.provo.novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gregory Haskins <GHaskins@novell.com> wrote:
> 
> So basically it was waiting for a packet to arrive, and the net-rx softirq would first trigger a NOSPACE wakeup (of which was a noop by the udp-rx code) followed by an rx-wakeup.  So the netperf thread woke twice for one packet.  Fixing this boosted performance by a large margin (don't recall exact figures off the top of my head....somewhere around 20%)

Please wrap your lines.

Anyway, you've lost me with this scenario.  The patch is stopping
wake-ups on the write path yet you're talking about the read path.
So my question is why are you getting the extra wake-up on that
write path when you receive a packet?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
