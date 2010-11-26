From: frank.blaschka@de.ibm.com
Subject: [patch 4/4] [PATCH] qeth: l3 fix len in tso hdr
Date: Fri, 26 Nov 2010 13:41:20 +0100
Message-ID: <20101126124154.416738888@de.ibm.com>
References: <20101126124116.123736494@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:35532 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851Ab0KZMmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 07:42:31 -0500
Content-Disposition: inline; filename=qeth_tso_hdr.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

The tso hdr is longer then the regular l3 hdr. Fix the calculation
of the total len by accounting the size of the tso hdr.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |    1 +
 1 file changed, 1 insertion(+)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2939,6 +2939,7 @@ static void qeth_tso_fill_header(struct
 
 	/*fix header to TSO values ...*/
 	hdr->hdr.hdr.l3.id = QETH_HEADER_TYPE_TSO;
+	hdr->hdr.hdr.l3.length = skb->len - sizeof(struct qeth_hdr_tso);
 	/*set values which are fix for the first approach ...*/
 	hdr->ext.hdr_tot_len = (__u16) sizeof(struct qeth_hdr_ext_tso);
 	hdr->ext.imb_hdr_no  = 1;

