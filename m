From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2] sctp: keep fragmentation point aligned to word size
Date: Sat, 19 Mar 2016 12:17:43 -0300
Message-ID: <1458400663-25558-1-git-send-email-marcelo.leitner@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41127 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754118AbcCSPRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Mar 2016 11:17:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user supply a different fragmentation point or if there is a
network header that cause it to not be aligned, force it to be aligned.

Fragmentation point at a value that is not aligned is not optimal.  It
causes extra padding to be used and has just no pros.

v2:
 - Make use of the new WORD_TRUNC macro

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/sctp.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index ad2136caa7d65fdc0f51e4c7ad3a526c2f39660d..65521cfdcadeee35d61f280165a387cc2164ab6d 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -431,7 +431,7 @@ static inline int sctp_frag_point(const struct sctp_association *asoc, int pmtu)
 	if (asoc->user_frag)
 		frag = min_t(int, frag, asoc->user_frag);
 
-	frag = min_t(int, frag, SCTP_MAX_CHUNK_LEN);
+	frag = WORD_TRUNC(min_t(int, frag, SCTP_MAX_CHUNK_LEN));
 
 	return frag;
 }
-- 
2.5.0
