From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 11/11] net: flow: Remove FLOWI_FLAG_L3MDEV_SRC flag
Date: Sat, 10 Sep 2016 12:10:02 -0700
Message-ID: <1473534602-23602-12-git-send-email-dsa@cumulusnetworks.com>
References: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35133 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754012AbcIJTLf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Sep 2016 15:11:35 -0400
Received: by mail-pf0-f178.google.com with SMTP id w87so39661576pfk.2
        for <netdev@vger.kernel.org>; Sat, 10 Sep 2016 12:11:35 -0700 (PDT)
In-Reply-To: <1473534602-23602-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No longer used

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c  | 5 ++---
 include/net/flow.h | 3 +--
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index ccce59fbb2b3..55674b0e65b7 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -165,7 +165,7 @@ static netdev_tx_t vrf_process_v6_outbound(struct sk_buff *skb,
 		.flowlabel = ip6_flowinfo(iph),
 		.flowi6_mark = skb->mark,
 		.flowi6_proto = iph->nexthdr,
-		.flowi6_flags = FLOWI_FLAG_L3MDEV_SRC | FLOWI_FLAG_SKIP_NH_OIF,
+		.flowi6_flags = FLOWI_FLAG_SKIP_NH_OIF,
 	};
 	int ret = NET_XMIT_DROP;
 	struct dst_entry *dst;
@@ -265,8 +265,7 @@ static netdev_tx_t vrf_process_v4_outbound(struct sk_buff *skb,
 		.flowi4_oif = vrf_dev->ifindex,
 		.flowi4_iif = LOOPBACK_IFINDEX,
 		.flowi4_tos = RT_TOS(ip4h->tos),
-		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_L3MDEV_SRC |
-				FLOWI_FLAG_SKIP_NH_OIF,
+		.flowi4_flags = FLOWI_FLAG_ANYSRC | FLOWI_FLAG_SKIP_NH_OIF,
 		.daddr = ip4h->daddr,
 	};
 	struct net *net = dev_net(vrf_dev);
diff --git a/include/net/flow.h b/include/net/flow.h
index d47ef4bb5423..035aa7716967 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -34,8 +34,7 @@ struct flowi_common {
 	__u8	flowic_flags;
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
-#define FLOWI_FLAG_L3MDEV_SRC		0x04
-#define FLOWI_FLAG_SKIP_NH_OIF		0x08
+#define FLOWI_FLAG_SKIP_NH_OIF		0x04
 	__u32	flowic_secid;
 	struct flowi_tunnel flowic_tun_key;
 };
-- 
2.1.4
