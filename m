From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH net-next-2.6 v5 4/5] sctp: Add ADD/DEL ASCONF handling at the receiver
Date: Tue, 26 Apr 2011 00:23:58 +0900
Message-ID: <360A83BB-EE0A-4370-AF38-F23414AC8198@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:53026 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755013Ab1DYPYE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2011 11:24:04 -0400
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

