From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/03: ip6tables regression fix
Date: Wed,  8 Apr 2009 18:52:17 +0200 (MEST)
Message-ID: <20090408165213.6702.77183.sendpatchset@x2.localnet>
References: <20090408165212.6702.44171.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54358 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbZDHQwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 12:52:18 -0400
In-Reply-To: <20090408165212.6702.44171.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 49a88d18a1721ac14dbc67cd390db18ee1f3a42f
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Mon Apr 6 17:06:55 2009 +0200

    netfilter: ip6tables regression fix
    
    Commit 7845447 (netfilter: iptables: lock free counters) broke
    ip6_tables by unconditionally returning ENOMEM in alloc_counters(),
    
    Reported-by: Graham Murray <graham@gmurray.org.uk>
    Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index dfed176..800ae85 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1033,6 +1033,8 @@ static struct xt_counters *alloc_counters(struct xt_table *table)
 
 	xt_free_table_info(info);
 
+	return counters;
+
  free_counters:
 	vfree(counters);
  nomem:
