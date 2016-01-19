From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 1/1] af_iucv: Validate socket address length in iucv_sock_bind()
Date: Tue, 19 Jan 2016 10:41:33 +0100
Message-ID: <1453196493-57590-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1453196493-57590-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: ubraunu@linux.vnet.ibm.com
To: davem@davemloft.net, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:55050 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757628AbcASJmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 04:42:08 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 19 Jan 2016 09:42:05 -0000
In-Reply-To: <1453196493-57590-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Reviewed-by: Evgeny Cherkashin <Eugene.Crosser@ru.ibm.com>
---
 net/iucv/af_iucv.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index ef50a94..fc3598a 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -708,6 +708,9 @@ static int iucv_sock_bind(struct socket *sock, struct sockaddr *addr,
 	if (!addr || addr->sa_family != AF_IUCV)
 		return -EINVAL;
 
+	if (addr_len < sizeof(struct sockaddr_iucv))
+		return -EINVAL;
+
 	lock_sock(sk);
 	if (sk->sk_state != IUCV_OPEN) {
 		err = -EBADFD;
-- 
2.3.9
