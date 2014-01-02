From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: fix the use of pcpu_tstats in sit
Date: Thu,  2 Jan 2014 08:49:36 +0800
Message-ID: <1388623776-1448-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:47175 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbaABAth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 19:49:37 -0500
Received: by mail-pa0-f42.google.com with SMTP id lj1so14035949pab.29
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 16:49:36 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id ik1sm97585480pbc.9.2014.01.01.16.49.33
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 01 Jan 2014 16:49:35 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

when read/write the 64bit data, the correct lock should be hold.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/sit.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 366fbba..1e33d77 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -702,8 +702,10 @@ static int ipip6_rcv(struct sk_buff *skb)
 		}
 
 		tstats = this_cpu_ptr(tunnel->dev->tstats);
+		u64_stats_update_begin(&tstats->syncp);
 		tstats->rx_packets++;
 		tstats->rx_bytes += skb->len;
+		u64_stats_update_end(&tstats->syncp);
 
 		netif_rx(skb);
 
-- 
1.7.10.4
