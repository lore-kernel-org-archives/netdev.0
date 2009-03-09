From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 2/3] bnx2x: Casting page alignment
Date: Mon, 09 Mar 2009 12:52:17 +0200
Message-ID: <1236595937.11030.13.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Alex Chiang" <achiang@hp.com>,
	"Bjorn Helgaas" <bjorn.helgaas@hp.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1828 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753296AbZCIKxJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 06:53:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 2/3] bnx2x: Casting page alignment

Adding a proper cast to the argument of PAGE_ALIGN macro so that the output
won't depend on its original type. Without this cast aligned value will be
truncated to the size of the argument type.

Reported-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Tested-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 15a5cf0..3cf2b92 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -152,7 +152,7 @@ struct sw_rx_page {
 #define PAGES_PER_SGE			(1 << PAGES_PER_SGE_SHIFT)
 #define SGE_PAGE_SIZE			PAGE_SIZE
 #define SGE_PAGE_SHIFT			PAGE_SHIFT
-#define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN(addr)
+#define SGE_PAGE_ALIGN(addr)		PAGE_ALIGN((typeof(PAGE_SIZE))addr)

 #define BCM_RX_ETH_PAYLOAD_ALIGN	64

--
1.5.6.3




