From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] neigh: Force garbage collection if an entry is
 deleted administratively
Date: Thu, 14 Nov 2013 02:23:56 -0500 (EST)
Message-ID: <20131114.022356.1095983243221745109.davem@davemloft.net>
References: <20131112085714.GU31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab3KNHX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 02:23:58 -0500
In-Reply-To: <20131112085714.GU31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 12 Nov 2013 09:57:14 +0100

> Since git commit 2724680 ("neigh: Keep neighbour cache entries if number
> of them is small enough."), we keep all neighbour cache entries if the
> number is below a threshold. But if we now delete an entry administratively
> and then try to replace this by a permanent one, we get -EEXIST because the
> old entry ist still in the table (in NUD_FAILED state).
> 
> So lets force a garbage collect if we delete an entry administratively.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

I don't think this is a sufficient fix.

If some entity refers to this entry (refcnt != 1) then the forced
GC won't do anything, and this is very much possible.

It is the difficult situation mentioned in a comment in
neigh_flush_dev() below the "refcnt != 1" test there.
