From: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
Subject: clarify code intent
Date: Thu, 18 Sep 2008 10:07:48 -0700
Message-ID: <1221757668.23007.12.camel@ns-test>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-5ZIWZpeoWDcOCjb10Cvn"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:35173 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752266AbYIRRRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2008 13:17:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5ZIWZpeoWDcOCjb10Cvn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

hi,

The attached patch hopefully clarifies the intent of the unix_bind
function in net/unix/af_unix.c. That 'feature' (the ability to delegate
the endpoint allocation to the kernel with bind by sending a
sockaddr_un.sun_family = AF_UNIX rather than have to wait until the
autobind is triggered by a later call to send) would be nice to document
in the unix '7' manpage but, I have no idea where these are maintained.
I also have no idea whether that specific 'feature' is common among
other unixes. It is quite useful though.

Mathieu

--=-5ZIWZpeoWDcOCjb10Cvn
Content-Disposition: attachment; filename=p
Content-Type: text/x-patch; name=p; charset=UTF-8
Content-Transfer-Encoding: 7bit

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 015606b..efa725e 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -777,7 +777,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	if (sunaddr->sun_family != AF_UNIX)
 		goto out;
 
-	if (addr_len==sizeof(short)) {
+	if (addr_len==sizeof(sa_family_t)) {
 		err = unix_autobind(sock);
 		goto out;
 	}

--=-5ZIWZpeoWDcOCjb10Cvn--

