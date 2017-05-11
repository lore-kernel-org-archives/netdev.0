From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] ethernet: aquantia: remove redundant checks on error status
Date: Thu, 11 May 2017 19:29:40 +0100
Message-ID: <20170511182940.18774-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Pavel Belous <pavel.belous@aquantia.com>,
        "David S . Miller" <davem@davemloft.net>,
        David VomLehn <vomlehn@texas.net>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The error status err is initialized as zero and then being checked
several times to see if it is less than zero even when it has not
been updated.  It may seem that the err should be assigned to the
return code of the call to the various *offload_en_set calls and
then we check for failure, however, these functions are void and
never actually return any status.  

Since these error checks are redundant we can remove these
as well as err and the error exit label err_exit.

Detected by CoverityScan, CID#1398313 and CID#1398306 ("Logically
dead code")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c | 13 +------------
 drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c | 12 +-----------
 2 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
index 4ee15ff06a44..faeb4935ef3e 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_a0.c
@@ -200,29 +200,18 @@ static int hw_atl_a0_hw_rss_set(struct aq_hw_s *self,
 static int hw_atl_a0_hw_offload_set(struct aq_hw_s *self,
 				    struct aq_nic_cfg_s *aq_nic_cfg)
 {
-	int err = 0;
-
 	/* TX checksums offloads*/
 	tpo_ipv4header_crc_offload_en_set(self, 1);
 	tpo_tcp_udp_crc_offload_en_set(self, 1);
-	if (err < 0)
-		goto err_exit;
 
 	/* RX checksums offloads*/
 	rpo_ipv4header_crc_offload_en_set(self, 1);
 	rpo_tcp_udp_crc_offload_en_set(self, 1);
-	if (err < 0)
-		goto err_exit;
 
 	/* LSO offloads*/
 	tdm_large_send_offload_en_set(self, 0xFFFFFFFFU);
-	if (err < 0)
-		goto err_exit;
-
-	err = aq_hw_err_from_flags(self);
 
-err_exit:
-	return err;
+	return aq_hw_err_from_flags(self);
 }
 
 static int hw_atl_a0_hw_init_tx_path(struct aq_hw_s *self)
diff --git a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
index 42150708191d..1bceb7358e5c 100644
--- a/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
+++ b/drivers/net/ethernet/aquantia/atlantic/hw_atl/hw_atl_b0.c
@@ -200,25 +200,18 @@ static int hw_atl_b0_hw_rss_set(struct aq_hw_s *self,
 static int hw_atl_b0_hw_offload_set(struct aq_hw_s *self,
 				    struct aq_nic_cfg_s *aq_nic_cfg)
 {
-	int err = 0;
 	unsigned int i;
 
 	/* TX checksums offloads*/
 	tpo_ipv4header_crc_offload_en_set(self, 1);
 	tpo_tcp_udp_crc_offload_en_set(self, 1);
-	if (err < 0)
-		goto err_exit;
 
 	/* RX checksums offloads*/
 	rpo_ipv4header_crc_offload_en_set(self, 1);
 	rpo_tcp_udp_crc_offload_en_set(self, 1);
-	if (err < 0)
-		goto err_exit;
 
 	/* LSO offloads*/
 	tdm_large_send_offload_en_set(self, 0xFFFFFFFFU);
-	if (err < 0)
-		goto err_exit;
 
 /* LRO offloads */
 	{
@@ -245,10 +238,7 @@ static int hw_atl_b0_hw_offload_set(struct aq_hw_s *self,
 
 		rpo_lro_en_set(self, aq_nic_cfg->is_lro ? 0xFFFFFFFFU : 0U);
 	}
-	err = aq_hw_err_from_flags(self);
-
-err_exit:
-	return err;
+	return aq_hw_err_from_flags(self);
 }
 
 static int hw_atl_b0_hw_init_tx_path(struct aq_hw_s *self)
-- 
2.11.0

