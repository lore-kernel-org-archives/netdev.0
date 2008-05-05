From: David Miller <davem@davemloft.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 13:02:25 -0700 (PDT)
Message-ID: <20080505.130225.159803012.davem@davemloft.net>
References: <1210014316.4181.14.camel@johannes.berg>
	<20080505.125013.129139559.davem@davemloft.net>
	<1210017456.4181.23.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tomasw@gmail.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53040
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753813AbYEEUCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 16:02:25 -0400
In-Reply-To: <1210017456.4181.23.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 05 May 2008 21:57:36 +0200

> Not necessarily because we seem to be getting a lot of cloned frames
> that we need to copy all the time. If we would remove the ethernet
> header and stick that skb into the fraglist of a new skb we'd win.

And the copy is necessary because you need more tailroom or something?

I don't understand why simply having all the space you need is not
better and faster :-)

Even if you have a clone, you can muck with the data in the IP and TCP
header areas, so long as skb_header_cloned() is false.

So I can only conclude that your problematic case is that of
encryption, right?  That's the only situation where I can imagine you
need to modify with packet data outside of the protocol headers.
