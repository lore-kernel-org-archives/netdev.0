From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/8] nfp: switch to dev_alloc_page()
Date: Thu,  2 Nov 2017 01:31:34 -0700
Message-ID: <20171102083136.2096-7-jakub.kicinski@netronome.com>
References: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:56690 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755341AbdKBIc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:32:27 -0400
Received: by mail-pg0-f67.google.com with SMTP id m18so4425699pgd.13
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 01:32:27 -0700 (PDT)
In-Reply-To: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the dev_alloc_page() networking helper to allocate pages
for RX packets.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index eddf850a6a7f..7147335a8b36 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1212,7 +1212,7 @@ static void *nfp_net_napi_alloc_one(struct nfp_net_dp *dp, dma_addr_t *dma_addr)
 	} else {
 		struct page *page;
 
-		page = alloc_page(GFP_ATOMIC | __GFP_COLD);
+		page = dev_alloc_page();
 		frag = page ? page_address(page) : NULL;
 	}
 	if (!frag) {
-- 
2.14.1
