From: David Miller <davem@davemloft.net>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 03:32:21 -0700 (PDT)
Message-ID: <20080501.033221.193705040.davem@davemloft.net>
References: <1209635299.4008.21.camel@johannes.berg>
	<20080501.025635.216053297.davem@davemloft.net>
	<1209636494.4008.24.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54816
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751542AbYEAKcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:32:23 -0400
In-Reply-To: <1209636494.4008.24.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 01 May 2008 12:08:14 +0200

> > Grrr, I bet it's coming from a combination of the
> > skb_set_mac_header(skb, 0); call done by mac80211 and the skb_push()
> > calls in net/packet/af_packet.c
> > 
> > davem@sunset:~/src/GIT/net-2.6$ egrep skb_push net/packet/af_packet.c
> > 	skb_push(skb, skb->data - skb_mac_header(skb));
> > 			skb_push(skb, skb->data - skb_mac_header(skb));
> > 			skb_push(skb, skb->data - skb_mac_header(skb));
> 
> But mac80211 does set_mac_header(0) so this should just push zero bytes,
> no?

Right you are.

So, I wonder what's causing the problem...  Could you "remember" the
length and truesize at the skb_orphan() point in mac80211, right
after the skb_push(), then in the truesize warning, print those
"remembered" values as well as the current ones.

