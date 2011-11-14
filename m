From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/4] ipv4: Update pmtu informations on inetpeer only
 for output routes
Date: Mon, 14 Nov 2011 11:12:44 +0100
Message-ID: <20111114101244.GB20943@secunet.com>
References: <20111011110842.GC1830@secunet.com>
 <20111011111027.GE1830@secunet.com>
 <20111012.170805.2172804476308993385.davem@davemloft.net>
 <20111108.143630.106539981030509701.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49049 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752428Ab1KNKMq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 05:12:46 -0500
Content-Disposition: inline
In-Reply-To: <20111108.143630.106539981030509701.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 08, 2011 at 02:36:30PM -0500, David Miller wrote:
> 
> What I think you can do to solve this problem is explicitly use
> dst->ops->default_mtu() in ip_forward() instead of dst_mtu().
> 

Unfortunately, that's not sufficient. We need to do an input route
check in ip_skb_dst_mtu() at least to get plain ipv4 to work,
IPsec is still broken then. So I assume most (all?) callers of
dst_mtu() don't want to get the cached PMTU for input routes on ipv4.

So for the moment I'm thinking about adding an ip_dst_mtu()
function that returns dst->ops->default_mtu() for input routes
and dst_mtu() for output routes. Then we could convert the
dst_mtu() users in net/ipv4/ over to this one.
