From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH] atm: idt77105: fix fetch_stats() result
Date: Fri, 21 Jan 2011 12:43:07 +0300
Message-ID: <1295602987-11688-1-git-send-email-segoon@openwall.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

copy_to_user() used PRIV(dev)->stats instead of local stats variable.
Zero stats were returned to user in case of (zero != 0), also memcpy()
was pointless.

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 drivers/atm/idt77105.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/idt77105.c b/drivers/atm/idt77105.c
index bca9cb8..487a547 100644
--- a/drivers/atm/idt77105.c
+++ b/drivers/atm/idt77105.c
@@ -151,7 +151,7 @@ static int fetch_stats(struct atm_dev *dev,struct idt77105_stats __user *arg,int
 	spin_unlock_irqrestore(&idt77105_priv_lock, flags);
 	if (arg == NULL)
 		return 0;
-	return copy_to_user(arg, &PRIV(dev)->stats,
+	return copy_to_user(arg, &stats,
 		    sizeof(struct idt77105_stats)) ? -EFAULT : 0;
 }
 
-- 
1.7.0.4
