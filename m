From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 10/14] qeth: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:47:02 +0100
Message-ID: <1314787626-12273-10-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Ursula Braun <ursula.braun@de.ibm.com>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>,
	linux390@de.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-s390@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55267 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754414Ab1HaKrV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 06:47:21 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Ursula Braun <ursula.braun@de.ibm.com>
Cc: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Cc: linux390@de.ibm.com
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux-s390@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/s390/net/qeth_core_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 97172f8..8153443 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -3694,7 +3694,8 @@ static inline void __qeth_fill_buffer(struct sk_buff *skb,
 
 	for (cnt = 0; cnt < skb_shinfo(skb)->nr_frags; cnt++) {
 		frag = &skb_shinfo(skb)->frags[cnt];
-		buffer->element[element].addr = (char *)page_to_phys(frag->page)
+		buffer->element[element].addr = (char *)
+			page_to_phys(skb_frag_page(frag))
 			+ frag->page_offset;
 		buffer->element[element].length = frag->size;
 		buffer->element[element].eflags = SBAL_EFLAGS_MIDDLE_FRAG;
-- 
1.7.2.5
