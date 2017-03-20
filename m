From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] sctp: remove useless err from sctp_association_init
Date: Mon, 20 Mar 2017 18:00:28 +0800
Message-ID: <82209fcc4742baa1c4855af7e54b88177e9d0537.1490004028.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35400 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754050AbdCTKJl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 06:09:41 -0400
Received: by mail-pg0-f65.google.com with SMTP id g2so19069282pge.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 03:09:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the unnecessary temporary variable 'err' from
sctp_association_init.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/associola.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 2a6835b..0439a1a 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -71,9 +71,8 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 {
 	struct net *net = sock_net(sk);
 	struct sctp_sock *sp;
-	int i;
 	sctp_paramhdr_t *p;
-	int err;
+	int i;
 
 	/* Retrieve the SCTP per socket area.  */
 	sp = sctp_sk((struct sock *)sk);
@@ -264,8 +263,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 
 	/* AUTH related initializations */
 	INIT_LIST_HEAD(&asoc->endpoint_shared_keys);
-	err = sctp_auth_asoc_copy_shkeys(ep, asoc, gfp);
-	if (err)
+	if (sctp_auth_asoc_copy_shkeys(ep, asoc, gfp))
 		goto fail_init;
 
 	asoc->active_key_id = ep->active_key_id;
-- 
2.1.0
