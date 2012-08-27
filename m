From: Wanlong Gao <gaowanlong@cn.fujitsu.com>
Subject: [PATCH 2/5] net:atm:fix up ENOIOCTLCMD error handling
Date: Mon, 27 Aug 2012 15:23:13 +0800
Message-ID: <1346052196-32682-3-git-send-email-gaowanlong@cn.fujitsu.com>
References: <1346052196-32682-1-git-send-email-gaowanlong@cn.fujitsu.com>
Cc: Wanlong Gao <gaowanlong@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1346052196-32682-1-git-send-email-gaowanlong@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At commit 07d106d0, Linus pointed out that ENOIOCTLCMD should be
translated as ENOTTY to user mode.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Wanlong Gao <gaowanlong@cn.fujitsu.com>
---
 net/atm/resources.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/atm/resources.c b/net/atm/resources.c
index 23f45ce..0447d5d 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -432,7 +432,7 @@ int atm_dev_ioctl(unsigned int cmd, void __user *arg, int compat)
 			size = dev->ops->ioctl(dev, cmd, buf);
 		}
 		if (size < 0) {
-			error = (size == -ENOIOCTLCMD ? -EINVAL : size);
+			error = (size == -ENOIOCTLCMD ? -ENOTTY : size);
 			goto done;
 		}
 	}
-- 
1.7.12
