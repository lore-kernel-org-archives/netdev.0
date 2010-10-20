From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: avoid RCU for NOCACHE dst
Date: Wed, 20 Oct 2010 03:03:08 -0700 (PDT)
Message-ID: <20101020.030308.39191390.davem@davemloft.net>
References: <1287157451.2647.126.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49004
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752672Ab0JTKCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 06:02:46 -0400
In-Reply-To: <1287157451.2647.126.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Oct 2010 17:44:11 +0200

> There is no point using RCU for dst we allocate for a very short time
> (used once).
> 
> Change dst_release() to take DST_NOCACHE into account, but also change
> skb_dst_set_noref() to force a refcount increment for such dst.
> 
> This is a _huge_ gain, because we dont waste memory to store xx thousand
> of dsts. Instead of queueing them to RCU, we can free them instantly. 
 ...
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Wonderful, we are now faster without the routing cache. :-)

Applied.
