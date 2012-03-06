From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: perform inetpeer binding at dst
 creation, with readonly option
Date: Tue, 06 Mar 2012 16:05:28 -0500 (EST)
Message-ID: <20120306.160528.1272258218296495399.davem@davemloft.net>
References: <4F56320B.60400@network-box.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nick.jones@network-box.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39650 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031130Ab2CFVFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 16:05:53 -0500
In-Reply-To: <4F56320B.60400@network-box.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Jones <nick.jones@network-box.com>
Date: Tue, 06 Mar 2012 23:49:31 +0800

> A neighbour advertises itself as obsolete and at a later time, the host
> sends solicitations to the neighbours direct address.  The NS icmp6
> packets have hoplimit explicitly set to 255.
> 
> The neighbour re-advertises itself.  All subsequent packets sent to the
> neighbour address will now have hoplimit stuck at 255 because the setup
> of the NS packet wrote 255 to the cached metrics of the inetpeer that
> the neighbour address' ip6_dst was bound to.  If the neighbour was a
> router, a RA that attempts to update the hoplimit for the route will
> have no effect because of the way ip6_dst_hoplimit works.
> 
> This patch adds an rt6_init_metrics method that is called shortly after
> a call to ip6_dst_alloc, it performs the inetpeer binding at that time.
> 
> It allows the caller to indicate whether they want the new ip6_dst
> metrics, and thus the inetpeer metrics, to be writable.  icmp6_dst_alloc
> will now no longer permanently alter the peer metrics.
> 
> Signed-off-by: Nick Jones <nick.jones@network-box.com>

So we essentially have two views of the same inetpeer.

I would say that the real fix for this is to just use kmalloc'd
metrics for these special icmp6 dsts and leave the rest of the
code alone.
