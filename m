From: "Jan Beulich" <JBeulich@suse.com>
Subject: [PATCH] xen-netback: correct return value checks on
 xenbus_scanf()
Date: Thu, 07 Jul 2016 01:57:16 -0600
Message-ID: <577E277C02000078000FBEBB@prv-mh.provo.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>
To: "Wei Liu" <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prv-mh.provo.novell.com ([137.65.248.74]:44818 "EHLO
	prv-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756547AbcGGH5Q convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:3:1>);
	Thu, 7 Jul 2016 03:57:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only a positive return value indicates success.

Signed-off-by: Jan Beulich <jbeulich@suse.com>
---
 drivers/net/xen-netback/xenbus.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

--- 4.7-rc6-xenbus_scanf.orig/drivers/net/xen-netback/xenbus.c
+++ 4.7-rc6-xenbus_scanf/drivers/net/xen-netback/xenbus.c
@@ -741,7 +741,7 @@ static void xen_mcast_ctrl_changed(struc
 	int val;
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend,
-			 "request-multicast-control", "%d", &val) < 0)
+			 "request-multicast-control", "%d", &val) <= 0)
 		val = 0;
 	vif->multicast_control = !!val;
 }
@@ -890,7 +890,7 @@ static void connect(struct backend_info
 	err = xenbus_scanf(XBT_NIL, dev->otherend,
 			   "multi-queue-num-queues",
 			   "%u", &requested_num_queues);
-	if (err < 0) {
+	if (err <= 0) {
 		requested_num_queues = 1; /* Fall back to single queue */
 	} else if (requested_num_queues > xenvif_max_queues) {
 		/* buggy or malicious guest */
@@ -1056,7 +1056,7 @@ static int connect_data_rings(struct bac
 	if (err < 0) {
 		err = xenbus_scanf(XBT_NIL, xspath,
 				   "event-channel", "%u", &tx_evtchn);
-		if (err < 0) {
+		if (err <= 0) {
 			xenbus_dev_fatal(dev, err,
 					 "reading %s/event-channel(-tx/rx)",
 					 xspath);
@@ -1092,10 +1092,10 @@ static int read_xenbus_vif_flags(struct
 	err = xenbus_scanf(XBT_NIL, dev->otherend, "request-rx-copy", "%u",
 			   &rx_copy);
 	if (err == -ENOENT) {
-		err = 0;
+		err = 1;
 		rx_copy = 0;
 	}
-	if (err < 0) {
+	if (err <= 0) {
 		xenbus_dev_fatal(dev, err, "reading %s/request-rx-copy",
 				 dev->otherend);
 		return err;
@@ -1104,7 +1104,7 @@ static int read_xenbus_vif_flags(struct
 		return -EOPNOTSUPP;
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend,
-			 "feature-rx-notify", "%d", &val) < 0)
+			 "feature-rx-notify", "%d", &val) <= 0)
 		val = 0;
 	if (!val) {
 		/* - Reduce drain timeout to poll more frequently for
@@ -1116,7 +1116,7 @@ static int read_xenbus_vif_flags(struct
 	}
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-sg",
-			 "%d", &val) < 0)
+			 "%d", &val) <= 0)
 		val = 0;
 	vif->can_sg = !!val;
 
@@ -1124,25 +1124,25 @@ static int read_xenbus_vif_flags(struct
 	vif->gso_prefix_mask = 0;
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
-			 "%d", &val) < 0)
+			 "%d", &val) <= 0)
 		val = 0;
 	if (val)
 		vif->gso_mask |= GSO_BIT(TCPV4);
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4-prefix",
-			 "%d", &val) < 0)
+			 "%d", &val) <= 0)
 		val = 0;
 	if (val)
 		vif->gso_prefix_mask |= GSO_BIT(TCPV4);
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6",
-			 "%d", &val) < 0)
+			 "%d", &val) <= 0)
 		val = 0;
 	if (val)
 		vif->gso_mask |= GSO_BIT(TCPV6);
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6-prefix",
-			 "%d", &val) < 0)
+			 "%d", &val) <= 0)
 		val = 0;
 	if (val)
 		vif->gso_prefix_mask |= GSO_BIT(TCPV6);
@@ -1156,12 +1156,12 @@ static int read_xenbus_vif_flags(struct
 	}
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-no-csum-offload",
-			 "%d", &val) < 0)
+			 "%d", &val) <= 0)
 		val = 0;
 	vif->ip_csum = !val;
 
 	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-ipv6-csum-offload",
-			 "%d", &val) < 0)
+			 "%d", &val) <= 0)
 		val = 0;
 	vif->ipv6_csum = !!val;
 
