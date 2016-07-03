From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 10/10] liquidio: Response header changes
Date: Sun, 3 Jul 2016 13:56:56 -0700
Message-ID: <1467579416-24219-11-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0041.outbound.protection.outlook.com ([104.47.32.41]:12331
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932236AbcGCVar (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jul 2016 17:30:47 -0400
In-Reply-To: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes response header to be able to communicate
with new firmware interface.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 603d205..199a8b9 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -542,6 +542,7 @@ union octeon_rh {
 		u64 csum_verified:3;     /** checksum verified. */
 		u64 has_hwtstamp:1;      /** Has hardware timestamp. 1 = yes. */
 		u64 encap_on:1;
+		u64 has_hash:1;          /** Has hash (rth or rss). 1 = yes. */
 	} r_dh;
 	struct {
 		u64 opcode:4;
@@ -551,7 +552,8 @@ union octeon_rh {
 		u64 num_gmx_ports:8;
 		u64 max_nic_ports:10;
 		u64 app_cap_flags:4;
-		u64 app_mode:16;
+		u64 app_mode:8;
+		u64 pkind:8;
 	} r_core_drv_init;
 	struct {
 		u64 opcode:4;
@@ -571,6 +573,7 @@ union octeon_rh {
 		u64 opcode:4;
 	} r;
 	struct {
+		u64 has_hash:1;          /** Has hash (rth or rss). 1 = yes. */
 		u64 encap_on:1;
 		u64 has_hwtstamp:1;      /** 1 = has hwtstamp */
 		u64 csum_verified:3;     /** checksum verified. */
@@ -582,7 +585,8 @@ union octeon_rh {
 		u64 opcode:4;
 	} r_dh;
 	struct {
-		u64 app_mode:16;
+		u64 pkind:8;
+		u64 app_mode:8;
 		u64 app_cap_flags:4;
 		u64 max_nic_ports:10;
 		u64 num_gmx_ports:8;
@@ -640,9 +644,11 @@ union oct_link_status {
 		u64 autoneg:1;
 		u64 if_mode:5;
 		u64 pause:1;
-		u64 reserved:16;
+		u64 flashing:1;
+		u64 reserved:15;
 #else
-		u64 reserved:16;
+		u64 reserved:15;
+		u64 flashing:1;
 		u64 pause:1;
 		u64 if_mode:5;
 		u64 autoneg:1;
@@ -869,9 +875,9 @@ union oct_nic_if_cfg {
 		u64 num_iqueues:16;
 		u64 num_oqueues:16;
 		u64 gmx_port_id:8;
-		u64 reserved:8;
+		u64 vf_id:8;
 #else
-		u64 reserved:8;
+		u64 vf_id:8;
 		u64 gmx_port_id:8;
 		u64 num_oqueues:16;
 		u64 num_iqueues:16;
-- 
1.8.3.1
