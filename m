From: frank.blaschka@de.ibm.com
Subject: [patch 2/6] [PATCH] af_iucv: block writing if msg limit is exceeded
Date: Wed, 08 Feb 2012 11:19:46 +0100
Message-ID: <20120208102029.228513931@de.ibm.com>
References: <20120208101944.272235343@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:51654 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517Ab2BHKUm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 05:20:42 -0500
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 8 Feb 2012 10:20:41 -0000
Content-Disposition: inline; filename=602-af_iucv-msg-limit.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

When polling on an AF_IUCV socket, writing should be blocked if the
number of pending messages exceeds a defined limit.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 net/iucv/af_iucv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -1490,7 +1490,7 @@ unsigned int iucv_sock_poll(struct file
 	if (sk->sk_state == IUCV_DISCONN)
 		mask |= POLLIN;
 
-	if (sock_writeable(sk))
+	if (sock_writeable(sk) && iucv_below_msglim(sk))
 		mask |= POLLOUT | POLLWRNORM | POLLWRBAND;
 	else
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
