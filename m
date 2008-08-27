From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 1/2] sctp: correct bounds check in sctp_setsockopt_auth_key
Date: Wed, 27 Aug 2008 16:03:34 -0400
Message-ID: <12198674162757-git-send-email-vladislav.yasevich@hp.com>
References: <48B42ECA.7010800@redhat.com>
Cc: eteo@redhat.com, netdev@vger.kernel.org, security@kernel.org,
	linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:40564 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbYH0UDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 16:03:38 -0400
In-Reply-To: <48B42ECA.7010800@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonds check to prevent buffer overlflow was not exactly
right.  It still allowed overflow of up to 8 bytes which is
sizeof(struct sctp_authkey).

Since optlen is already checked against the size of that struct,
we are guaranteed not to cause interger overflow either.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index afa952e..9b9b2c3 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3144,7 +3144,7 @@ static int sctp_setsockopt_auth_key(struct sock *sk,
 		goto out;
 	}
 
-	if (authkey->sca_keylength > optlen) {
+	if (authkey->sca_keylength > optlen - sizeof(struct sctp_authkey)) {
 		ret = -EINVAL;
 		goto out;
 	}
-- 
1.5.2.5

