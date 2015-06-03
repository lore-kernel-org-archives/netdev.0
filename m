From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH v2 net-next] vlan: Add GRO support for non hardware
 accelerated vlan
Date: Wed, 3 Jun 2015 10:09:08 +0900
Message-ID: <20150603010908.GE30703@verge.net.au>
References: <1433163307-9299-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
 <1433167957.1895.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150601.145625.1435351866234972759.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, makita.toshiaki@lab.ntt.co.jp,
	kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56467 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbbFCBJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 21:09:11 -0400
Content-Disposition: inline
In-Reply-To: <20150601.145625.1435351866234972759.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 01, 2015 at 02:56:25PM -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 01 Jun 2015 07:12:37 -0700
> 
> > Can we ensure offload_base contains a sensible order of expected
> > types ?
> 
> This seemed easy enough to kill, so I pushed the following into net-next:
> 
> ====================
> [PATCH] net: Add priority to packet_offload objects.
> 
> When we scan a packet for GRO processing, we want to see the most
> common packet types in the front of the offload_base list.
> 
> So add a priority field so we can handle this properly.
> 
> IPv4/IPv6 get the highest priority with the implicit zero priority
> field.
> 
> Next comes ethernet with a priority of 10, and then we have the MPLS
> types with a priority of 15.

FWIW I have no objections to the priority assigned to MPLS.

> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Suggested-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
> Signed-off-by: David S. Miller <davem@davemloft.net>
