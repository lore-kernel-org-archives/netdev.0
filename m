From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 1/9] atm: convert to SKB paged frag API.
Date: Thu, 25 Aug 2011 09:28:07 +0100
Message-ID: <1314260895-15936-1-git-send-email-ian.campbell@citrix.com>
References: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37967 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752219Ab1HYI2T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Aug 2011 04:28:19 -0400
In-Reply-To: <1314260881.10283.48.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
Cc: netdev@vger.kernel.org

--
The original logic here appears to be bogus (adding page-offset to the struct
page * itself doesn't seem likely to be correct) but I left that unchanged for
this mechanical change.
---
 drivers/atm/eni.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/eni.c b/drivers/atm/eni.c
index 9307141..f7ca4c1 100644
--- a/drivers/atm/eni.c
+++ b/drivers/atm/eni.c
@@ -1134,7 +1134,8 @@ DPRINTK("doing direct send\n"); /* @@@ well, this doesn't work anyway */
 				    skb_headlen(skb));
 			else
 				put_dma(tx->index,eni_dev->dma,&j,(unsigned long)
-				    skb_shinfo(skb)->frags[i].page + skb_shinfo(skb)->frags[i].page_offset,
+				    skb_frag_page(&skb_shinfo(skb)->frags[i]) +
+					skb_shinfo(skb)->frags[i].page_offset,
 				    skb_shinfo(skb)->frags[i].size);
 	}
 	if (skb->len & 3)
-- 
1.7.2.5
