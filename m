From: James Chapman <jchapman@katalix.com>
Subject: [PATCH 4/5 2.6.21-rc7] l2tp: pppox protocol module load
Date: Mon, 23 Apr 2007 13:56:40 +0100
Message-ID: <200704231256.l3NCuecl028387@quickie.katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:37866 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161534AbXDWM5X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Apr 2007 08:57:23 -0400
Received: from jchapman.plus.com ([84.92.108.75] helo=quickie.katalix.com)
	by s36.avahost.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.63)
	(envelope-from <jchapman@katalix.com>)
	id 1Hfy6Z-00077f-5G
	for netdev@vger.kernel.org; Mon, 23 Apr 2007 07:57:19 -0500
Received: from quickie.katalix.com (quickie.katalix.com [127.0.0.1])
	by quickie.katalix.com (8.13.5/8.13.5) with ESMTP id l3NCuevI028398
	for <netdev@vger.kernel.org>; Mon, 23 Apr 2007 13:56:41 +0100
Received: (from james@localhost)
	by quickie.katalix.com (8.13.5/8.13.5/Submit) id l3NCuecl028387
	for netdev@vger.kernel.org; Mon, 23 Apr 2007 13:56:40 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[L2TP]: Add the ability to autoload a pppox protocol module.

This patch allows a name "pppox-proto-nnn" to be used in modprobe.conf
to autoload a PPPoX protocol nnn.

Signed-off-by: James Chapman <jchapman@katalix.com>

Index: linux-2.6.21-rc7/drivers/net/pppox.c
===================================================================
--- linux-2.6.21-rc7.orig/drivers/net/pppox.c
+++ linux-2.6.21-rc7/drivers/net/pppox.c
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
