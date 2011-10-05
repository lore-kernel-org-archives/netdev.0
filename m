From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 5/8] hv: netvsc: convert to SKB paged frag API.
Date: Wed, 5 Oct 2011 11:28:49 +0100
Message-ID: <1317810532-24984-5-git-send-email-ian.campbell@citrix.com>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Hank Janssen <hjanssen@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Abhishek Kane <v-abkane@microsoft.com>,
	devel@driverdev.osuosl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:34524 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934263Ab1JEK3C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 06:29:02 -0400
In-Reply-To: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Hank Janssen <hjanssen@microsoft.com>
Cc: Haiyang Zhang <haiyangz@microsoft.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: Abhishek Kane <v-abkane@microsoft.com>
Cc: devel@driverdev.osuosl.org
Cc: netdev@vger.kernel.org
---
 drivers/staging/hv/netvsc_drv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/hv/netvsc_drv.c b/drivers/staging/hv/netvsc_drv.c
index bfd4c81..58792ae 100644
--- a/drivers/staging/hv/netvsc_drv.c
+++ b/drivers/staging/hv/netvsc_drv.c
@@ -171,7 +171,7 @@ static int netvsc_start_xmit(struct sk_buff *skb, struct net_device *net)
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
 
-		packet->page_buf[i+2].pfn = page_to_pfn(f->page);
+		packet->page_buf[i+2].pfn = page_to_pfn(skb_frag_page(f));
 		packet->page_buf[i+2].offset = f->page_offset;
 		packet->page_buf[i+2].len = f->size;
 	}
-- 
1.7.2.5
