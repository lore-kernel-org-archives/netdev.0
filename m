From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC 06/12] rocker: Add helper to check ports belong to the same rocker switch
Date: Wed, 28 Sep 2016 14:42:56 +0200
Message-ID: <1475066582-1971-7-git-send-email-simon.horman@netronome.com>
References: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Cc: Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:33150 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932295AbcI1MnR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 08:43:17 -0400
Received: by mail-lf0-f42.google.com with SMTP id b71so50890721lfg.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 05:43:17 -0700 (PDT)
In-Reply-To: <1475066582-1971-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be used by a follow-up patch to add Add Open vSwitch (-like) flow
support to the OF-DPA rocker world.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/rocker/rocker.h      |  4 ++++
 drivers/net/ethernet/rocker/rocker_main.c | 15 +++++++++++++++
 2 files changed, 19 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 332adce701fa..4b4a7d2af774 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -85,6 +85,10 @@ int rocker_cmd_exec(struct rocker_port *rocker_port, bool nowait,
 int rocker_port_set_learning(struct rocker_port *rocker_port,
 			     bool learning);
 
+/* True if a and b are ports on the same rocker switch */
+bool rocker_port_dev_cmp_rocker(const struct net_device *a,
+				const struct net_device *b);
+
 struct rocker_world_ops {
 	const char *kind;
 	size_t priv_size;
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 6c6a486cced6..02101f88dc08 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2859,6 +2859,21 @@ static bool rocker_port_dev_check(const struct net_device *dev)
 	return dev->netdev_ops == &rocker_port_netdev_ops;
 }
 
+bool rocker_port_dev_cmp_rocker(const struct net_device *a,
+				const struct net_device *b)
+{
+	struct rocker_port *rocker_port_a, *rocker_port_b;
+
+	if (!rocker_port_dev_check(a) || !rocker_port_dev_check(b))
+		return false;
+
+
+	rocker_port_a = netdev_priv(a);
+	rocker_port_b = netdev_priv(b);
+
+	return rocker_port_a->rocker == rocker_port_b->rocker;
+}
+
 static int rocker_netdevice_event(struct notifier_block *unused,
 				  unsigned long event, void *ptr)
 {
-- 
2.7.0.rc3.207.g0ac5344
