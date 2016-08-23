From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net] sctp: fix overrun in sctp_diag_dump_one()
Date: Tue, 23 Aug 2016 11:40:52 -0400
Message-ID: <1471966852-6218-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36294 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751550AbcHWPlT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 23 Aug 2016 11:41:19 -0400
Received: from int-mx14.intmail.prod.int.phx2.redhat.com (int-mx14.intmail.prod.int.phx2.redhat.com [10.5.11.27])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id AB0839B0ED
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 15:40:52 +0000 (UTC)
Received: from thinkcentre.nc.rr.com (vpn-59-57.rdu2.redhat.com [10.10.59.57])
        by int-mx14.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u7NFeqea031060
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:40:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function sctp_diag_dump_one() currently performs a memcpy()
of 64 bytes from a 16 byte field into another 16 byte field. Fix
by using correct size, use sizeof to obtain correct size instead
of using a hard-coded constant.

Fixes: 8f840e47f190 ("sctp: add the sctp_diag.c file")
Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 net/sctp/sctp_diag.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index bb69153..f3508aa 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -424,11 +424,13 @@ static int sctp_diag_dump_one(struct sk_buff *in_skb,
 		paddr.v4.sin_family = AF_INET;
 	} else {
 		laddr.v6.sin6_port = req->id.idiag_sport;
-		memcpy(&laddr.v6.sin6_addr, req->id.idiag_src, 64);
+		memcpy(&laddr.v6.sin6_addr, req->id.idiag_src,
+		       sizeof(laddr.v6.sin6_addr));
 		laddr.v6.sin6_family = AF_INET6;
 
 		paddr.v6.sin6_port = req->id.idiag_dport;
-		memcpy(&paddr.v6.sin6_addr, req->id.idiag_dst, 64);
+		memcpy(&paddr.v6.sin6_addr, req->id.idiag_dst,
+		       sizeof(paddr.v6.sin6_addr));
 		paddr.v6.sin6_family = AF_INET6;
 	}
 
-- 
2.5.5
