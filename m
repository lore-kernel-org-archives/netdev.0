From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] iproute2: ndm states should be handled as flags
Date: Tue, 16 Nov 2004 01:15:26 +0100
Message-ID: <20041116001526.GE31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen,

ndm states are actually flags.

diff -Nru iproute2-2.6.9.orig/ip/ipneigh.c iproute2-2.6.9/ip/ipneigh.c
--- iproute2-2.6.9.orig/ip/ipneigh.c	2004-10-19 22:49:02.000000000 +0200
+++ iproute2-2.6.9/ip/ipneigh.c	2004-11-16 01:12:59.000000000 +0100
@@ -86,33 +86,6 @@
 	return 0;
 }
 
-char * nud_state_n2a(__u8 state, char *buf, int len)
-{
-	switch (state) {
-	case NUD_NONE:	
-		return "none";
-	case NUD_INCOMPLETE:	
-		return "incomplete";
-	case NUD_REACHABLE:	
-		return "reachable";
-	case NUD_STALE:	
-		return "stale";
-	case NUD_DELAY:	
-		return "delay";
-	case NUD_PROBE:	
-		return "probe";
-	case NUD_FAILED:	
-		return "failed";
-	case NUD_NOARP:	
-		return "noarp";
-	case NUD_PERMANENT:	
-		return "permanent";
-	default:	
-		snprintf(buf, len, "%x", state);
-		return buf;
-	}
-}
-
 static int flush_update(void)
 {
 	if (rtnl_send(filter.rth, filter.flushb, filter.flushp) < 0) {
@@ -316,8 +289,20 @@
 	}
 
 	if (r->ndm_state) {
-		SPRINT_BUF(b1);
-		fprintf(fp, " nud %s", nud_state_n2a(r->ndm_state, b1, sizeof(b1)));
+		int nud = r->ndm_state;
+		fprintf(fp, " ");
+
+#define PRINT_FLAG(f) if (nud & NUD_##f) { \
+	nud &= ~NUD_##f; fprintf(fp, #f "%s", nud ? "," : ""); }
+		PRINT_FLAG(INCOMPLETE);
+		PRINT_FLAG(REACHABLE);
+		PRINT_FLAG(STALE);
+		PRINT_FLAG(DELAY);
+		PRINT_FLAG(PROBE);
+		PRINT_FLAG(FAILED);
+		PRINT_FLAG(NOARP);
+		PRINT_FLAG(PERMANENT);
+#undef PRINT_FLAG
 	}
 	fprintf(fp, "\n");
 
