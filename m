From: frank.blaschka@de.ibm.com
Subject: [patch 7/8] qeth: core code should alloc headroom for LLC protocol
Date: Tue, 01 Apr 2008 10:26:59 +0200
Message-ID: <20080401082745.152557000@de.ibm.com>
References: <20080401082652.754871000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:23441 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755544AbYDAI1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 04:27:47 -0400
Content-Disposition: inline; filename=07-qeth_headroom.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Allocate headroom for TR_HLEN but using only ETH_HLEN causes rx
performance degradation. Allocate ETH_HLEN for ethernet and
TR_HLEN for token ring (layer 3 mode).

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: git_davem-2.6.26/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_core_main.c	2008-03-31 13:21:07.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_core_main.c	2008-03-31 13:21:36.000000000 +0200
@@ -4002,7 +4002,11 @@
 		}
 	} else {
 		skb_len = (*hdr)->hdr.l3.length;
-		headroom = max((int)ETH_HLEN, (int)TR_HLEN);
+		if ((card->info.link_type == QETH_LINK_TYPE_LANE_TR) ||
+		    (card->info.link_type == QETH_LINK_TYPE_HSTR))
+			headroom = TR_HLEN;
+		else
+			headroom = ETH_HLEN;
 	}
 
 	if (!skb_len)

-- 
