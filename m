From: Tom Herbert <therbert@google.com>
Subject: [PATCH] bridge: Fix redefined references
Date: Mon, 29 Sep 2014 19:16:44 -0700
Message-ID: <1412043404-27494-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, pablo@netfilter.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:44961 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755200AbaI3CRC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 22:17:02 -0400
Received: by mail-pd0-f169.google.com with SMTP id p10so6369988pdj.0
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 19:17:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 34666d467cbf1e2e3 ("netfilter: bridge: move br_netfilter out of
the core") cause compiler errors when CONFIG_BRIDGE_NETFILTER is not
defined.

net/bridge/br_nf_core.c:77:1: error: expected identifier or '(' before '{' token
net/bridge/br_nf_core.c:88:115: error: redefinition of 'br_nf_core_init'
In file included from net/bridge/br_nf_core.c:23:0:
net/bridge/br_private.h:762:59: note: previous definition of 'br_nf_core_init' was here
net/bridge/br_nf_core.c:93:6: error: redefinition of 'br_nf_core_fini'
In file included from net/bridge/br_nf_core.c:23:0:
net/bridge/br_private.h:763:60: note: previous definition of 'br_nf_core_fini' was here

Add #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER) around definitions of
the redefined functions.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/bridge/br_nf_core.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_nf_core.c b/net/bridge/br_nf_core.c
index 387cb3b..ac4bea1 100644
--- a/net/bridge/br_nf_core.c
+++ b/net/bridge/br_nf_core.c
@@ -73,6 +73,7 @@ static const u32 br_dst_default_metrics[RTAX_MAX] = {
 	[RTAX_MTU - 1] = 1500,
 };
 
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 void br_netfilter_rtable_init(struct net_bridge *br)
 {
 	struct rtable *rt = &br->fake_rtable;
@@ -94,3 +95,4 @@ void br_nf_core_fini(void)
 {
 	dst_entries_destroy(&fake_dst_ops);
 }
+#endif
-- 
2.1.0.rc2.206.gedb03e5
