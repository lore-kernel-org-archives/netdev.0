From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 3/6] ebtables: remove unneeded initializations
Date: Fri, 30 Jan 2009 13:57:03 -0800
Message-ID: <20090130215729.290960679@vyatta.com>
References: <20090130215700.965611970@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49658 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756961AbZA3V6A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Jan 2009 16:58:00 -0500
Content-Disposition: inline; filename=ebtables-lock-init.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The initialization of the lock element is not needed
since the lock is always initialized in ebt_register_table.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 net/bridge/netfilter/ebtable_broute.c |    1 -
 net/bridge/netfilter/ebtable_filter.c |    1 -
 net/bridge/netfilter/ebtable_nat.c    |    1 -
 3 files changed, 3 deletions(-)

--- a/net/bridge/netfilter/ebtable_broute.c	2009-01-27 17:09:10.313100854 -0800
+++ b/net/bridge/netfilter/ebtable_broute.c	2009-01-27 17:09:15.862142852 -0800
@@ -46,7 +46,6 @@ static struct ebt_table broute_table =
 	.name		= "broute",
 	.table		= &initial_table,
 	.valid_hooks	= 1 << NF_BR_BROUTING,
-	.lock		= __RW_LOCK_UNLOCKED(broute_table.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
--- a/net/bridge/netfilter/ebtable_filter.c	2009-01-27 17:08:50.725100955 -0800
+++ b/net/bridge/netfilter/ebtable_filter.c	2009-01-27 17:08:53.828611768 -0800
@@ -55,7 +55,6 @@ static struct ebt_table frame_filter =
 	.name		= "filter",
 	.table		= &initial_table,
 	.valid_hooks	= FILTER_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_filter.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };
--- a/net/bridge/netfilter/ebtable_nat.c	2009-01-27 17:09:22.896602465 -0800
+++ b/net/bridge/netfilter/ebtable_nat.c	2009-01-27 17:09:31.589085328 -0800
@@ -55,7 +55,6 @@ static struct ebt_table frame_nat =
 	.name		= "nat",
 	.table		= &initial_table,
 	.valid_hooks	= NAT_VALID_HOOKS,
-	.lock		= __RW_LOCK_UNLOCKED(frame_nat.lock),
 	.check		= check,
 	.me		= THIS_MODULE,
 };

-- 

