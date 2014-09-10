From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: implement rt_genid_bump_ipv6 with
 fn_sernum and remove rt6i_genid
Date: Wed, 10 Sep 2014 13:09:29 -0700 (PDT)
Message-ID: <20140910.130929.247064282043941043.davem@davemloft.net>
References: <1410267519.27979.31.camel@localhost>
	<130f98f49b1b90a30908bfda8f01109c91edfe1c.1410341451.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	nicolas.dichtel@6wind.com
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752787AbaIJUJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 16:09:30 -0400
In-Reply-To: <130f98f49b1b90a30908bfda8f01109c91edfe1c.1410341451.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed, 10 Sep 2014 11:31:28 +0200

> In case we need to force the sockets to relookup the routes we now
> increase the fn_sernum on all fibnodes in the routing tree. This is a
> costly operation but should only happen if we have major routing/policy
> changes in the kernel (e.g. manual route adding/removal, xfrm policy
> changes).

Core routers can update thousands of route updates per second, and they
do this via what you refer to as "manual route adding/removal".

I don't think we want to put such a scalability problem into the tree.

There has to be a lightweight way to address this.
