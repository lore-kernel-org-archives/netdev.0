From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: Eliminate gso_send_check
Date: Fri, 26 Sep 2014 00:23:43 -0400 (EDT)
Message-ID: <20140926.002343.1473744968675123105.davem@davemloft.net>
References: <1411249950-6795-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbaIZEXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 00:23:45 -0400
In-Reply-To: <1411249950-6795-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sat, 20 Sep 2014 14:52:27 -0700

> gso_send_check presents a lot of complexity for what it is being used
> for. It seems that there are only two cases where it might be effective:
> TCP and UFO paths. In these cases, the gso_send_check function
> initializes the TCP or UDP checksum respectively to the pseudo header
> checksum so that the checksum computation is appropriately offloaded or
> computed in the gso_segment functions. The gso_send_check functions
> are only called from dev.c in skb_mac_gso_segment when ip_summed !=
> CHECKSUM_PARTIAL (which seems very unlikely in TCP case). We can move
> the logic of this into the respective gso_segment functions where the
> checksum is initialized if ip_summed != CHECKSUM_PARTIAL.
> 
> With the above cases handled, gso_send_check is no longer needed, so
> we can remove all uses of it and the fields in the offload callbacks.
> With this change, ip_summed in the skb should be preserved though all
> the layers of gso_segment calls.
> 
> In follow-on patches, we may be able to remove the check setup code in
> tcp_gso_segment if we can guarantee that ip_summed will always be
> CHECKSUM_PARTIAL (verify all paths and probably add an assert in
> tcp_gro_segment).
> 
> Tested these patches by:
>   - netperf TCP_STREAM test with GSO enabled
>   - Forced ip_summed != CHECKSUM_PARTIAL with above
>   - Ran UDP_RR with 10000 request size over GRE tunnel. This exercised
>     UFO path.

Series applied, thanks Tom.
