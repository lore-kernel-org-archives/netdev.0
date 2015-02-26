From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 5/5] tipc: make media address offset a common define
Date: Thu, 26 Feb 2015 07:43:30 +0100
Message-ID: <1424933010-31003-6-git-send-email-erik.hugne@ericsson.com>
References: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
	<richard.alpe@ericsson.com>, <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:55325 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753185AbbBZGrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 01:47:49 -0500
In-Reply-To: <1424933010-31003-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

With the exception of infiniband media which does not use media
offsets, the media address is always located at offset 4 in the
media info field as defined by the protocol, so we move the
definition to the generic bearer.h

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bearer.h    | 1 +
 net/tipc/eth_media.c | 6 ++----
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 1a23327..097aff0 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -52,6 +52,7 @@
  */
 #define TIPC_MEDIA_INFO_SIZE	32
 #define TIPC_MEDIA_TYPE_OFFSET	3
+#define TIPC_MEDIA_ADDR_OFFSET	4
 
 /*
  * Identifiers of supported TIPC media types
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 085d3a0..f69a2fd 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -37,8 +37,6 @@
 #include "core.h"
 #include "bearer.h"
 
-#define ETH_ADDR_OFFSET  4  /* MAC addr position inside address field */
-
 /* Convert Ethernet address (media address format) to string */
 static int tipc_eth_addr2str(struct tipc_media_addr *addr,
 			     char *strbuf, int bufsz)
@@ -55,7 +53,7 @@ static int tipc_eth_addr2msg(char *msg, struct tipc_media_addr *addr)
 {
 	memset(msg, 0, TIPC_MEDIA_INFO_SIZE);
 	msg[TIPC_MEDIA_TYPE_OFFSET] = TIPC_MEDIA_TYPE_ETH;
-	memcpy(msg + ETH_ADDR_OFFSET, addr->value, ETH_ALEN);
+	memcpy(msg + TIPC_MEDIA_ADDR_OFFSET, addr->value, ETH_ALEN);
 	return 0;
 }
 
@@ -79,7 +77,7 @@ static int tipc_eth_msg2addr(struct tipc_bearer *b,
 			     char *msg)
 {
 	/* Skip past preamble: */
-	msg += ETH_ADDR_OFFSET;
+	msg += TIPC_MEDIA_ADDR_OFFSET;
 	return tipc_eth_raw2addr(b, addr, msg);
 }
 
-- 
2.1.4
