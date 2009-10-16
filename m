From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH 1/4 revised] TCPCT part 1a: extend struct tcp_request_sock
Date: Fri, 16 Oct 2009 13:39:12 -0400
Message-ID: <4AD8AFC0.1090101@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060904040004060802030407"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:38956 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbZJPRjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 13:39:13 -0400
Received: by fxm18 with SMTP id 18so2684328fxm.37
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2009 10:39:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060904040004060802030407
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Pass additional parameters associated with sending SYNACK.  This
is not as straightforward or architecturally clean as previously
proposed, and has the unfortunate side effect of potentially
including otherwise unneeded headers for related protocols, but
that problem will affect very few files.
---
  include/net/extend_request_sock.h |   37 +++++++++++++++++++++++++++++++++++++
  1 files changed, 37 insertions(+), 0 deletions(-)
  create mode 100644 include/net/extend_request_sock.h


--------------060904040004060802030407
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1+1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1+1.patch"

diff --git a/include/net/extend_request_sock.h b/include/net/extend_request_sock.h
new file mode 100644
index 0000000..c991af9
--- /dev/null
+++ b/include/net/extend_request_sock.h
@@ -0,0 +1,37 @@
+#ifndef _EXTEND_REQUEST_SOCK_H
+#define _EXTEND_REQUEST_SOCK_H
+/*
+ * Short term extension of struct tcp_request_sock and related.
+ *
+ * Copyright (C) 2009 William.Allen.Simpson@gmail.com
+ * All rights reserved.
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+#include <linux/tcp.h>
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#include <linux/ipv6.h>
+#endif
+
+struct extend_request_sock {
+	union {
+		struct tcp_request_sock tcp4rsk;
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+		struct tcp6_request_sock tcp6rsk;
+#endif
+	} header;
+
+	u8	cookie_plus;
+	u8	cookie_in_always:1,
+		cookie_out_never:1;
+};
+
+static inline struct extend_request_sock *ext_rsk(const struct request_sock *req)
+{
+	return (struct extend_request_sock *)req;
+}
+
+#endif /* _EXTEND_REQUEST_SOCK_H */
-- 
1.6.0.4


--------------060904040004060802030407--
