From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH] net: dsa/slave: Fix compilation warnings
Date: Mon, 29 Oct 2012 22:27:56 +0530
Message-ID: <5afab1ebe83e4361f1fd75bbea0c559af195bf02.1351529738.git.viresh.kumar@linaro.org>
Cc: linaro-dev@lists.linaro.org, patches@linaro.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Viresh Kumar <viresh.kumar@linaro.org>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently when none of CONFIG_NET_DSA_TAG_DSA, CONFIG_NET_DSA_TAG_EDSA and
CONFIG_NET_DSA_TAG_TRAILER is defined, we get following compilation warnings:

net/dsa/slave.c:51:12: warning: 'dsa_slave_init' defined but not used [-Wunused-function]
net/dsa/slave.c:60:12: warning: 'dsa_slave_open' defined but not used [-Wunused-function]
net/dsa/slave.c:98:12: warning: 'dsa_slave_close' defined but not used [-Wunused-function]
net/dsa/slave.c:116:13: warning: 'dsa_slave_change_rx_flags' defined but not used [-Wunused-function]
net/dsa/slave.c:127:13: warning: 'dsa_slave_set_rx_mode' defined but not used [-Wunused-function]
net/dsa/slave.c:136:12: warning: 'dsa_slave_set_mac_address' defined but not used [-Wunused-function]
net/dsa/slave.c:164:12: warning: 'dsa_slave_ioctl' defined but not used [-Wunused-function]

Fix them by enclosing these routines under #ifdef,endif.

Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
 net/dsa/slave.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index e32083d..5606fae 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -48,6 +48,8 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 
 
 /* slave device handling ****************************************************/
+#if defined(CONFIG_NET_DSA_TAG_DSA) || defined(CONFIG_NET_DSA_TAG_EDSA) || \
+		defined(CONFIG_NET_DSA_TAG_TRAILER)
 static int dsa_slave_init(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -170,6 +172,8 @@ static int dsa_slave_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 	return -EOPNOTSUPP;
 }
+#endif /* defined(CONFIG_NET_DSA_TAG_DSA) || defined(CONFIG_NET_DSA_TAG_EDSA ||
+		defined(CONFIG_NET_DSA_TAG_TRAILER) */
 
 
 /* ethtool operations *******************************************************/
-- 
1.7.12.rc2.18.g61b472e
