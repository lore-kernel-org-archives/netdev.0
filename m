From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH] be2net: swap only first 2 fields of mcc_wrb
Date: Fri, 22 Jan 2010 14:21:36 +0530
Message-ID: <20100122085136.GA19742@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:39800 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751673Ab0AVIvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 03:51:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only the first two fields of mcc wrb - embedded, payload_len
need to be cpu_to_le32() swapped while issuing a cmd to the hw.
The fields tag0, tag1 are opaque and returned back to cpu as is...

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 102ade1..fee6eee 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -286,7 +286,7 @@ static void be_wrb_hdr_prepare(struct be_mcc_wrb *wrb, int payload_len,
 				MCC_WRB_SGE_CNT_SHIFT;
 	wrb->payload_length = payload_len;
 	wrb->tag0 = opcode;
-	be_dws_cpu_to_le(wrb, 20);
+	be_dws_cpu_to_le(wrb, 8);
 }
 
 /* Don't touch the hdr after it's prepared */
-- 
1.6.3.3

