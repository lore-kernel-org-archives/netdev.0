From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] drivers/s390/ - csum_partial - remove unnecessary casts
Date: Mon, 17 Nov 2008 09:55:12 -0800
Message-ID: <1226944512-13310-3-git-send-email-joe@perches.com>
References: <1226944512-13310-1-git-send-email-joe@perches.com>
Cc: David Miller <davem@davemloft.net>,
	Frank Blaschka <frank.blaschka@de.ibm.com>,
	Jeff Garzik <jeff@garzik.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:3349 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbYKQRzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 12:55:04 -0500
In-Reply-To: <1226944512-13310-1-git-send-email-joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    The first argument to csum_partial is const void *
    casts to char/u8 * are not necessary

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/s390/net/qeth_core_offl.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/s390/net/qeth_core_offl.c b/drivers/s390/net/qeth_core_offl.c
index 452874e..4080126 100644
--- a/drivers/s390/net/qeth_core_offl.c
+++ b/drivers/s390/net/qeth_core_offl.c
@@ -350,7 +350,7 @@ static __wsum qeth_eddp_check_tcp4_hdr(struct qeth_eddp_data *eddp,
 	phcsum = csum_tcpudp_nofold(eddp->nh.ip4.h.saddr, eddp->nh.ip4.h.daddr,
 				    eddp->thl + data_len, IPPROTO_TCP, 0);
 	/* compute checksum of tcp header */
-	return csum_partial((u8 *)&eddp->th, eddp->thl, phcsum);
+	return csum_partial(&eddp->th, eddp->thl, phcsum);
 }
 
 static __wsum qeth_eddp_check_tcp6_hdr(struct qeth_eddp_data *eddp,
@@ -362,12 +362,12 @@ static __wsum qeth_eddp_check_tcp6_hdr(struct qeth_eddp_data *eddp,
 	QETH_DBF_TEXT(TRACE, 5, "eddpckt6");
 	eddp->th.tcp.h.check = 0;
 	/* compute pseudo header checksum */
-	phcsum = csum_partial((u8 *)&eddp->nh.ip6.h.saddr,
+	phcsum = csum_partial(&eddp->nh.ip6.h.saddr,
 			      sizeof(struct in6_addr), 0);
-	phcsum = csum_partial((u8 *)&eddp->nh.ip6.h.daddr,
+	phcsum = csum_partial(&eddp->nh.ip6.h.daddr,
 			      sizeof(struct in6_addr), phcsum);
 	proto = htonl(IPPROTO_TCP);
-	phcsum = csum_partial((u8 *)&proto, sizeof(u32), phcsum);
+	phcsum = csum_partial(&proto, sizeof(u32), phcsum);
 	return phcsum;
 }
 
-- 
1.6.0.2

