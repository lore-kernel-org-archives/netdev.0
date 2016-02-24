From: David Decotigny <ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v9 11/16] net: rdma: use __ethtool_get_ksettings
Date: Wed, 24 Feb 2016 10:58:07 -0800
Message-ID: <1456340292-26003-12-git-send-email-ddecotig@gmail.com>
References: <1456340292-26003-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Ido Shamay <idos-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Govindarajulu Varadarajan <_govind-KK0ffGbhmjU@public.gmane.org>,
	Venkata Duvvuru <VenkatKumar.Duvvuru-iH1Dq9VlAzfQT0dZR+AlfA@public.gmane.org>,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Pravin B Shelar <pshelar-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>,
	Ed Swierk <eswierk-FilZDy9cOaHkQYj/0HfcvtBPR1lH4CV8@public.gmane.org>,
	Robert Love <robert.w.love-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	kan.liang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, vidya-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org,
	David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mips-6z/3iImG2C8G8FEW9MqTrA@public.gmane.org,
	fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1456340292-26003-1-git-send-email-ddecotig-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>

Signed-off-by: David Decotigny <decot-Ypc/8FJVVoBWk0Htik3J/w@public.gmane.org>
---
 include/rdma/ib_addr.h | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index c34c900..931a47b 100644
--- a/include/rdma/ib_addr.h
+++ b/include/rdma/ib_addr.h
@@ -262,24 +262,22 @@ static inline enum ib_mtu iboe_get_mtu(int mtu)
 
 static inline int iboe_get_rate(struct net_device *dev)
 {
-	struct ethtool_cmd cmd;
-	u32 speed;
+	struct ethtool_link_ksettings cmd;
 	int err;
 
 	rtnl_lock();
-	err = __ethtool_get_settings(dev, &cmd);
+	err = __ethtool_get_link_ksettings(dev, &cmd);
 	rtnl_unlock();
 	if (err)
 		return IB_RATE_PORT_CURRENT;
 
-	speed = ethtool_cmd_speed(&cmd);
-	if (speed >= 40000)
+	if (cmd.base.speed >= 40000)
 		return IB_RATE_40_GBPS;
-	else if (speed >= 30000)
+	else if (cmd.base.speed >= 30000)
 		return IB_RATE_30_GBPS;
-	else if (speed >= 20000)
+	else if (cmd.base.speed >= 20000)
 		return IB_RATE_20_GBPS;
-	else if (speed >= 10000)
+	else if (cmd.base.speed >= 10000)
 		return IB_RATE_10_GBPS;
 	else
 		return IB_RATE_PORT_CURRENT;
-- 
2.7.0.rc3.207.g0ac5344
