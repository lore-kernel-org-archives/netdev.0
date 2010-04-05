From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH] mac80211: Ensure initializing private mc_list in prepare_multicast().
Date: Mon, 5 Apr 2010 12:59:30 +0900
Message-ID: <201004050457.o354v6ec008492@94.43.138.210.xn.2iij.net>
Cc: jpirko@redhat.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:59830 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750732Ab0DEE53 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 00:57:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix kernel panic by NULL pointer dereference in the context of
ieee80211_ops->prepare_multicast().

This bug was introduced by commit 22bedad3c.. ("net: convert
multicast list to list_head").

Call __hw_addr_init() in ieee80211_alloc_hw() to initialize
list_head of private device multicast list, like we do in
bond_init().

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/mac80211/main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 84ad249..0b82cd2 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -388,6 +388,9 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 	local->uapsd_max_sp_len = IEEE80211_DEFAULT_MAX_SP_LEN;
 
 	INIT_LIST_HEAD(&local->interfaces);
+
+	__hw_addr_init(&local->mc_list);
+
 	mutex_init(&local->iflist_mtx);
 	mutex_init(&local->scan_mtx);
 
-- 
1.5.6.5

