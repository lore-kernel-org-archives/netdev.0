From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sit: allow ip fragmentation when using nopmtudisc to
 fix package loss
Date: Fri, 28 Aug 2009 23:54:04 -0700 (PDT)
Message-ID: <20090828.235404.61171174.davem@davemloft.net>
References: <1251197322-3177-1-git-send-email-contact@saschahlusiak.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: contact@saschahlusiak.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083AbZH2Gxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 02:53:50 -0400
In-Reply-To: <1251197322-3177-1-git-send-email-contact@saschahlusiak.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Hlusiak <contact@saschahlusiak.de>
Date: Tue, 25 Aug 2009 12:48:42 +0200

> if tunnel parameters have frag_off set to IP_DF, pmtudisc on the ipv4 link
> will be performed by deriving the mtu from the ipv4 link and setting the
> DF-Flag of the encapsulating IPv4 Header. If fragmentation is needed on the
> way, the IPv4 pmtu gets adjusted, the ipv6 package will be resent eventually,
> using the new and lower mtu and everyone is happy.
> 
> If the frag_off parameter is unset, the mtu for the tunnel will be derived
> from the tunnel device or the ipv6 pmtu, which might be higher than the ipv4
> pmtu. In that case we must allow the fragmentation of the IPv4 packet because
> the IPv6 mtu wouldn't 'learn' from the adjusted IPv4 pmtu, resulting in
> frequent icmp_frag_needed and package loss on the IPv6 layer.
> 
> This patch allows fragmentation when tunnel was created with parameter
> nopmtudisc, like in ipip/gre tunnels.
> 
> Signed-off-by: Sascha Hlusiak <contact@saschahlusiak.de>

Seems reasonable, applied to net-next-2.6, thanks!
