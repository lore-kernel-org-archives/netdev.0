From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Export nd_tbl to allow modules to
 support IPv6
Date: Thu, 06 Sep 2012 13:47:38 -0400 (EDT)
Message-ID: <20120906.134738.425625608685741613.davem@davemloft.net>
References: <fd8b9a9ad300edfc378065ef7887c3debeeb5e89.1346843399.git.tgraf@suug.ch>
	<20120905.130636.2295422323329670307.davem@davemloft.net>
	<20120906085102.GA14711@canuck.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759372Ab2IFRrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 13:47:40 -0400
In-Reply-To: <20120906085102.GA14711@canuck.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 6 Sep 2012 04:51:02 -0400

> On Wed, Sep 05, 2012 at 01:06:36PM -0400, David Miller wrote:
>> So if one of our goals is to move towards a situation where all neigh
>> accesses are refcount'less, having those external users makes that
>> nearly impossible.
>> 
>> Instead, I'd rather see patches that mark arp_tbl as being exported
>> only for internal usage inside of the tree, so that we can reach that
>> goal.
>> 
>> I'm not applying this, sorry.
> 
> Fair enough
> 
> Does that mean you dismiss neighbour lookups by external users in
> general in order to get rid of the refcnt?
> 
> Assuming that lookups would still be ok, would an ipv6 version of
> __ipv4_neigh_lookup() be an acceptable API for external users?
> (Yes there is __ipv6_neigh_lookup() already but unlike the ipv4 version
> it takes the table as first argument)

Right now we're in a transition period where ipv4 is mostly refcount'less
and ipv6 is not.

This is part of the reason I don't want to expose these things, the
calling convention and locking requirements are going to be fluid for
any interface you might propose.

arp_tbl was exported only for in-tree users, and I therefore say that
we should only export nd_tbl for in-tree users as well, since that's
the only way we can audit and update all the referencing callers as
the semantics radically change.
