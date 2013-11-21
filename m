From: David Miller <davem@davemloft.net>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Wed, 20 Nov 2013 21:23:21 -0500 (EST)
Message-ID: <20131120.212321.700376819925646003.davem@davemloft.net>
References: <alpine.DEB.2.02.1311201220510.19725@tomh.mtv.corp.google.com>
	<20131120.190252.940036939480739452.davem@davemloft.net>
	<CA+mtBx91hSmYKrbUsPrtnXRjYR8QDGZ+GAAnMixauUqw9LFkiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, hkchu@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab3KUCXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 21:23:24 -0500
In-Reply-To: <CA+mtBx91hSmYKrbUsPrtnXRjYR8QDGZ+GAAnMixauUqw9LFkiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 20 Nov 2013 17:09:01 -0800

> I think the sw_rxhash holds more useful information.  In
> skb_get_rxhash() either we have an L4 hash or we try to get one by
> doing the SW computation, this means we don't ever return a HW hash
> which is not L4 so basically that case is treated as an invalid hash.
> So after a call to skb_get_rxhash, at least one of l4_rxhash or
> sw_rxhash is and we won't redo flow dissection on subsequent calls
> unless the rxhash is cleared.

Ok.... one interesting issue remains, which is that the SW flow
dissector considers decapsulating protocols like AH and ESP as
"L4".

I think we'll need to do something about that at some point.
