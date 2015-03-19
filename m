From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] ipv4,ipv6: grab rtnl before locking the socket
Date: Wed, 18 Mar 2015 22:05:25 -0400 (EDT)
Message-ID: <20150318.220525.1402514310956071469.davem@davemloft.net>
References: <9605dd2faf9e0aae8c3f6ce9f255760dd4856c91.1426700794.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbCSCF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 22:05:28 -0400
In-Reply-To: <9605dd2faf9e0aae8c3f6ce9f255760dd4856c91.1426700794.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Date: Wed, 18 Mar 2015 14:50:42 -0300

> There are some setsockopt operations in ipv4 and ipv6 that are grabbing
> rtnl after having grabbed the socket lock. Yet this makes it impossible
> to do operations that have to lock the socket when already within a rtnl
> protected scope, like ndo dev_open and dev_stop.
> 
> We normally take coarse grained locks first but setsockopt inverted that.
> 
> So this patch invert the lock logic for these operations and makes
> setsockopt grab rtnl if it will be needed prior to grabbing socket lock.
> 
> Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied to net-next.
