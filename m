From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Export nd_tbl to allow modules to
 support IPv6
Date: Wed, 05 Sep 2012 13:06:36 -0400 (EDT)
Message-ID: <20120905.130636.2295422323329670307.davem@davemloft.net>
References: <fd8b9a9ad300edfc378065ef7887c3debeeb5e89.1346843399.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789Ab2IERGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 13:06:38 -0400
In-Reply-To: <fd8b9a9ad300edfc378065ef7887c3debeeb5e89.1346843399.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Wed,  5 Sep 2012 13:14:08 +0200

> It does not make sense to export these functions if we don't
> export the table itself as well.

Yes it does make perfect sense.  It's exported for the sake of the
_implementation_ of a neighbour table in a kernel module.

I do not want to add more users with direct access to the neighbour
tables, because it is therefore impossible to go and add the inline
refcount'less lookups et al. to those external users.

So if one of our goals is to move towards a situation where all neigh
accesses are refcount'less, having those external users makes that
nearly impossible.

Instead, I'd rather see patches that mark arp_tbl as being exported
only for internal usage inside of the tree, so that we can reach that
goal.

I'm not applying this, sorry.
