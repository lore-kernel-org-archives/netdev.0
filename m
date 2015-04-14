From: Honggang Li <honli@redhat.com>
Subject: [PATCH linux-next 4/4] net/dsa: fix possible NULL pointer dereference in dsa_slave_get_iflink
Date: Tue, 14 Apr 2015 23:20:17 +0800
Message-ID: <1429024817-21561-5-git-send-email-honli@redhat.com>
References: <1429024817-21561-1-git-send-email-honli@redhat.com>
Cc: Honggang Li <honli@redhat.com>
To: roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	kaber@trash.net, davem@davemloft.net, alex.estrin@intel.com,
	dledford@redhat.com, edumazet@google.com, erezsh@mellanox.com,
	nicolas.dichtel@6wind.com, maheshb@google.com, jbenc@redhat.com,
	ebiederm@xmission.com, elfring@users.sourceforge.net,
	f.fainelli@gmail.com, linux@roeck-us.net, andrew@lunn.ch,
	sfeldma@gmail.com, alexander.h.duyck@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831AbbDNPWA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 11:22:00 -0400
In-Reply-To: <1429024817-21561-1-git-send-email-honli@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Honggang Li <honli@redhat.com>
---
 net/dsa/slave.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 827cda56..070b599 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -59,7 +59,10 @@ static int dsa_slave_get_iflink(const struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 
-	return p->parent->dst->master_netdev->ifindex;
+	if (p && p->parent && p->parent->dst && p->parent->dst->master_netdev)
+		return p->parent->dst->master_netdev->ifindex;
+	else
+		return 0;
 }
 
 static inline bool dsa_port_is_bridged(struct dsa_slave_priv *p)
-- 
1.8.3.1
