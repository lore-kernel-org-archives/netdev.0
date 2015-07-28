From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net] sctp: fix sockopt size check
Date: Tue, 28 Jul 2015 11:16:23 -0300
Message-ID: <387de09215f2ad50481516932f213cccfa077e3e.1438092726.git.marcelo.leitner@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42016 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754006AbbG1OQ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jul 2015 10:16:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem is not on being bigger than what we want, but on being
smaller, as it causes read of invalid memory.

Note that the struct changes on commit 7e8616d8e773 didn't affect
sctp_setsockopt_events one but that's where this check was flipped.

Fixes: 7e8616d8e773 ("[SCTP]: Update AUTH structures to match
declarations in draft-16.")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 1425ec2bbd5ae359a8e0408a89a6da6bb60bd87e..6c4f0dac2104d38ba6420ce6740224866a2ece82 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -2195,7 +2195,7 @@ static int sctp_setsockopt_events(struct sock *sk, char __user *optval,
 	struct sctp_association *asoc;
 	struct sctp_ulpevent *event;
 
-	if (optlen > sizeof(struct sctp_event_subscribe))
+	if (optlen < sizeof(struct sctp_event_subscribe))
 		return -EINVAL;
 	if (copy_from_user(&sctp_sk(sk)->subscribe, optval, optlen))
 		return -EFAULT;
-- 
2.4.3
