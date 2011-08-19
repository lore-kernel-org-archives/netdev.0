From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 06/75] atm: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:38 +0100
Message-ID: <1313760467-8598-6-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Chas Williams <chas@cmf.nrl.navy.mil>
Cc: linux-atm-general@lists.sourceforge.net
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
