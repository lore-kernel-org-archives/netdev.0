From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bridge: use the maximum hard_header_len of ports
 for bridging device
Date: Mon, 23 Mar 2009 15:47:51 -0700 (PDT)
Message-ID: <20090323.154751.190788467.davem@davemloft.net>
References: <20090323085122.4c9d21f2@nehalam>
	<20090323.152028.205335400.davem@davemloft.net>
	<20090323154517.2146a357@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42259
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751089AbZCWWsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2009 18:48:06 -0400
In-Reply-To: <20090323154517.2146a357@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 23 Mar 2009 15:45:17 -0700

> So you dynamically compute the additional space but if the space was
> an awkward size, could it cause driver to breaks alignment assumptions?

Yes, you'd need to 16-byte align or something like that.

> And you didn't fixup the skb that is about to gag in the skb to make
> more space, so transmitting device driver (gfar) is going to overwrite or die.

This particular instance will do the headroom reallocation,
that's unavoidable during the size transition event.

The headroom checks can't ever be removed, but we won't hit
them in the fast path after the adjustment is made by my
patch.
