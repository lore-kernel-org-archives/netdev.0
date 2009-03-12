From: David Miller <davem@davemloft.net>
Subject: Re: VIA velocity skb leak.
Date: Wed, 11 Mar 2009 21:20:09 -0700 (PDT)
Message-ID: <20090311.212009.51140677.davem@davemloft.net>
References: <20090312041352.GA6035@redhat.com>
	<20090311.211706.68465072.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60042
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751025AbZCLEUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 00:20:23 -0400
In-Reply-To: <20090311.211706.68465072.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 11 Mar 2009 21:17:06 -0700 (PDT)

> 
> velocity_xmit() needs to set 'pktlen = skb->len;' after,
> not before, the skb_padto() call.

Actually that won't work since, as you suggest, skb->len
isn't updated by skb_padto().

So the transmit needs something like:

	pktlen = (skb->len > ETH_ZLEN ? : ETH_ZLEN);

velocity_free_tx_buf() needs to make the same calculation
instead of just plain skb->len

This bug probably exists in every other driver using
skb_padto() :-)


