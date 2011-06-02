From: Michio Honda <micchie@sfc.wide.ad.jp>
Subject: [PATCH 1/6 v9] sctp: Add ADD/DEL ASCONF handling at the receiver.
Date: Thu, 2 Jun 2011 12:01:05 +0900
Message-ID: <506FB213-6C73-4F00-95B2-E20976F2064E@sfc.wide.ad.jp>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shonan.sfc.wide.ad.jp ([203.178.142.130]:49907 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759290Ab1FBDBG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 23:01:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From fb3b20d29f89c1570d44df7fdc20fe0ed12a71f0 Mon Sep 17 00:00:00 2001
From: Michio Honda <micchie@sfc.wide.ad.jp>
Date: Tue, 26 Apr 2011 17:37:02 +0900
Subject: [PATCH 1/6 v9] sctp: Add ADD/DEL ASCONF handling at the receiver.

This patch fixes the problem that the original code cannot delete
the remote address where the corresponding transport is currently
directed, even when the ASCONF is sent from the other address (this
situation happens when the single-homed sender transmits  ASCONF
with ADD and DEL.)

Signed-off-by: Michio Honda <micchie@sfc.wide.ad.jp>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/sctp/sm_make_chunk.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 58eb27f..3740603 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3014,7 +3014,7 @@ static __be16 sctp_process_asconf_param(struct sctp_association *asoc,
 		 * an Error Cause TLV set to the new error code 'Request to
 		 * Delete Source IP Address'
 		 */
-		if (sctp_cmp_addr_exact(sctp_source(asconf), &addr))
+		if (sctp_cmp_addr_exact(&asconf->source, &addr))
 			return SCTP_ERROR_DEL_SRC_IP;
 
 		/* Section 4.2.2
-- 
1.7.3.2


