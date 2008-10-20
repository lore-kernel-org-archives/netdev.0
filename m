From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: disable NAPI on failure to setup the interface
Date: Mon, 20 Oct 2008 13:54:12 +0200
Message-ID: <48FC7164.8040002@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1945 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751956AbYJTLyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Oct 2008 07:54:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disable NAPI if a failure occurs when setting up the interface. Leaving
it enabled could cause a BUG the next time an ifconfig up is issued.

Signed-off-by: Brice Goglin <brice@myri.com>

--- linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-10-20 08:36:48.000000000 +0200
+++ linux-tmp/drivers/net/myri10ge/myri10ge.c	2008-10-20 13:47:21.000000000 +0200
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.3-1.369"
+#define MYRI10GE_VERSION_STR "1.4.3-1.371"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -2497,6 +2497,10 @@ static int myri10ge_open(struct net_devi
 	return 0;
 
 abort_with_rings:
+	while (slice) {
+		slice--;
+		napi_disable(&mgp->ss[slice].napi);
+	}
 	for (i = 0; i < mgp->num_slices; i++)
 		myri10ge_free_rings(&mgp->ss[i]);
 


