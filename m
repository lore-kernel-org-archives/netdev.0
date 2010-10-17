From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netns: reorder fields in struct net
Date: Sun, 17 Oct 2010 13:49:31 -0700 (PDT)
Message-ID: <20101017.134931.183048950.davem@davemloft.net>
References: <1287071778.2712.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53809
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932785Ab0JQUtI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Oct 2010 16:49:08 -0400
In-Reply-To: <1287071778.2712.73.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 14 Oct 2010 17:56:18 +0200

> In a network bench, I noticed an unfortunate false sharing between
> 'loopback_dev' and 'count' fields in "struct net".
> 
> 'count' is written each time a socket is created or destroyed, while
> loopback_dev might be often read in routing code.
> 
> Move loopback_dev in a read mostly section of "struct net"
> 
> Note: struct netns_xfrm is cache line aligned on SMP.
> (It contains a "struct dst_ops")
> Move it at the end to avoid holes, and reduce sizeof(struct net) by 128
> bytes on ia32.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
