From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] TCP connection timesout if ICMP frag needed is
 delayed
Date: Wed, 21 May 2008 16:43:08 -0700 (PDT)
Message-ID: <20080521.164308.147927212.davem@davemloft.net>
References: <1211413030.14663.42.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40250
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756780AbYEUXnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 19:43:12 -0400
In-Reply-To: <1211413030.14663.42.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Wed, 21 May 2008 16:37:10 -0700

> We are seeing an issue with TCP in handling an ICMP frag needed
> message that is received after net.ipv4.tcp_retries1 retransmits.
> The default value of retries1 is 3. So if the path mtu changes
> and ICMP frag needed is lost for the first 3 retransmits or if
> it gets delayed until 3 retransmits are done, TCP doesn't update
> MSS correctly and continues to retransmit the orginal message
> until it timesout after tcp_retries2 retransmits.
> I am seeing this issue even with the latest 2.6.25.4 kernel.
> 
> In tcp_retransmit_timer(), when retransmits counter exceeds 
> tcp_retries1 value, the dst cache entry of the socket is reset.
> At this time, if we receive an ICMP frag needed message, the 
> dst entry gets updated with the new MTU, but the TCP sockets
> dst_cache entry remains NULL.
> So the next time when we try to retransmit after the ICMP frag
> needed is received, tcp_retransmit_skb() gets called. Here the
> cur_mss value is calculated at the start of the routine with
> a NULL sk_dst_cache. Instead we should call tcp_current_mss after
> the rebuild_header that caches the dst entry with the updated mtu.
> Also the rebuild_header should be called before tcp_fragment
> so that skb is fragmented if the mss goes down.
> 
 ...
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

Excellent analysis and the patch looks fine to me, applied.

I'll queue this up to -stable as well.
