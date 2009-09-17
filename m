From: Kusanagi Kouichi <slash@ma.neweb.ne.jp>
Subject: tun: Return -EINVAL if neither IFF_TUN nor IFF_TAP is set.
Date: Thu, 17 Sep 2009 16:36:13 +0900
Message-ID: <20090917073614.15217260031@msa105lp.auone-net.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752003AbZIQHy5@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After commit 2b980dbd77d229eb60588802162c9659726b11f4
("lsm: Add hooks to the TUN driver") tun_set_iff doesn't
return -EINVAL though neither IFF_TUN nor IFF_TAP is set.

Signed-off-by: Kusanagi Kouichi <slash@ma.neweb.ne.jp>
---
 drivers/net/tun.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 3f5d288..e091756 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -946,8 +946,6 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		char *name;
 		unsigned long flags = 0;
 
-		err = -EINVAL;
-
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 		err = security_tun_dev_create();
@@ -964,7 +962,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			flags |= TUN_TAP_DEV;
 			name = "tap%d";
 		} else
-			goto failed;
+			return -EINVAL;
 
 		if (*ifr->ifr_name)
 			name = ifr->ifr_name;
-- 
1.6.4.3
