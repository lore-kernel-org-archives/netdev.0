From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next iproute2] ip: increase number of MPLS labels
Date: Sat, 29 Apr 2017 20:48:50 -0700
Message-ID: <1493524130-10220-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35604 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1164562AbdD3Dsy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Apr 2017 23:48:54 -0400
Received: by mail-pf0-f172.google.com with SMTP id v14so63758521pfd.2
        for <netdev@vger.kernel.org>; Sat, 29 Apr 2017 20:48:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel now supports more than 2 labels. Increase ip to
handle up to 16 labels.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/utils.h | 8 ++++----
 lib/utils.c     | 2 +-
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 8c12e1e2a60c..a69e176c260d 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -54,6 +54,9 @@ void incomplete_command(void) __attribute__((noreturn));
 #define NEXT_ARG_FWD() do { argv++; argc--; } while(0)
 #define PREV_ARG() do { argv--; argc++; } while(0)
 
+/* Maximum number of labels the mpls helpers support */
+#define MPLS_MAX_LABELS 16
+
 typedef struct
 {
 	__u16 flags;
@@ -61,7 +64,7 @@ typedef struct
 	__s16 bitlen;
 	/* These next two fields match rtvia */
 	__u16 family;
-	__u32 data[8];
+	__u32 data[MPLS_MAX_LABELS];
 } inet_prefix;
 
 #define PREFIXLEN_SPECIFIED 1
@@ -88,9 +91,6 @@ struct ipx_addr {
 # define AF_MPLS 28
 #endif
 
-/* Maximum number of labels the mpls helpers support */
-#define MPLS_MAX_LABELS 8
-
 __u32 get_addr32(const char *name);
 int get_addr_1(inet_prefix *dst, const char *arg, int family);
 int get_prefix_1(inet_prefix *dst, char *arg, int family);
diff --git a/lib/utils.c b/lib/utils.c
index 6d5642f4f1f3..c23251067180 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -526,7 +526,7 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
 		addr->bytelen = 4;
 		addr->bitlen = 20;
 		/* How many bytes do I need? */
-		for (i = 0; i < 8; i++) {
+		for (i = 0; i < MPLS_MAX_LABELS; i++) {
 			if (ntohl(addr->data[i]) & MPLS_LS_S_MASK) {
 				addr->bytelen = (i + 1)*4;
 				break;
-- 
2.1.4
