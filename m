From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Mon, 21 Jul 2008 09:51:24 -0700 (PDT)
Message-ID: <20080721.095124.89249903.davem@davemloft.net>
References: <20080721161616.GA12938@gondor.apana.org.au>
	<20080721.092556.227421936.davem@davemloft.net>
	<20080721164306.GA13131@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55658
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751407AbYGUQvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 12:51:24 -0400
In-Reply-To: <20080721164306.GA13131@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 22 Jul 2008 00:43:06 +0800

> So let's assume that these flows have been distributed uniformly
> by both the RX hash and the TX hash such that each queue is handling
> ~250 flows.  If the TX hash does not match the result produced by
> the RX hash, you're going to get a hell lot of contention once you
> get into the NIC driver on the TX side.

How so?  If the TX hash is well distributed, which it should be,
it is at least going to approximate the distribution provided by
the RX hash.

> The benefit as far as I can see is that this would allow a packet's
> entire journey through Linux to stay on exactly one CPU.  There will
> be zero memory written by multiple CPUs as far as that packet is
> concerned.

So will the existing one, enough of the time for it to matter,
and yes even on a router or firewall.

At least this is my belief :-)
