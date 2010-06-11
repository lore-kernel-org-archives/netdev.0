From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ip: ip_ra_control() rcu fix
Date: Thu, 10 Jun 2010 22:48:55 -0700 (PDT)
Message-ID: <20100610.224855.212696344.davem@davemloft.net>
References: <20100607.212612.35795010.davem@davemloft.net>
	<1276136109.2475.9.camel@edumazet-laptop>
	<1276136467.2475.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52038
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751819Ab0FKFso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 01:48:44 -0400
In-Reply-To: <1276136467.2475.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Jun 2010 04:21:07 +0200

> [PATCH net-next-2.6 v2] ip: ip_ra_control() rcu fix
> 
> commit 66018506e15b (ip: Router Alert RCU conversion) introduced RCU
> lookups to ip_call_ra_chain(). It missed proper deinit phase :
> When ip_ra_control() deletes an ip_ra_chain, it should make sure
> ip_call_ra_chain() users can not start to use socket during the rcu
> grace period. It should also delay the sock_put() after the grace
> period, or we risk a premature socket freeing and corruptions, as
> raw sockets are not rcu protected yet.
> 
> This delay avoids using expensive atomic_inc_not_zero() in
> ip_call_ra_chain().
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
