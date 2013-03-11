From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] bridge: using for_each_set_bit to simplify the code
Date: Mon, 11 Mar 2013 23:45:23 +0800
Message-ID: <CAPgLHd_viA9nTBMRhhE-XJzYHu8a7f5Xjve9hYpU-RaY=uE9+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: stephen@networkplumber.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:33474 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751612Ab3CKPpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 11:45:24 -0400
Received: by mail-bk0-f48.google.com with SMTP id jf20so1737772bkc.7
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 08:45:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Using for_each_set_bit() to simplify the code.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/bridge/br_netlink.c | 5 +----
 net/bridge/br_fdb.c     | 10 ++--------
 2 files changed, 3 insertions(+), 12 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 27aa3ee..2135afa 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -135,10 +135,7 @@ static int br_fill_ifinfo(struct sk_buff *skb,
 			goto nla_put_failure;
 
 		pvid = br_get_pvid(pv);
-		for (vid = find_first_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN);
-		     vid < BR_VLAN_BITMAP_LEN;
-		     vid = find_next_bit(pv->vlan_bitmap,
-					 BR_VLAN_BITMAP_LEN, vid+1)) {
+		for_each_set_bit(vid, pv->vlan_bitmap, BR_VLAN_BITMAP_LEN) {
 			vinfo.vid = vid;
 			vinfo.flags = 0;
 			if (vid == pvid)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index b0812c9..4f68df1 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -724,13 +724,10 @@ int br_fdb_add(struct ndmsg *ndm, struct nlattr *tb[],
 		 * specify a VLAN.  To be nice, add/update entry for every
 		 * vlan on this port.
 		 */
-		vid = find_first_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN);
-		while (vid < BR_VLAN_BITMAP_LEN) {
+		for_each_set_bit(vid, pv->vlan_bitmap, BR_VLAN_BITMAP_LEN) {
 			err = __br_fdb_add(ndm, p, addr, nlh_flags, vid);
 			if (err)
 				goto out;
-			vid = find_next_bit(pv->vlan_bitmap,
-					    BR_VLAN_BITMAP_LEN, vid+1);
 		}
 	}
 
@@ -815,11 +812,8 @@ int br_fdb_delete(struct ndmsg *ndm, struct nlattr *tb[],
 		 * vlan on this port.
 		 */
 		err = -ENOENT;
-		vid = find_first_bit(pv->vlan_bitmap, BR_VLAN_BITMAP_LEN);
-		while (vid < BR_VLAN_BITMAP_LEN) {
+		for_each_set_bit(vid, pv->vlan_bitmap, BR_VLAN_BITMAP_LEN) {
 			err &= __br_fdb_delete(p, addr, vid);
-			vid = find_next_bit(pv->vlan_bitmap,
-					    BR_VLAN_BITMAP_LEN, vid+1);
 		}
 	}
 out:
