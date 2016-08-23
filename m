From: Luis Henriques <luis.henriques@canonical.com>
Subject: net: Zeroing the structure ethtool_wolinfo in ethtool_get_wol()
Date: Tue, 23 Aug 2016 14:41:08 +0100
Message-ID: <1471959668-18209-2-git-send-email-luis.henriques@canonical.com>
References: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Ben Hutchings <ben@decadent.org.uk>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Avijit Kanti Das <avijitnsec@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471959668-18209-1-git-send-email-luis.henriques@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Avijit Kanti Das <avijitnsec@codeaurora.org>

memset() the structure ethtool_wolinfo that has padded bytes
but the padded bytes have not been zeroed out.

Change-Id: If3fd2d872a1b1ab9521d937b86a29fc468a8bbfe
Signed-off-by: Avijit Kanti Das <avijitnsec@codeaurora.org>
---
 net/core/ethtool.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 977489820eb9..6bf6362e8114 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1435,11 +1435,13 @@ static int ethtool_reset(struct net_device *dev, char __user *useraddr)
 
 static int ethtool_get_wol(struct net_device *dev, char __user *useraddr)
 {
-	struct ethtool_wolinfo wol = { .cmd = ETHTOOL_GWOL };
+	struct ethtool_wolinfo wol;
 
 	if (!dev->ethtool_ops->get_wol)
 		return -EOPNOTSUPP;
 
+	memset(&wol, 0, sizeof(struct ethtool_wolinfo));
+	wol.cmd = ETHTOOL_GWOL;
 	dev->ethtool_ops->get_wol(dev, &wol);
 
 	if (copy_to_user(useraddr, &wol, sizeof(wol)))
