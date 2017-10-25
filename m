From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/4] net: sched: remove ndo_setup_tc check from tc_can_offload
Date: Wed, 25 Oct 2017 16:35:00 +0200
Message-ID: <20171025143500.28973-5-jiri@resnulli.us>
References: <20171025143500.28973-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:53412 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932205AbdJYOfF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:35:05 -0400
Received: by mail-wm0-f66.google.com with SMTP id r196so2405271wmf.2
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:35:04 -0700 (PDT)
In-Reply-To: <20171025143500.28973-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since tc_can_offload is always called from block callback or egdev
callback, no need to check if ndo_setup_tc exists.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 0d24d22..4631f1a 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -609,11 +609,7 @@ struct tc_cls_u32_offload {
 
 static inline bool tc_can_offload(const struct net_device *dev)
 {
-	if (!(dev->features & NETIF_F_HW_TC))
-		return false;
-	if (!dev->netdev_ops->ndo_setup_tc)
-		return false;
-	return true;
+	return dev->features & NETIF_F_HW_TC;
 }
 
 static inline bool tc_skip_hw(u32 flags)
-- 
2.9.5
