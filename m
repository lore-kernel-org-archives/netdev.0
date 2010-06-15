From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inetpeer: various changes
Date: Mon, 14 Jun 2010 23:13:31 -0700 (PDT)
Message-ID: <20100614.231331.112591806.davem@davemloft.net>
References: <1276580121.30434.322.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35917
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751946Ab0FOGNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 02:13:20 -0400
In-Reply-To: <1276580121.30434.322.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Jun 2010 07:35:21 +0200

> Try to reduce cache line contentions in peer management, to reduce IP
> defragmentation overhead.
> 
> - peer_fake_node is marked 'const' to make sure its not modified.
>   (tested with CONFIG_DEBUG_RODATA=y)
> 
> - Group variables in two structures to reduce number of dirtied cache
> lines. One named "peers" for avl tree root, its number of entries, and
> associated lock. (candidate for RCU conversion)
> 
> - A second one named "unused_peers" for unused list and its lock 
> 
> - Add a !list_empty() test in unlink_from_unused() to avoid taking lock
> when entry is not unused.
> 
> - Use atomic_dec_and_lock() in inet_putpeer() to avoid taking lock in
> some cases.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
