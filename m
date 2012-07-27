From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 4/7] bridge: call NETDEV_RELEASE notifier in br_del_if()
Date: Fri, 27 Jul 2012 23:38:01 +0800
Message-ID: <1343403484-29347-5-git-send-email-amwang@redhat.com>
References: <1343403484-29347-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343403484-29347-1-git-send-email-amwang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a bridge interface deletes its underlying ports, it should
notify netconsole too, like what bonding interface does.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 net/bridge/br_if.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index e1144e1..d243914 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -427,6 +427,7 @@ int br_del_if(struct net_bridge *br, struct net_device *dev)
 	if (!p || p->br != br)
 		return -EINVAL;
 
+	call_netdevice_notifiers(NETDEV_RELEASE, br->dev);
 	del_nbp(p);
 
 	spin_lock_bh(&br->lock);
-- 
1.7.7.6
