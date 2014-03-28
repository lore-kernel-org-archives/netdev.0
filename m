From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] net: Account for all vlan headers in
 skb_mac_gso_segment
Date: Fri, 28 Mar 2014 17:10:50 -0400 (EDT)
Message-ID: <20140328.171050.472173056877978647.davem@davemloft.net>
References: <1395955578-16715-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40961 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751902AbaC1VKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 17:10:53 -0400
In-Reply-To: <1395955578-16715-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vyasevic@redhat.com>
Date: Thu, 27 Mar 2014 17:26:18 -0400

> skb_network_protocol() already accounts for multiple vlan
> headers that may be present in the skb.  However, skb_mac_gso_segment()
> doesn't know anything about it and assumes that skb->mac_len
> is set correctly to skip all mac headers.  That may not
> always be the case.  If we are simply forwarding the packet (via
> bridge or macvtap), all vlan headers may not be accounted for.
> 
> A simple solution is to allow skb_network_protocol to return
> the vlan depth it has calculated.  This way skb_mac_gso_segment
> will correctly skip all mac headers.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
> ---
> Since v1:
>  - Removed conditionals and used dummy variables as suggested by
>    Eric Dumazet.

Applied, thanks.
