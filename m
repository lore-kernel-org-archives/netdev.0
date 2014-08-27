From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: ipv4: drop unicast encapsulated in L2 multicast
Date: Wed, 27 Aug 2014 11:13:12 +0200
Message-ID: <1409130792.2505.5.camel@jlt4.sipsolutions.net>
References: <1408641747-22199-1-git-send-email-johannes@sipsolutions.net>
	 <alpine.LFD.2.11.1408212119510.1896@ja.home.ssi.bg>
	 <20140822.105405.1982870131653082781.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:44595 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754967AbaH0JNU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2014 05:13:20 -0400
In-Reply-To: <20140822.105405.1982870131653082781.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-08-22 at 10:54 -0700, David Miller wrote:

> > 	Is this place better, after checking for RTN_BROADCAST?
> > 
> > 	/* ARP link-layer broadcasts are acceptable here */
> > 	if ((skb->pkt_type == PACKET_BROADCAST ||
> > 	     skb->pkt_type == PACKET_MULTICAST) &&
> > 	    skb->protocol == htons(ETH_P_IP))
> > 		goto e_inval;
> 
> Indeed, this would make ARP happier, but that still leaves open the
> issue of CLUSTERIP.

Unfortunately, I have no idea how to determine that CLUSTERIP is active
here? Do we need to tag frames, or would a sysctl work?

Or should we go back to the drawing board and not make this change in
the IP stack at all? But parsing all the IP layer in the wireless stack
is really quite ugly as well.

johannes
