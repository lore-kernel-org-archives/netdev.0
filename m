From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 09/14] openvswitch: Drop packets when interdev is not up
Date: Mon,  3 Nov 2014 22:01:46 -0800
Message-ID: <1415080906-1895-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Chunhe Li <lichunhe@huawei.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog018.obsmtp.com ([74.125.150.76]:42019 "HELO
	na6sys009bog018.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752091AbaKEUB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:01:59 -0500
Received: by mail-pa0-f53.google.com with SMTP id kx10so1400913pab.40
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:01:58 -0800 (PST)
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
