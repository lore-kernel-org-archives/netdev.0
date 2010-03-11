From: Ajit Khaparde <ajitk@serverengines.com>
Subject: [PATCH net-2.6] be2net: fix mccq create for big endian
 architectures
Date: Thu, 11 Mar 2010 17:05:59 +0530
Message-ID: <20100311113548.GA12029@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:56829 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757553Ab0CKLgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 06:36:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The request to create an mccq was being dispatched without
doing a byte swap of num_pages. This byte swap is necessary
for Big Endian systems like PPC. Not having this fix leads
mccq create to fail on BE ASICs running newer version of
firmware, thereby causing driver initialization failure.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index c592153..50e6259 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -673,7 +673,7 @@ int be_cmd_mccq_create(struct be_adapter *adapter,
 	be_cmd_hdr_prepare(&req->hdr, CMD_SUBSYSTEM_COMMON,
 			OPCODE_COMMON_MCC_CREATE, sizeof(*req));
 
-	req->num_pages = PAGES_4K_SPANNED(q_mem->va, q_mem->size);
+	req->num_pages = cpu_to_le16(PAGES_4K_SPANNED(q_mem->va, q_mem->size));
 
 	AMAP_SET_BITS(struct amap_mcc_context, valid, ctxt, 1);
 	AMAP_SET_BITS(struct amap_mcc_context, ring_size, ctxt,
-- 
1.6.3.3

