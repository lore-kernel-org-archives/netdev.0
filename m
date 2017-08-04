From: Florian Lehner <dev@der-flo.net>
Subject: [PATCH v5] ss: Enclose IPv6 address in brackets
Date: Fri, 4 Aug 2017 20:02:52 +0200
Message-ID: <1aa882d5-b7f6-8b91-b884-0bd45ebeb2a2@der-flo.net>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.der-flo.net ([193.160.39.236]:47240 "EHLO mx.der-flo.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751303AbdHDSCy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 14:02:54 -0400
Received: from [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179] (unknown [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179])
        (using TLSv1.2 with cipher ECDHE-ECDSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.der-flo.net (Postfix) with ESMTPSA id E17FD4863E
        for <netdev@vger.kernel.org>; Fri,  4 Aug 2017 20:02:52 +0200 (CEST)
In-Reply-To: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updated patch adds support for RFC2732 IPv6 address format with
brackets for the tool ss.

Now checking the complete IPv6 address if it is IN6ADDR_ANY.

Signed-off-by: Lehner Florian <dev@der-flo.net>
---
 misc/ss.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 12763c9..83683b5 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1046,8 +1046,9 @@ do_numeric:

 static void inet_addr_print(const inet_prefix *a, int port, unsigned
int ifindex)
 {
-	char buf[1024];
+	char buf[1024], buf2[1024];
 	const char *ap = buf;
+	char *c = NULL;
 	int est_len = addr_width;
 	const char *ifname = NULL;

@@ -1059,7 +1060,18 @@ static void inet_addr_print(const inet_prefix *a,
int port, unsigned int ifindex
 			ap = format_host(AF_INET, 4, a->data);
 		}
 	} else {
-		ap = format_host(a->family, 16, a->data);
+		if (a->data[0] == 0 && a->data[1] == 0 &&
+		    a->data[2] == 0 && a->data[3] == 0) {
+				buf[0] = '*';
+				buf[1] = 0;
+		} else {
+			ap = format_host(a->family, 16, a->data);
+			c = strchr(ap, ':');
+			if (c != NULL && a->family == AF_INET6) {
+				sprintf(buf2, "[%s]", ap);
+				ap = buf2;
+			}
+		}
 		est_len = strlen(ap);
 		if (est_len <= addr_width)
 			est_len = addr_width;
-- 
2.9.4
