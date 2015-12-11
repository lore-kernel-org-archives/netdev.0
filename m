From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH 1/7] iucv: prevent information leak in iucv_message
Date: Fri, 11 Dec 2015 11:38:51 +0100
Message-ID: <1449830337-26091-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1449830337-26091-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: ubraunu@linux.vnet.ibm.com
To: davem@davemloft.net, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:46217 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880AbbLKKjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 05:39:08 -0500
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 11 Dec 2015 10:39:07 -0000
In-Reply-To: <1449830337-26091-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Initialize storage for the future IUCV header that will be included
in the transmitted packet. Some of the header fields are unused with
HiperSockets transport, and will contain data left from some other
functions.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 net/iucv/af_iucv.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index 3ea4c98..5bc473b 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1031,7 +1031,7 @@ static int iucv_sock_sendmsg(struct socket *sock, struct msghdr *msg,
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv = iucv_sk(sk);
 	struct sk_buff *skb;
-	struct iucv_message txmsg;
+	struct iucv_message txmsg = {0};
 	struct cmsghdr *cmsg;
 	int cmsg_done;
 	long timeo;
-- 
2.3.9
