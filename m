From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] net: bridge: export vlan flags with the stats
Date: Wed, 17 Aug 2016 12:53:10 +0200
Message-ID: <1471431190-27442-3-git-send-email-nikolay@cumulusnetworks.com>
References: <1471431190-27442-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35728 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839AbcHQKx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 06:53:29 -0400
Received: by mail-wm0-f45.google.com with SMTP id f65so189624271wmi.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 03:53:29 -0700 (PDT)
In-Reply-To: <1471431190-27442-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use one of the vlan xstats padding fields to export the vlan flags. This is
needed in order to be able to distinguish between master (bridge) and port
vlan entries in user-space when dumping the bridge vlan stats.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_bridge.h | 2 +-
 net/bridge/br_netlink.c        | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index c186f64fffca..ab92bca6d448 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -140,7 +140,7 @@ struct bridge_vlan_xstats {
 	__u64 tx_bytes;
 	__u64 tx_packets;
 	__u16 vid;
-	__u16 pad1;
+	__u16 flags;
 	__u32 pad2;
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 493ab9b3d51a..872d4c0deb59 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1321,6 +1321,7 @@ static int br_fill_linkxstats(struct sk_buff *skb,
 				continue;
 			memset(&vxi, 0, sizeof(vxi));
 			vxi.vid = v->vid;
+			vxi.flags = v->flags;
 			br_vlan_get_stats(v, &stats);
 			vxi.rx_bytes = stats.rx_bytes;
 			vxi.rx_packets = stats.rx_packets;
-- 
2.1.4
