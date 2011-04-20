From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v5 5/5] sctp: Add ADD/DEL ASCONF handling at the receiver
Date: Thu, 21 Apr 2011 05:42:22 +0900
Message-ID: <8F7C47DA-A0A2-48BE-84A7-1D073B5617AE@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:42201 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753160Ab1DTUmZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 16:42:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the problem that the original code cannot delete the remote address where the corresponding transport is currently directed, even when the ASCONF is sent from the other address (this situation happens when the single-homed sender transmits  ASCONF with ADD and DEL.)  

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
---
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index de98665..a9f25d7 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2990,7 +2990,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		 * an Error Cause TLV set to the new error code 'Request to
 		 * Delete Source IP Address'
 		 */
-		if (sctp_cmp_addr_exact(sctp_source(asconf), &addr))
+		if (sctp_cmp_addr_exact(&asconf->source, &addr))
 			return SCTP_ERROR_DEL_SRC_IP;
 
 		/* Section 4.2.2

