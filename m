From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 8/9] bnx2fc: convert to SKB paged frag API.
Date: Thu, 25 Aug 2011 09:28:14 +0100
Message-ID: <1314260895-15936-8-git-send-email-ian.campbell@citrix.com>
References: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Bhanu Prakash Gollapudi <bprakash@broadcom.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	linux-scsi@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:38678 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752407Ab1HYI23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:28:29 -0400
In-Reply-To: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: linux-scsi@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/scsi/bnx2fc/bnx2fc_fcoe.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
index 7cb2cd4..2c780a7 100644
--- a/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
+++ b/drivers/scsi/bnx2fc/bnx2fc_fcoe.c
@@ -302,7 +302,7 @@ static int bnx2fc_xmit(struct fc_lport *lport, struct fc_frame *fp)
 			return -ENOMEM;
 		}
 		frag = &skb_shinfo(skb)->frags[skb_shinfo(skb)->nr_frags - 1];
-		cp = kmap_atomic(frag->page, KM_SKB_DATA_SOFTIRQ)
+		cp = kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ)
 				+ frag->page_offset;
 	} else {
 		cp = (struct fcoe_crc_eof *)skb_put(skb, tlen);
-- 
1.7.2.5
