From: frank.blaschka@de.ibm.com
Subject: [patch 2/2] [PATCH] qeth: l3 hw tx csum circumvent hw bug
Date: Thu, 13 Jan 2011 07:42:25 +0100
Message-ID: <20110113064310.729751199@de.ibm.com>
References: <20110113064223.429450048@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:35855 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447Ab1AMGnP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jan 2011 01:43:15 -0500
Content-Disposition: inline; filename=602-qeth-l3-tx-csum.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Some OSA level have a bug in the hw tx csum logic. We can circumvent
this bug by turning on IP hw csum also.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2998,7 +2998,9 @@ static inline void qeth_l3_hdr_csum(stru
 	 */
 	if (iph->protocol == IPPROTO_UDP)
 		hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_UDP;
-	hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_CSUM_TRANSP_REQ;
+	hdr->hdr.l3.ext_flags |= QETH_HDR_EXT_CSUM_TRANSP_REQ |
+		QETH_HDR_EXT_CSUM_HDR_REQ;
+	iph->check = 0;
 	if (card->options.performance_stats)
 		card->perf_stats.tx_csum++;
 }

