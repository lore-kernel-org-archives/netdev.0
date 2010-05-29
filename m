From: David Miller <davem@davemloft.net>
Subject: Re: Warning in net/ipv4/af_inet.c:154
Date: Sat, 29 May 2010 00:21:24 -0700 (PDT)
Message-ID: <20100529.002124.149815573.davem@davemloft.net>
References: <20100526031943.GA28295@kryten>
	<20100526.005634.48509140.davem@davemloft.net>
	<1274868776.2672.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38377
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753579Ab0E2HVN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 May 2010 03:21:13 -0400
In-Reply-To: <1274868776.2672.96.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 26 May 2010 12:12:56 +0200

> [PATCH] net: fix sk_forward_alloc corruptions
> 
> As David found out, sock_queue_err_skb() should be called with socket
> lock hold, or we risk sk_forward_alloc corruption, since we use non
> atomic operations to update this field.
> 
> This patch adds bh_lock_sock()/bh_unlock_sock() pair to three spots.
> (BH already disabled)
> 
> 1) skb_tstamp_tx() 
> 2) Before calling ip_icmp_error(), in __udp4_lib_err() 
> 3) Before calling ipv6_icmp_error(), in __udp6_lib_err()
> 
> Reported-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

This wasn't the direct cause of Anton's problems but is
a serious legitimate bug.

So, applied, thanks!
