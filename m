From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH] enic: enic_main: fix sparse warnings
Date: Thu,  5 Feb 2015 15:34:13 +0000
Message-ID: <1423150453-26417-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Neel Patel <neepatel@cisco.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>

this patch fixes following sparse warnings:

enic_main.c:92:28: warning: symbol 'mod_table' was not declared. Should it be static?
enic_main.c:109:28: warning: symbol 'mod_range' was not declared. Should it be static?
enic_main.c:1306:5: warning: symbol 'enic_busy_poll' was not declared. Should it be static?

Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>
---
 Found this issue on linux-next (gcc  version 4.8.2,
 sparse version  0.4.5-rc1)and applies on top linux-next.

 drivers/net/ethernet/cisco/enic/enic_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index ee44c82..9cbe038 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -89,7 +89,7 @@ MODULE_DEVICE_TABLE(pci, enic_id_table);
  *  coalescing timer values
  *  {rx_rate in Mbps, mapping percentage of the range}
  */
-struct enic_intr_mod_table mod_table[ENIC_MAX_COALESCE_TIMERS + 1] = {
+static struct enic_intr_mod_table mod_table[ENIC_MAX_COALESCE_TIMERS + 1] = {
 	{4000,  0},
 	{4400, 10},
 	{5060, 20},
@@ -106,7 +106,7 @@ struct enic_intr_mod_table mod_table[ENIC_MAX_COALESCE_TIMERS + 1] = {
 /* This table helps the driver to pick different ranges for rx coalescing
  * timer depending on the link speed.
  */
-struct enic_intr_mod_range mod_range[ENIC_MAX_LINK_SPEEDS] = {
+static struct enic_intr_mod_range mod_range[ENIC_MAX_LINK_SPEEDS] = {
 	{0,  0}, /* 0  - 4  Gbps */
 	{0,  3}, /* 4  - 10 Gbps */
 	{3,  6}, /* 10 - 40 Gbps */
@@ -1303,7 +1303,7 @@ static void enic_set_rx_cpu_rmap(struct enic *enic)
 #endif /* CONFIG_RFS_ACCEL */
 
 #ifdef CONFIG_NET_RX_BUSY_POLL
-int enic_busy_poll(struct napi_struct *napi)
+static int enic_busy_poll(struct napi_struct *napi)
 {
 	struct net_device *netdev = napi->dev;
 	struct enic *enic = netdev_priv(netdev);
-- 
1.9.1
