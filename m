From: Steven Whitehouse <swhiteho@redhat.com>
Subject: [NET] Change "not found" return value for rule lookup
Date: Fri, 30 Mar 2007 10:13:55 +0100
Message-ID: <1175246035.1636.138.camel@quoit.chygwyn.com>
References: <1175185450.1636.124.camel@quoit.chygwyn.com>
	 <20070329.114306.112621613.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org, pcaulfie@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1945951AbXC3JHf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Mar 2007 05:07:35 -0400
In-Reply-To: <20070329.114306.112621613.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From 657baf6bbaa8302660d6b218149dcb5546b9b08c Mon Sep 17 00:00:00 2001
From: Steven Whitehouse <swhiteho@redhat.com>
Date: Fri, 30 Mar 2007 09:06:34 +0100
Subject: [PATCH] [NET] Change "not found" return value for rule lookup

This changes the "not found" error return for the lookup
function to -ESRCH so that it can be distinguished from
the case where a rule or route resulting in -ENETUNREACH
has been found during the search.

It fixes a bug where if DECnet was compiled with routing
support, but no routes were added to the routing table,
it was failing to fall back to endnode routing.

Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>
Signed-off-by: Patrick Caulfield <pcaulfie@redhat.com>

diff --git a/net/core/fib_rules.c b/net/core/fib_rules.c
index 06f304a..cb2dae1 100644
--- a/net/core/fib_rules.c
+++ b/net/core/fib_rules.c
@@ -164,7 +164,7 @@ jumped:
 		}
 	}
 
-	err = -ENETUNREACH;
+	err = -ESRCH;
 out:
 	rcu_read_unlock();
 
-- 
1.4.4.2



