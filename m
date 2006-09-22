From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 2.6.19]  net/dccp: set safe upper bound for option length
Date: Fri, 22 Sep 2006 15:48:38 +0100
Message-ID: <200609221548.38586@strip-the-willow>
References: <200609221545.03112@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:25050 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S932553AbWIVOst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 10:48:49 -0400
To: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
In-Reply-To: <200609221545.03112@strip-the-willow>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stupid me, it should read 4 * 255 = 1020, not 8 * 255; this is
fixed below.

--
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 272e858..adabf3e 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -40,12 +40,17 @@ extern void dccp_tw_deschedule(struct in
 
 extern void dccp_time_wait(struct sock *sk, int state, int timeo);
 
-/* FIXME: Right size this */
-#define DCCP_MAX_OPT_LEN 128
-
-#define DCCP_MAX_PACKET_HDR 32
-
-#define MAX_DCCP_HEADER  (DCCP_MAX_PACKET_HDR + DCCP_MAX_OPT_LEN + MAX_HEADER)
+/*
+ *  Set safe upper bounds for header and option length. Since Data Offset is 8
+ *  bits (RFC 4340, sec. 5.1), the total header length can never be more than
+ *  4 * 255 = 1020 bytes. The largest possible header length is 28 bytes (X=1):
+ *    - DCCP-Response with ACK Subheader and 4 bytes of Service code      OR
+ *    - DCCP-Reset    with ACK Subheader and 4 bytes of Reset Code fields
+ *  Hence a safe upper bound for the maximum option length is 1020-28 = 992
+ */
+#define DCCP_MAX_OPT_LEN      992
+#define DCCP_MAX_PACKET_HDR    28
+#define MAX_DCCP_HEADER     (1020 + MAX_HEADER)
 
 #define DCCP_TIMEWAIT_LEN (60 * HZ) /* how long to wait to destroy TIME-WAIT
 				     * state, about 60 seconds */
