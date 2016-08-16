From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: atm: remove redundant null pointer check on dev->name
Date: Tue, 16 Aug 2016 12:08:42 +0100
Message-ID: <1471345722-19203-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

dev->name is a char array of IFNAMSIZ elements, hence can never be
null, so the null pointer check is redundant. Remove it.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/atm/mpc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 0e98222..3b3b1a2 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -1007,7 +1007,7 @@ static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 	if (!net_eq(dev_net(dev), &init_net))
 		return NOTIFY_DONE;
 
-	if (dev->name == NULL || strncmp(dev->name, "lec", 3))
+	if (strncmp(dev->name, "lec", 3))
 		return NOTIFY_DONE; /* we are only interested in lec:s */
 
 	switch (event) {
-- 
2.8.1
