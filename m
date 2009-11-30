From: David Miller <davem@davemloft.net>
Subject: Re: Problem with tcp (2.6.31) as first
Date: Mon, 30 Nov 2009 12:56:23 -0800 (PST)
Message-ID: <20091130.125623.44579269.davem@davemloft.net>
References: <4B0F0466.8080006@gmail.com>
	<20091129.233447.60856273.davem@davemloft.net>
	<4B138C73.8040401@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, ole@ans.pl, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45498
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752704AbZK3U4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 15:56:18 -0500
In-Reply-To: <4B138C73.8040401@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Nov 2009 10:12:19 +0100

> [PATCH] tcp: tcp_disconnect() should clear window_clamp
> 
> NFS can reuse its TCP socket after calling tcp_disconnect().
> We noticed window scaling was not negotiated in SYN packet of next connection request.
> 
> Fix is to clear tp->window_clamp in tcp_disconnect().
> 
> Reported-by: Krzysztof Oledzki <ole@ans.pl>
> Tested-by: Krzysztof Oledzki <ole@ans.pl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.

You voiced some concerns about window clamp route and socket settings
and whatnot.  But I think the route side should be OK.  When a new
connect() occurs, TCP will reinitialize the window clamp setting based
upon the route metric and other values.

The TCP_WINDOW_CLAMP socket option case is tedious however.  If we
want to preserve such settings across disconnect operations we'll need
to store two pieces of state I believe.
