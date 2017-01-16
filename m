From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net-next] bridge: sparse fixes in br_ip6_multicast_alloc_query()
Date: Mon, 16 Jan 2017 18:11:35 -0500
Message-ID: <1484608295-24250-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41818 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750996AbdAPXLg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 18:11:36 -0500
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3577361B83
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 23:11:37 +0000 (UTC)
Received: from thinkcentre.redhat.com (ovpn-116-133.rdu2.redhat.com [10.10.116.133])
        by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id v0GNBaKe000368
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 18:11:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changed type of csum field in struct igmpv3_query from __be16 to
__sum16 to eliminate type warning, made same change in struct
igmpv3_report for consistency.

Fixed up an ntohs() where htons() should have been used instead.

Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 include/uapi/linux/igmp.h | 4 ++--
 net/bridge/br_multicast.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/igmp.h b/include/uapi/linux/igmp.h
index ccbb32a..a97f9a7 100644
--- a/include/uapi/linux/igmp.h
+++ b/include/uapi/linux/igmp.h
@@ -53,7 +53,7 @@ struct igmpv3_grec {
 struct igmpv3_report {
 	__u8 type;
 	__u8 resv1;
-	__be16 csum;
+	__sum16 csum;
 	__be16 resv2;
 	__be16 ngrec;
 	struct igmpv3_grec grec[0];
@@ -62,7 +62,7 @@ struct igmpv3_report {
 struct igmpv3_query {
 	__u8 type;
 	__u8 code;
-	__be16 csum;
+	__sum16 csum;
 	__be32 group;
 #if defined(__LITTLE_ENDIAN_BITFIELD)
 	__u8 qrv:3,
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index b30e77e..f6634612 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -540,7 +540,7 @@ static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
 		break;
 	case 2:
 		mld2q = (struct mld2_query *)icmp6_hdr(skb);
-		mld2q->mld2q_mrc = ntohs((u16)jiffies_to_msecs(interval));
+		mld2q->mld2q_mrc = htons((u16)jiffies_to_msecs(interval));
 		mld2q->mld2q_type = ICMPV6_MGM_QUERY;
 		mld2q->mld2q_code = 0;
 		mld2q->mld2q_cksum = 0;
-- 
2.5.5
