From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/15] net: sched: rename TC_SETUP_MATCHALL to TC_SETUP_CLSMATCHALL
Date: Sat,  5 Aug 2017 16:53:24 +0200
Message-ID: <20170805145337.17728-3-jiri@resnulli.us>
References: <20170805145337.17728-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36393 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751226AbdHEOxo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 10:53:44 -0400
Received: by mail-wm0-f66.google.com with SMTP id d40so8766604wma.3
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2017 07:53:43 -0700 (PDT)
In-Reply-To: <20170805145337.17728-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In order to be aligned with the rest of the types, rename
TC_SETUP_MATCHALL to TC_SETUP_CLSMATCHALL.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 include/linux/netdevice.h                      | 2 +-
 net/dsa/slave.c                                | 2 +-
 net/sched/cls_matchall.c                       | 4 ++--
 4 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1554242..6438c38 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1704,7 +1704,7 @@ static int mlxsw_sp_setup_tc(struct net_device *dev, enum tc_setup_type type,
 		return -EOPNOTSUPP;
 
 	switch (type) {
-	case TC_SETUP_MATCHALL:
+	case TC_SETUP_CLSMATCHALL:
 		switch (tc->cls_mall->command) {
 		case TC_CLSMATCHALL_REPLACE:
 			return mlxsw_sp_port_add_cls_matchall(mlxsw_sp_port,
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e4238e5..f8051a3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -778,7 +778,7 @@ enum tc_setup_type {
 	TC_SETUP_MQPRIO,
 	TC_SETUP_CLSU32,
 	TC_SETUP_CLSFLOWER,
-	TC_SETUP_MATCHALL,
+	TC_SETUP_CLSMATCHALL,
 	TC_SETUP_CLSBPF,
 };
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 2946fad..a02d22b 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -860,7 +860,7 @@ static int dsa_slave_setup_tc(struct net_device *dev, enum tc_setup_type type,
 		return -EOPNOTSUPP;
 
 	switch (type) {
-	case TC_SETUP_MATCHALL:
+	case TC_SETUP_CLSMATCHALL:
 		switch (tc->cls_mall->command) {
 		case TC_CLSMATCHALL_REPLACE:
 			return dsa_slave_add_cls_matchall(dev, protocol,
diff --git a/net/sched/cls_matchall.c b/net/sched/cls_matchall.c
index 6ffe0b8..a8853ad 100644
--- a/net/sched/cls_matchall.c
+++ b/net/sched/cls_matchall.c
@@ -63,7 +63,7 @@ static int mall_replace_hw_filter(struct tcf_proto *tp,
 	offload.cls_mall->exts = &head->exts;
 	offload.cls_mall->cookie = cookie;
 
-	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MATCHALL,
+	err = dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL,
 					    tp->q->handle, tp->chain->index,
 					    tp->protocol, &offload);
 	if (!err)
@@ -85,7 +85,7 @@ static void mall_destroy_hw_filter(struct tcf_proto *tp,
 	offload.cls_mall->exts = NULL;
 	offload.cls_mall->cookie = cookie;
 
-	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_MATCHALL, tp->q->handle,
+	dev->netdev_ops->ndo_setup_tc(dev, TC_SETUP_CLSMATCHALL, tp->q->handle,
 				      tp->chain->index, tp->protocol, &offload);
 }
 
-- 
2.9.3
