From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 3/5 2.6.21-rc4] l2tp: pppox protocol module load
Date: Fri, 23 Mar 2007 23:07:27 GMT
Message-ID: <200703232307.l2NN7RrU010814@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:33024 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992616AbXCWXIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 19:08:11 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1HUsrY-00055a-Sm
	for netdev@vger.kernel.org; Fri, 23 Mar 2007 18:08:01 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l2NN7SNl010846
	for <netdev@vger.kernel.org>; Fri, 23 Mar 2007 23:07:28 GMT
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l2NN7RrU010814
	for netdev@vger.kernel.org; Fri, 23 Mar 2007 23:07:27 GMT
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PPPOL2TP]: Add the ability to autoload a pppox protocol module.

This patch allows a name "pppox-proto-nnn" to be used in modprobe.conf
to autoload a driver for PPPoX protocol nnn.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.21-rc4/drivers/net/pppox.c
===================================================================
--- linux-2.6.21-rc4.orig/drivers/net/pppox.c
+++ linux-2.6.21-rc4/drivers/net/pppox.c
@@ -114,6 +114,13 @@ static int pppox_create(struct socket *s
 		goto out;
 
 	rc = -EPROTONOSUPPORT;
+#ifdef CONFIG_KMOD
+	if (!pppox_protos[protocol]) {
+		char buffer[32];
+		sprintf(buffer, "pppox-proto-%d", protocol);
+		request_module(buffer);
+	}
+#endif
 	if (!pppox_protos[protocol] ||
 	    !try_module_get(pppox_protos[protocol]->owner))
 		goto out;
