From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Wed, 23 Jul 2008 14:21:47 -0700 (PDT)
Message-ID: <20080723.142147.61941255.davem@davemloft.net>
References: <4887550B.2070704@tvcablenet.be>
	<4887555A.30605@trash.net>
	<48875B8C.2090800@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: francois.valenduc@tvcablenet.be, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	jussi.kivilinna@mbnet.fi
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754462AbYGWVVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 17:21:47 -0400
In-Reply-To: <48875B8C.2090800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 23 Jul 2008 18:25:48 +0200

> We can't fit them into the cb together, I don't see a way to
> shrink ieee80211_tx_info.
> 
> Maybe one of the wireless folks can suggest something? Is it
> really necessary to pass the full struct ieee80211_tx_info
> through the qdisc layer, or could the struct be split? It
> needs to find a way to co-exist peacefully with qdiscs'
> skb->cb usage.

This is another area that got mangled up in the ->select_queue()
conversion of the WME bits, but in another aspect this problem
existed beforehand as well.

Specifically, when RX packets get requeued out to transmit in
the code in net/mac80211/rx.c that resends packets back out the
wireless device by setting a bit in the SKB CB then calling
dev_queue_xmit().

That's completely illegal :-)

There's a ton of stuff in that structure, I can't see how to
make it smaller either.  Maybe some bits only matter through
the layers of the TX mac80211 stack and thus can be passed
as parameters during such processing?

