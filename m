From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] neigh: Force garbage collection if an entry is
 deleted administratively
Date: Thu, 21 Nov 2013 14:18:13 -0500 (EST)
Message-ID: <20131121.141813.302653702167603709.davem@davemloft.net>
References: <20131119115414.GZ31491@secunet.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7432@saturn3.aculab.com>
	<20131119124102.GA31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44048 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011Ab3KUTSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 14:18:15 -0500
In-Reply-To: <20131119124102.GA31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 19 Nov 2013 13:41:02 +0100

> We have the table locked in neigh_periodic_work() so we can unlink
> invalidated entries there. This function could then periodically
> check and remove the unlinked entries if they lost their references.
> Unlinking with neigh_periodic_work() would have some seconds delay
> of course, but I think this is acceptable.

Create an "invalidated_list", and at the moment the neigh is
administratively deleted you can remove it from the hash table and
link it into this new list.

Then neigh_periodic_work() can scan both the hash tables and this
"invalidated_list" for refcnt==1 entries.

It seems a good solution, and should avoid the need to handle
forcibly freeing a neigh which still has external references.
