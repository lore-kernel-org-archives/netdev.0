From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: Add tos to validate source tracepoint
Date: Mon, 31 Aug 2015 09:57:12 -0600
Message-ID: <1441036632-26203-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:36854 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724AbbHaP5a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 11:57:30 -0400
Received: by igboj15 with SMTP id oj15so30605586igb.1
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2015 08:57:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TOS is another key aspect of the lookup passed to fib_validate_source.
Add it to the tracepoint.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/trace/events/fib.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/trace/events/fib.h b/include/trace/events/fib.h
index 4030f75410d7..acd1d22571a2 100644
--- a/include/trace/events/fib.h
+++ b/include/trace/events/fib.h
@@ -83,6 +83,7 @@ TRACE_EVENT(fib_validate_source,
 		__string(	name,	dev->name	)
 		__field(	int,	oif		)
 		__field(	int,	iif		)
+		__field(	__u8,	tos		)
 		__array(	__u8,	src,	4	)
 		__array(	__u8,	dst,	4	)
 	),
@@ -93,6 +94,7 @@ TRACE_EVENT(fib_validate_source,
 		__assign_str(name, dev ? dev->name : "not set");
 		__entry->oif = flp->flowi4_oif;
 		__entry->iif = flp->flowi4_iif;
+		__entry->tos = flp->flowi4_tos;
 
 		p32 = (__be32 *) __entry->src;
 		*p32 = flp->saddr;
@@ -101,8 +103,8 @@ TRACE_EVENT(fib_validate_source,
 		*p32 = flp->daddr;
 	),
 
-	TP_printk("dev %s oif %d iif %d src %pI4 dst %pI4",
-		  __get_str(name), __entry->oif, __entry->iif,
+	TP_printk("dev %s oif %d iif %d tos %d src %pI4 dst %pI4",
+		  __get_str(name), __entry->oif, __entry->iif, __entry->tos,
 		  __entry->src, __entry->dst)
 );
 #endif /* _TRACE_FIB_H */
-- 
2.3.2 (Apple Git-55)
