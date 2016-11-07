From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: icmp_route_lookup should use rt dev to determine
 L3 domain
Date: Mon, 07 Nov 2016 13:16:27 -0500 (EST)
Message-ID: <20161107.131627.595358248939910365.davem@davemloft.net>
References: <1478193219-5288-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39154 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932635AbcKGSQ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 13:16:28 -0500
In-Reply-To: <1478193219-5288-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Thu,  3 Nov 2016 10:13:39 -0700

> icmp_send is called in response to some event. The skb may not have
> the device set (skb->dev is NULL), but it is expected to have an rt.
> Update icmp_route_lookup to use the rt on the skb to determine L3
> domain.
> 
> Fixes: 613d09b30f8b ("net: Use VRF device index for lookups on TX")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

"skb_dst(...)->dev" would be more direct and look nicer.  No need to
use skb_rtable() just to walk backwards to the 'dst'.
