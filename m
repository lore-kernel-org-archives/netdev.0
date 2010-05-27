From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix lock_sock_bh/unlock_sock_bh
Date: Thu, 27 May 2010 00:29:36 -0700 (PDT)
Message-ID: <20100527.002936.68139951.davem@davemloft.net>
References: <1274937618.2542.46.camel@edumazet-laptop>
	<20100526.222332.233688655.davem@davemloft.net>
	<20100527060923.GD28295@kryten>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40856
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754752Ab0E0H30 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 03:29:26 -0400
In-Reply-To: <20100527060923.GD28295@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Thu, 27 May 2010 16:09:23 +1000

> 
>> > [PATCH v2] net: fix lock_sock_bh/unlock_sock_bh
>> > 
>> > This new sock lock primitive was introduced to speedup some user context
>> > socket manipulation. But it is unsafe to protect two threads, one using
>> > regular lock_sock/release_sock, one using lock_sock_bh/unlock_sock_bh
>> > 
>> > This patch changes lock_sock_bh to be careful against 'owned' state.
>> > If owned is found to be set, we must take the slow path.
>> > lock_sock_bh() now returns a boolean to say if the slow path was taken,
>> > and this boolean is used at unlock_sock_bh time to call the appropriate
>> > unlock function.
>> > 
>> > After this change, BH are either disabled or enabled during the
>> > lock_sock_bh/unlock_sock_bh protected section. This might be misleading,
>> > so we rename these functions to lock_sock_fast()/unlock_sock_fast().
>> > 
>> > Reported-by: Anton Blanchard <anton@samba.org>
>> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> 
>> Looks good, I'll wait for positive testing from Anton before applying
>> this.
> 
> Thanks guys, this fixed it.
> 
> Tested-by: Anton Blanchard <anton@samba.org>

Thanks for testing Anton, I'll apply this now.
