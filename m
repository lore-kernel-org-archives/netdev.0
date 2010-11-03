From: kaber@trash.net
Subject: [PATCH 5/5] ipv4: netfilter: ip_tables: fix information leak to userland
Date: Wed,  3 Nov 2010 23:12:52 +0100
Message-ID: <1288822372-21245-6-git-send-email-kaber@trash.net>
References: <1288822372-21245-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58661 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750Ab0KCWNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 18:13:02 -0400
In-Reply-To: <1288822372-21245-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasiliy Kulikov <segooon@gmail.com>

Structure ipt_getinfo is copied to userland with the field "name"
that has the last elements unitialized.  It leads to leaking of
contents of kernel stack memory.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/ip_tables.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index d31b007..a846d63 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1124,6 +1124,7 @@ static int get_info(struct net *net, void __user *user,
 			private = &tmp;
 		}
 #endif
+		memset(&info, 0, sizeof(info));
 		info.valid_hooks = t->valid_hooks;
 		memcpy(info.hook_entry, private->hook_entry,
 		       sizeof(info.hook_entry));
-- 
1.7.1

