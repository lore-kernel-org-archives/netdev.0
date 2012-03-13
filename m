From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Provide SYN packet for passive connections
Date: Mon, 12 Mar 2012 22:56:00 -0700 (PDT)
Message-ID: <20120312.225600.124181041257683930.davem@davemloft.net>
References: <CA+mtBx_LqwUpe5Df3VPw-L=h-WUjr=fxh86rgNuYnMacNikuOA@mail.gmail.com>
	<20120311.211424.996831768685832926.davem@davemloft.net>
	<1331611319.7787.37.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55926 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759674Ab2CMF4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Mar 2012 01:56:03 -0400
In-Reply-To: <1331611319.7787.37.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 12 Mar 2012 21:01:59 -0700

> [PATCH net-next] inet: embed icsk_accept_queue in an union
> 
> icsk_accept_queue is currently used only for LISTEN sockets. We could
> share its space with fields used for other kind of inet sockets.
> 
> For active connections, this area is zeroed in socket setup, and for
> passive ones, we clear the whole area in inet_csk_clone_lock() to make
> sure we dont use content inherited from (listener) parent.
> 
> /* Deinitialize accept_queue to trap illegal accesses. */
> memset(&newicsk->icsk_accept_queue, 0, sizeof(newicsk->icsk_accept_queue));
> 
> For 100% safety, we could do the same in inet_csk_listen_stop(), or we can
> double check that fields added in this union later are only accessed by non
> LISTEN sockets.
> 
> All these fields must have a null default value.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Suggested-by: Tom Herbert <therbert@google.com>

We can put this in when something that makes use of the new union
is added.
