From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] vxlan: synchronously and race-free
 destruction of vxlan sockets
Date: Sat, 16 Apr 2016 18:23:47 -0400 (EDT)
Message-ID: <20160416.182347.1767582354651118863.davem@davemloft.net>
References: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jbenc@redhat.com,
	marcelo.leitner@gmail.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36072 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbcDPWXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 18:23:53 -0400
In-Reply-To: <1460148901-23740-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri,  8 Apr 2016 22:55:01 +0200

> Due to the fact that the udp socket is destructed asynchronously in a
> work queue, we have some nondeterministic behavior during shutdown of
> vxlan tunnels and creating new ones. Fix this by keeping the destruction
> process synchronous in regards to the user space process so IFF_UP can
> be reliably set.
> 
> udp_tunnel_sock_release destroys vs->sock->sk if reference counter
> indicates so. We expect to have the same lifetime of vxlan_sock and
> vxlan_sock->sock->sk even in fast paths with only rcu locks held. So
> only destruct the whole socket after we can be sure it cannot be found
> by searching vxlan_net->sock_list.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jiri Benc <jbenc@redhat.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
