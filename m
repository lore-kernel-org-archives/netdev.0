From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: reorganize IP MIB values
Date: Sun, 05 Aug 2012 08:33:59 +0200
Message-ID: <1344148439.9299.1570.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:61744 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab2HEGeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Aug 2012 02:34:05 -0400
Received: by wibhr14 with SMTP id hr14so744811wib.1
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 23:34:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Reduce IP latencies by placing hot MIB IP fields in a single cache line.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/snmp.h |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 00bc189..aa02b9e 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -18,7 +18,14 @@
 enum
 {
 	IPSTATS_MIB_NUM = 0,
+/* frequently written fields in fast path, kept in same cache line */
 	IPSTATS_MIB_INPKTS,			/* InReceives */
+	IPSTATS_MIB_INOCTETS,			/* InOctets */
+	IPSTATS_MIB_INDELIVERS,			/* InDelivers */
+	IPSTATS_MIB_OUTFORWDATAGRAMS,		/* OutForwDatagrams */
+	IPSTATS_MIB_OUTPKTS,			/* OutRequests */
+	IPSTATS_MIB_OUTOCTETS,			/* OutOctets */
+/* other fields */
 	IPSTATS_MIB_INHDRERRORS,		/* InHdrErrors */
 	IPSTATS_MIB_INTOOBIGERRORS,		/* InTooBigErrors */
 	IPSTATS_MIB_INNOROUTES,			/* InNoRoutes */
@@ -26,9 +33,6 @@ enum
 	IPSTATS_MIB_INUNKNOWNPROTOS,		/* InUnknownProtos */
 	IPSTATS_MIB_INTRUNCATEDPKTS,		/* InTruncatedPkts */
 	IPSTATS_MIB_INDISCARDS,			/* InDiscards */
-	IPSTATS_MIB_INDELIVERS,			/* InDelivers */
-	IPSTATS_MIB_OUTFORWDATAGRAMS,		/* OutForwDatagrams */
-	IPSTATS_MIB_OUTPKTS,			/* OutRequests */
 	IPSTATS_MIB_OUTDISCARDS,		/* OutDiscards */
 	IPSTATS_MIB_OUTNOROUTES,		/* OutNoRoutes */
 	IPSTATS_MIB_REASMTIMEOUT,		/* ReasmTimeout */
@@ -42,8 +46,6 @@ enum
 	IPSTATS_MIB_OUTMCASTPKTS,		/* OutMcastPkts */
 	IPSTATS_MIB_INBCASTPKTS,		/* InBcastPkts */
 	IPSTATS_MIB_OUTBCASTPKTS,		/* OutBcastPkts */
-	IPSTATS_MIB_INOCTETS,			/* InOctets */
-	IPSTATS_MIB_OUTOCTETS,			/* OutOctets */
 	IPSTATS_MIB_INMCASTOCTETS,		/* InMcastOctets */
 	IPSTATS_MIB_OUTMCASTOCTETS,		/* OutMcastOctets */
 	IPSTATS_MIB_INBCASTOCTETS,		/* InBcastOctets */
