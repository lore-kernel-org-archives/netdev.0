From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH v2] net/macb: fix sparse warning
Date: Thu,  5 Feb 2015 16:21:07 +0000
Message-ID: <1423153267-1768-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warning:

macb.c:2038:26: warning: symbol 'gem_ethtool_ops' was not declared. Should it be static?

Alongside drops exporting of gem_ethtool_ops as there is no need.

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.8.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/ethernet/cadence/macb.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 4f7bd13..ad76b8e 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2035,7 +2035,7 @@ const struct ethtool_ops macb_ethtool_ops = {
 };
 EXPORT_SYMBOL_GPL(macb_ethtool_ops);
 
-const struct ethtool_ops gem_ethtool_ops = {
+static const struct ethtool_ops gem_ethtool_ops = {
 	.get_settings		= macb_get_settings,
 	.set_settings		= macb_set_settings,
 	.get_regs_len		= macb_get_regs_len,
@@ -2046,7 +2046,6 @@ const struct ethtool_ops gem_ethtool_ops = {
 	.get_strings		= gem_get_ethtool_strings,
 	.get_sset_count		= gem_get_sset_count,
 };
-EXPORT_SYMBOL_GPL(gem_ethtool_ops);
 
 int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-- 
1.9.1
