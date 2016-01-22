From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: allow setting SCTP_SACK_IMMEDIATELY by the application
Date: Fri, 22 Jan 2016 18:29:49 -0200
Message-ID: <e066aaa1725a6cafb73ad270376ed2ebc953917a.1453494301.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34239 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751987AbcAVU37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jan 2016 15:29:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch extends commit b93d6471748d ("sctp: implement the sender side
for SACK-IMMEDIATELY extension") as it didn't white list
SCTP_SACK_IMMEDIATELY on sctp_msghdr_parse(), causing it to be
understood as an invalid flag and returning -EINVAL to the application.

Note that the actual handling of the flag is already there in
sctp_datamsg_from_user().

https://tools.ietf.org/html/rfc7053#section-7

Fixes: b93d6471748d ("sctp: implement the sender side for SACK-IMMEDIATELY extension")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/socket.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 2657b51f627625a4d674041da1f6dd913932b1d7..594ba9db9c2660b6b0803a2a3955ea7e8b3a7a44 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -6638,6 +6638,7 @@ static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
 
 			if (cmsgs->srinfo->sinfo_flags &
 			    ~(SCTP_UNORDERED | SCTP_ADDR_OVER |
+			      SCTP_SACK_IMMEDIATELY |
 			      SCTP_ABORT | SCTP_EOF))
 				return -EINVAL;
 			break;
@@ -6661,6 +6662,7 @@ static int sctp_msghdr_parse(const struct msghdr *msg, sctp_cmsgs_t *cmsgs)
 
 			if (cmsgs->sinfo->snd_flags &
 			    ~(SCTP_UNORDERED | SCTP_ADDR_OVER |
+			      SCTP_SACK_IMMEDIATELY |
 			      SCTP_ABORT | SCTP_EOF))
 				return -EINVAL;
 			break;
-- 
2.5.0
