From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH] [SCTP]: Fix err_hdr assignment in sctp_init_cause.
Date: Tue, 09 Jan 2007 11:26:49 -0800
Message-ID: <1168370809.24896.20.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:35926 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123AbXAIT05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 14:26:57 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l09JQq1X017152
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 14:26:52 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l09JQoBG306606
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 14:26:52 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l09JQo6v006163
	for <netdev@vger.kernel.org>; Tue, 9 Jan 2007 14:26:50 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Fix err_hdr assignment in sctp_init_cause.

The subh->err_hdr should point to the error header, not the data.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/sm_make_chunk.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index f0bbe36..167d888 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -124,8 +124,8 @@ void  sctp_init_cause(struct sctp_chunk *chunk, __be16 cause_code,
 	padlen = len % 4;
 	err.length  = htons(len);
 	len += padlen;
-	sctp_addto_chunk(chunk, sizeof(sctp_errhdr_t), &err);
-	chunk->subh.err_hdr = sctp_addto_chunk(chunk, paylen, payload);
+	chunk->subh.err_hdr = sctp_addto_chunk(chunk, sizeof(sctp_errhdr_t), &err);
+	sctp_addto_chunk(chunk, paylen, payload);
 }

 /* 3.3.2 Initiation (INIT) (1)

