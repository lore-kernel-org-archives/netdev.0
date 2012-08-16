From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] sctp: fix bogus if statement in sctp_auth_recv_cid()
Date: Thu, 16 Aug 2012 16:16:19 +0300
Message-ID: <20120816131618.GA23279@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:23551 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932479Ab2HPNQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2012 09:16:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is an extra semi-colon here, so we always return 0 instead of
calling __sctp_auth_cid().

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Only needed for linux-next.

diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index aaa6c12..159b9bc 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -695,7 +695,7 @@ int sctp_auth_recv_cid(sctp_cid_t chunk, const struct sctp_association *asoc)
 		return 0;
 
 	net = sock_net(asoc->base.sk);
-	if (!net->sctp.auth_enable);
+	if (!net->sctp.auth_enable)
 		return 0;
 
 	return __sctp_auth_cid(chunk,
