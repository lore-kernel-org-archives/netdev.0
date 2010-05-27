From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix lock_sock_bh/unlock_sock_bh
Date: Wed, 26 May 2010 22:23:32 -0700 (PDT)
Message-ID: <20100526.222332.233688655.davem@davemloft.net>
References: <20100526.212105.212688828.davem@davemloft.net>
	<1274936763.2542.42.camel@edumazet-laptop>
	<1274937618.2542.46.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48017
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751039Ab0E0FXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 01:23:22 -0400
In-Reply-To: <1274937618.2542.46.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 27 May 2010 07:20:18 +0200

> [PATCH v2] net: fix lock_sock_bh/unlock_sock_bh
> 
> This new sock lock primitive was introduced to speedup some user context
> socket manipulation. But it is unsafe to protect two threads, one using
> regular lock_sock/release_sock, one using lock_sock_bh/unlock_sock_bh
> 
> This patch changes lock_sock_bh to be careful against 'owned' state.
> If owned is found to be set, we must take the slow path.
> lock_sock_bh() now returns a boolean to say if the slow path was taken,
> and this boolean is used at unlock_sock_bh time to call the appropriate
> unlock function.
> 
> After this change, BH are either disabled or enabled during the
> lock_sock_bh/unlock_sock_bh protected section. This might be misleading,
> so we rename these functions to lock_sock_fast()/unlock_sock_fast().
> 
> Reported-by: Anton Blanchard <anton@samba.org>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Looks good, I'll wait for positive testing from Anton before applying
this.
