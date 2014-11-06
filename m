From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 09/14] openvswitch: Drop packets when interdev is not up
Date: Thu,  6 Nov 2014 01:19:32 -0800
Message-ID: <1415265572-1785-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Chunhe Li <lichunhe@huawei.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog118.obsmtp.com ([74.125.149.244]:40822 "HELO
	na3sys009aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752022AbaKFJTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:19:35 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so897240pad.7
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 01:19:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chunhe Li <lichunhe@huawei.com>

If the internal device is not up, it should drop received
packets. Sometimes it receive the broadcast or multicast
packets, and the ip protocol stack will casue more cpu
usage wasted.

Signed-off-by: Chunhe Li <lichunhe@huawei.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/vport-internal_dev.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 10dc07e..6a55f71 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -224,6 +224,11 @@ static int internal_dev_recv(struct vport *vport, struct sk_buff *skb)
 	struct net_device *netdev = netdev_vport_priv(vport)->dev;
 	int len;
 
+	if (unlikely(!(netdev->flags & IFF_UP))) {
+		kfree_skb(skb);
+		return 0;
+	}
+
 	len = skb->len;
 
 	skb_dst_drop(skb);
-- 
1.9.3
