From: David Miller <davem@davemloft.net>
Subject: Re: Get rxhash fixes and RFS support in tun
Date: Wed, 20 Nov 2013 21:50:25 -0500 (EST)
Message-ID: <20131120.215025.590189385589840672.davem@davemloft.net>
References: <CA+mtBx91hSmYKrbUsPrtnXRjYR8QDGZ+GAAnMixauUqw9LFkiQ@mail.gmail.com>
	<20131120.212321.700376819925646003.davem@davemloft.net>
	<CA+mtBx8g9uYOc0euQiEDi8qfx_ZggsE_Wn8N5R+peE1_N4WKEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, hkchu@google.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965Ab3KUCu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 21:50:28 -0500
In-Reply-To: <CA+mtBx8g9uYOc0euQiEDi8qfx_ZggsE_Wn8N5R+peE1_N4WKEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 20 Nov 2013 18:42:48 -0800

> We need the rxhash to be the value seen at the point of RPS (to do RFS
> correctly), which I think probably means we don't ever want to change
> it after the first calculation! (clearing at tunnel decap wouldn't be
> correct either)  For ESP or AH, I believe it's appropriate to use SPI
> as a substitute for ports.

But that means that all connections going over the same IPSEC path
hash to the same value.

I really think that xfrm_input() should zap the rxhash near the
existing nf_reset() call.

The same argument goes for tunnels, that is why ip_tunnel_core.c does
what it does with the rxhash clearing right now.

In both the IPSEC tunnel (not transport) and normal IP/GRE tunnel
cases, it's a completely new SKB receive, done via netif_rx(), after
decapsulation.

That leaves only IPSEC transport mode as the only case where RFS isn't
(re-)performed but we can build infrastructure to make that happen.
