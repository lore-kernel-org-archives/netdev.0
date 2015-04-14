From: Honggang Li <honli@redhat.com>
Subject: [PATCH linux-next 2/4] ipvlan: fix possible NULL pointer dereference in ipvlan_get_iflink
Date: Tue, 14 Apr 2015 23:20:15 +0800
Message-ID: <1429024817-21561-3-git-send-email-honli@redhat.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429024817-21561-1-git-send-email-honli@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Honggang Li <honli@redhat.com>
---
 drivers/net/ipvlan/ipvlan_main.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 77b92a0..479fcf7 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -308,7 +308,10 @@ static int ipvlan_get_iflink(const struct net_device *dev)
 {
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 
-	return ipvlan->phy_dev->ifindex;
+	if (ipvlan && pvlan->phy_dev)
+		return ipvlan->phy_dev->ifindex;
+	else
+		return 0;
 }
 
 static const struct net_device_ops ipvlan_netdev_ops = {
-- 
1.8.3.1
