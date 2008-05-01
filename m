From: David Miller <davem@davemloft.net>
Subject: Re: mac80211 truesize bugs
Date: Thu, 01 May 2008 02:56:35 -0700 (PDT)
Message-ID: <20080501.025635.216053297.davem@davemloft.net>
References: <1209634349.4008.15.camel@johannes.berg>
	<20080501.024320.212547875.davem@davemloft.net>
	<1209635299.4008.21.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mb@bu3sch.de, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58600
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751795AbYEAJ4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 05:56:39 -0400
In-Reply-To: <1209635299.4008.21.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Thu, 01 May 2008 11:48:19 +0200

> > Signed-off-by: David S. Miller <davem@davemloft.net>
>  
> > +	/* This is safe because the buffer has been orphaned.  */
> > +	skb->truesize += sizeof(*rthdr);
> 
> Hmm. The disconnect between truesize and skb->len+sizeof(*skb) was
> usually 17 or 19 bytes and sizeof(*rthdr) is only 11. On the other hand,
> I don't see where the other bytes should be coming from. I'll give this
> a try, thanks.

Grrr, I bet it's coming from a combination of the
skb_set_mac_header(skb, 0); call done by mac80211 and the skb_push()
calls in net/packet/af_packet.c

davem@sunset:~/src/GIT/net-2.6$ egrep skb_push net/packet/af_packet.c
	skb_push(skb, skb->data - skb_mac_header(skb));
			skb_push(skb, skb->data - skb_mac_header(skb));
			skb_push(skb, skb->data - skb_mac_header(skb));
davem@sunset:~/src/GIT/net-2.6$ 
