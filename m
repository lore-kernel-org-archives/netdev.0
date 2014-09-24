From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH] vlan: Fix receive statistics under-reporting
Date: Wed, 24 Sep 2014 10:45:06 -0400
Message-ID: <1411569906-31679-1-git-send-email-vyasevic@redhat.com>
References: <20140922090134.3a114531@urahara>
Cc: stephen@networkplumber.org,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:65095 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbaIXOpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 10:45:17 -0400
Received: by mail-qc0-f176.google.com with SMTP id o8so3539952qcw.35
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 07:45:16 -0700 (PDT)
In-Reply-To: <20140922090134.3a114531@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlan devices uder-report 14 bytes per packet in the recieve statistics.
This is because the ETH_HLEN bytes of data has been pulled off the skb
by the time it gets to the vlan receive code.  When accounting for
receive butes, add ETH_HLEN back.

See also https://bugzilla.kernel.org/show_bug.cgi?id=84951

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/8021q/vlan_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 90cc2bd..8bc5d46 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -54,7 +54,7 @@ bool vlan_do_receive(struct sk_buff **skbp)
 
 	u64_stats_update_begin(&rx_stats->syncp);
 	rx_stats->rx_packets++;
-	rx_stats->rx_bytes += skb->len;
+	rx_stats->rx_bytes += skb->len + ETH_HLEN;
 	if (skb->pkt_type == PACKET_MULTICAST)
 		rx_stats->rx_multicast++;
 	u64_stats_update_end(&rx_stats->syncp);
-- 
1.9.3
