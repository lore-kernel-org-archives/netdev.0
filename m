From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: fix Coverity scan errors
Date: Mon, 20 Mar 2017 19:04:48 -0700
Message-ID: <20170321020448.GA3829@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com, stephen@networkplumber.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0075.outbound.protection.outlook.com ([104.47.41.75]:2593
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754873AbdCUCVO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 22:21:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix Coverity scan errors by not dereferencing lio->glists_dma_base pointer
if it's NULL.

See http://marc.info/?l=linux-netdev&m=149002294305614&w=2

Reported-by: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: VSR Burru <veerasenareddy.burru@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 3 ++-
 drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 761061b..72b69bd 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -748,7 +748,8 @@ static void delete_glists(struct lio *lio)
 				kfree(g);
 		} while (g);
 
-		if (lio->glists_virt_base && lio->glists_virt_base[i]) {
+		if (lio->glists_virt_base && lio->glists_virt_base[i] &&
+		    lio->glists_dma_base && lio->glists_dma_base[i]) {
 			lio_dma_free(lio->oct_dev,
 				     lio->glist_entry_size * lio->tx_qsize,
 				     lio->glists_virt_base[i],
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
index 5ec5c24..8d9db23 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
@@ -506,7 +506,8 @@ static void delete_glists(struct lio *lio)
 				kfree(g);
 		} while (g);
 
-		if (lio->glists_virt_base && lio->glists_virt_base[i]) {
+		if (lio->glists_virt_base && lio->glists_virt_base[i] &&
+		    lio->glists_dma_base && lio->glists_dma_base[i]) {
 			lio_dma_free(lio->oct_dev,
 				     lio->glist_entry_size * lio->tx_qsize,
 				     lio->glists_virt_base[i],
