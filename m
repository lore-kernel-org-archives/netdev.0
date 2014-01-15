From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [RFC PATCH net-next 2/3] virtio_net: Introduce one dummy function virtnet_filter_rfs()
Date: Wed, 15 Jan 2014 22:20:53 +0800
Message-ID: <1389795654-28381-3-git-send-email-zwu.kernel@gmail.com>
References: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
Cc: therbert@google.com, edumazet@google.com, davem@davemloft.net,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:40852 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054AbaAOOVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 09:21:15 -0500
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <zwu.kernel@gmail.com>;
	Wed, 15 Jan 2014 07:21:15 -0700
Received: from b03cxnp07029.gho.boulder.ibm.com (b03cxnp07029.gho.boulder.ibm.com [9.17.130.16])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 850F83E4005B
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 07:21:12 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by b03cxnp07029.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s0FCInqw10355094
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 13:18:49 +0100
Received: from d03av02.boulder.ibm.com (localhost [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s0FELBp4012022
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 07:21:12 -0700
In-Reply-To: <1389795654-28381-1-git-send-email-zwu.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/virtio_net.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 7b17240..046421c 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -1295,6 +1295,14 @@ static int virtnet_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+#ifdef CONFIG_RFS_ACCEL
+static int virtnet_filter_rfs(struct net_device *net_dev,
+		const struct sk_buff *skb, u16 rxq_index, u32 flow_id)
+{
+	return 0;
+}
+#endif /* CONFIG_RFS_ACCEL */
+
 static const struct net_device_ops virtnet_netdev = {
 	.ndo_open            = virtnet_open,
 	.ndo_stop   	     = virtnet_close,
@@ -1309,6 +1317,9 @@ static const struct net_device_ops virtnet_netdev = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = virtnet_netpoll,
 #endif
+#ifdef CONFIG_RFS_ACCEL
+	.ndo_rx_flow_steer   = virtnet_filter_rfs,
+#endif
 };
 
 static void virtnet_config_changed_work(struct work_struct *work)
-- 
1.7.6.5
