From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 3/9] net_sch: cbs: Change TC_SETUP_CBS to TC_SETUP_QDISC_CBS
Date: Mon, 30 Oct 2017 09:56:07 +0100
Message-ID: <20171030085613.8697-4-jiri@resnulli.us>
References: <20171030085613.8697-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com,
        ogerlitz@mellanox.com, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:53214 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752577AbdJ3I4S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 04:56:18 -0400
Received: by mail-wm0-f66.google.com with SMTP id t139so14755058wmt.1
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 01:56:18 -0700 (PDT)
In-Reply-To: <20171030085613.8697-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Change TC_SETUP_CBS to TC_SETUP_QDISC_CBS to match the new convention..

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 include/linux/netdevice.h                 | 2 +-
 net/sched/sch_cbs.c                       | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b3d730f..fe0c2f4 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2488,7 +2488,7 @@ static int igb_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	struct igb_adapter *adapter = netdev_priv(dev);
 
 	switch (type) {
-	case TC_SETUP_CBS:
+	case TC_SETUP_QDISC_CBS:
 		return igb_offload_cbs(adapter, type_data);
 
 	default:
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 732e2dc..ec58ef8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -776,7 +776,7 @@ enum tc_setup_type {
 	TC_SETUP_CLSMATCHALL,
 	TC_SETUP_CLSBPF,
 	TC_SETUP_BLOCK,
-	TC_SETUP_CBS,
+	TC_SETUP_QDISC_CBS,
 	TC_SETUP_QDISC_RED,
 };
 
diff --git a/net/sched/sch_cbs.c b/net/sched/sch_cbs.c
index bdb533b..7a72980 100644
--- a/net/sched/sch_cbs.c
+++ b/net/sched/sch_cbs.c
@@ -212,7 +212,7 @@ static void cbs_disable_offload(struct net_device *dev,
 	cbs.queue = q->queue;
 	cbs.enable = 0;
 
-	err = ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
+	err = ops->ndo_setup_tc(dev, TC_SETUP_QDISC_CBS, &cbs);
 	if (err < 0)
 		pr_warn("Couldn't disable CBS offload for queue %d\n",
 			cbs.queue);
@@ -236,7 +236,7 @@ static int cbs_enable_offload(struct net_device *dev, struct cbs_sched_data *q,
 	cbs.idleslope = opt->idleslope;
 	cbs.sendslope = opt->sendslope;
 
-	err = ops->ndo_setup_tc(dev, TC_SETUP_CBS, &cbs);
+	err = ops->ndo_setup_tc(dev, TC_SETUP_QDISC_CBS, &cbs);
 	if (err < 0)
 		return err;
 
-- 
2.9.5
