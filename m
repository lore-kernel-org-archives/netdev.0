From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/4] More work towards neigh-less dsts.
Date: Mon, 18 Jul 2011 01:24:53 -0700 (PDT)
Message-ID: <20110718.012453.560423538801097033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754524Ab1GRIY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:57 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6I8OrEp028177
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2011 01:24:56 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This continues the effort to divorce neighbour from dst_entry as
much as possible.

When we remove the routing cache, route entries will be fully generic
and not specific to any particular keyed destination.  Therefore we'll
need to lookup neigh entries dynamically, and quickly, at packet
output time.

To that end, this series:

1) Passes an explicit neighbour to packet out neigh_ops.

2) Abstracts all dst->neighbour behind helpers to ease the
   transition process.

3) Adds a new dst_ops entry, ->neigh_lookup(), to provide a transition
   scheme for dst->neighbour uses outside of the packet output path.

The next set of patches after this one will deal with all of
the dst_get_neighbour() code paths, converting them over to
dst_neigh_lookup()/neigh_release() sequences.

Then there will be a little bit of fiddling around in decnet since
it's usage of dst->neighbour is still too tight in the packet output
path.

Finally, we can kill dst->neighbour and do RCU neigh lookups in the
packet output paths for all the protocols using the neighbour cache
(ipv4, ipv6, decnet).
