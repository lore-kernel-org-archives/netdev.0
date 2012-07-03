From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/19] Disconnect neigh from dst_entry
Date: Tue, 03 Jul 2012 02:45:43 -0700 (PDT)
Message-ID: <20120703.024543.1597240990462633709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab2GCJpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 05:45:44 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 5074258411C
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2012 02:45:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This finally severs neighbour table entries from dst_entry enough that
we no longer depend upon them outside of the individual protocols.

Besides being a major step towards making routing cache removal
practical, it also means an end to the infamous "neighbour table
overflow" condition.

Routes in ipv4 no longer refer to neighbour table entries, they are
used on an as-needed basis during packet output in a refcount-less
manner.

Therefore garbage collection is trivial since almost nothing actually
holds onto neighbour table references.

On the routing cache removal side, this set of changes removes another
dependency upon rt->rt_dst.  The only one left is for inetpeer, and
once that is severed (I have a rough plan for it) rt->rt_dst is finally
without any use and we can construct ipv4 routes directly inside of
FIB table entries.

Signed-off-by: David S. Miller <davem@davemloft.net>
