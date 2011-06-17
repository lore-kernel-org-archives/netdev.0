From: Pavel Shved <shved@ispras.ru>
Subject: [PATCH] farsync: add module_put to error path in fst_open()
Date: Fri, 17 Jun 2011 20:25:10 +0400
Message-ID: <1308327913-23220-1-git-send-email-shved@ispras.ru>
Cc: Pavel Shved <shved@ispras.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@ispras.ru
To: Kevin Curtis <kevin.curtis@farsite.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The fst_open() function, after a successful try_module_get() may return
an error code if hdlc_open() returns it.  However, it does not put the
module on this error path.

This patch adds the necessary module_put() call.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Pavel Shved <shved@ispras.ru>
---
 drivers/net/wan/farsync.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index e050bd6..777d1a4 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2203,8 +2203,10 @@ fst_open(struct net_device *dev)
 
 	if (port->mode != FST_RAW) {
 		err = hdlc_open(dev);
-		if (err)
+		if (err) {
+			module_put(THIS_MODULE);
 			return err;
+		}
 	}
 
 	fst_openport(port);
-- 
1.7.0.2
