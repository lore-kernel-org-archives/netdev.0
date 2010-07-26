From: leitao@linux.vnet.ibm.com
Subject: [PATCH] [PATCH] s2io: fixing DBG_PRINT() macro
Date: Mon, 26 Jul 2010 12:07:16 -0300
Message-ID: <1280156836-16138-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp04.br.ibm.com ([32.104.18.25]:48184 "EHLO
	e24smtp04.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753196Ab0GZPHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 11:07:22 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp04.br.ibm.com (8.14.4/8.13.1) with ESMTP id o6QF4mWP004626
	for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 12:04:48 -0300
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6QFCMNc1155576
	for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 12:12:22 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6QF7H5U001372
	for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 12:07:18 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 9e39f7c5b311a306977c5471f9e2ce4c456aa038 changed the
DBG_PRINT() macro and the if clause was wrongly changed. It means
that currently all the DBG_PRINT are being printed, flooding the
kernel log buffer with things like:

s2io: eth6: Next block at: c0000000b9c90000
s2io: eth6: In Neterion Tx routine

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Acked-by: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
---
 drivers/net/s2io.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 3645fb3..0af0335 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -65,7 +65,7 @@ static int debug_level = ERR_DBG;
 
 /* DEBUG message print. */
 #define DBG_PRINT(dbg_level, fmt, args...) do {			\
-	if (dbg_level >= debug_level)				\
+	if (dbg_level <= debug_level)				\
 		pr_info(fmt, ##args);				\
 	} while (0)
 
-- 
1.6.5.2

