From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] bridge: using for_each_set_bit_from to simplify the code
Date: Mon, 11 Mar 2013 23:43:48 +0800
Message-ID: <CAPgLHd_EW_y3VjSc9F4+fgmHpPVLZsysBo+sdDambZN96WBBcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: stephen@networkplumber.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:33830 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319Ab3CKPnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 11:43:50 -0400
Received: by mail-bk0-f41.google.com with SMTP id q16so1790158bkw.0
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 08:43:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using for_each_set_bit_from() to simplify the code.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/bridge/br_fdb.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b0812c9..48fe761 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -161,9 +161,7 @@ void br_fdb_change_mac_address(struct net_bridge *br, const u8 *newaddr)
 	if (!pv)
 		return;
 
-	for (vid = find_next_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN, vid);
-	     vid < BR_VLAN_BITMAP_LEN;
-	     vid = find_next_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN, vid+1)) {
+	for_each_set_bit_from(vid, pv->vlan_bitmap, BR_VLAN_BITMAP_LEN) {
 		f = __br_fdb_get(br, br->dev->dev_addr, vid);
 		if (f && f->is_local && !f->dst)
 			fdb_delete(br, f);
