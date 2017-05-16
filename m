From: Anoob Soman <anoob.soman@citrix.com>
Subject: [PATCH 4.4-only] openvswitch: clear sender cpu before forwarding packets
Date: Tue, 16 May 2017 15:25:10 +0100
Message-ID: <1494944710-7901-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <pshelar@nicira.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <dev@openvswitch.org>,
        <linux-kernel@vger.kernel.org>,
        Anoob Soman <anoob.soman@citrix.com>
To: <stable@vger.kernel.org>
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similar to commit c29390c6dfee ("xps: must clear sender_cpu before
forwarding") the skb->sender_cpu needs to be cleared before forwarding
packets.

Fixes: 2bd82484bb4c ("xps: fix xps for stacked devices")
Signed-off-by: Anoob Soman <anoob.soman@citrix.com>
---
 net/openvswitch/vport.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 31cbc8c..a4887e7 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -503,6 +503,7 @@ void ovs_vport_send(struct vport *vport, struct sk_buff *skb)
 	}
 
 	skb->dev = vport->dev;
+	skb_sender_cpu_clear(skb);
 	vport->ops->send(skb);
 	return;
 
-- 
1.8.3.1
