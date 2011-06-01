From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH] vlan: fix typo in vlan_dev_hard_start_xmit()
Date: Wed, 01 Jun 2011 16:53:19 +0800
Message-ID: <4DE5FDFF.4000208@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59816 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1162280Ab1FAIyF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 04:54:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4af429d29b341bb1735f04c2fb960178ed5d52e7 (vlan: lockless
transmit path) have a typo in vlan_dev_hard_start_xmit(), using
u64_stats_update_begin() to end the stat update, it should be
u64_stats_update_end().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/8021q/vlan_dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index f247f5b..7ea5cf9 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -165,7 +165,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 		u64_stats_update_begin(&stats->syncp);
 		stats->tx_packets++;
 		stats->tx_bytes += len;
-		u64_stats_update_begin(&stats->syncp);
+		u64_stats_update_end(&stats->syncp);
 	} else {
 		this_cpu_inc(vlan_dev_info(dev)->vlan_pcpu_stats->tx_dropped);
 	}
-- 
1.6.5.2


