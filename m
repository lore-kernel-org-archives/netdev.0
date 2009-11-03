From: Thiago Farina <tfransosi@gmail.com>
Subject: [PATCH]  trivial: remove duplicated MIN macro from tehuti.
Date: Tue,  3 Nov 2009 08:10:29 -0500
Message-ID: <1257253829-4531-1-git-send-email-tfransosi@gmail.com>
Cc: yanghy@cn.fujitsu.com, baum@tehutinetworks.net, andy@greyhouse.net,
	davem@davemloft.net, shemminger@vyatta.com,
	apkm@linux-fundation.org, ben@decadent.org.uk,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thiago Farina <tfransosi@gmail.com>
To: trivial@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753480AbZKCNKj@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the kernel api already has the macro "min",
just use it instead of declaring another one.

Signed-off-by: Thiago Farina <tfransosi@gmail.com>
---
 drivers/net/tehuti.c |    2 +-
 drivers/net/tehuti.h |    2 --
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index ec9dfb2..863084d 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1878,7 +1878,7 @@ static void bdx_tx_push_desc_safe(struct bdx_priv *priv, void *data, int size)
 			udelay(50);	/* give hw a chance to clean fifo */
 			continue;
 		}
-		avail = MIN(avail, size);
+		avail = min(avail, size);
 		DBG("about to push  %d bytes starting %p size %d\n", avail,
 		    data, size);
 		bdx_tx_push_desc(priv, data, avail);
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index 4fc875e..1241419 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -76,8 +76,6 @@
 #define FIFO_SIZE  4096
 #define FIFO_EXTRA_SPACE            1024
 
-#define MIN(x, y)  ((x) < (y) ? (x) : (y))
-
 #if BITS_PER_LONG == 64
 #    define H32_64(x)  (u32) ((u64)(x) >> 32)
 #    define L32_64(x)  (u32) ((u64)(x) & 0xffffffff)
-- 
1.6.5.1.61.ge79999
