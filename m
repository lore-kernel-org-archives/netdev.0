From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rps: tcp: fix rps_sock_flow_table table updates
Date: Fri, 04 Jun 2010 15:57:34 -0700 (PDT)
Message-ID: <20100604.155734.260106618.davem@davemloft.net>
References: <1275591838.2533.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45097
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755920Ab0FDW5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jun 2010 18:57:24 -0400
In-Reply-To: <1275591838.2533.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jun 2010 21:03:58 +0200

> I believe a moderate SYN flood attack can corrupt RFS flow table
> (rps_sock_flow_table), making RPS/RFS much less effective.
> 
> Even in a normal situation, server handling short lived sessions suffer
> from bad steering for the first data packet of a session, if another SYN
> packet is received for another session.
> 
> We do following action in tcp_v4_rcv() :
> 
> 	sock_rps_save_rxhash(sk, skb->rxhash);
> 
> We should _not_ do this if sk is a LISTEN socket, as about each
> packet received on a LISTEN socket has a different rxhash than
> previous one.
>  -> RPS_NO_CPU markers are spread all over rps_sock_flow_table.
> 
> Also, it makes sense to protect sk->rxhash field changes with socket
> lock (We currently can change it even if user thread owns the lock
> and might use rxhash)
> 
> This patch moves sock_rps_save_rxhash() to a sock locked section,
> and only for non LISTEN sockets.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
