From: Florian Lehner <dev@der-flo.net>
Subject: [PATCH v2] ss: Enclose IPv6 address in brackets
Date: Mon, 31 Jul 2017 21:50:04 +0200
Message-ID: <182a039f-5e8f-3c37-a32b-ae4562c57c1c@der-flo.net>
References: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.der-flo.net ([193.160.39.236]:45501 "EHLO mx.der-flo.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750999AbdGaTuG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Jul 2017 15:50:06 -0400
Received: from [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179] (unknown [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179])
        (using TLSv1.2 with cipher ECDHE-ECDSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.der-flo.net (Postfix) with ESMTPSA id 340F147EAE
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 21:50:05 +0200 (CEST)
In-Reply-To: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This updated patch adds support for RFC2732 IPv6 address format with
brackets for the tool ss. Resolved hostnames will not be enclosed in
brackets, therefore the global variable resolve_hosts is initialized and
checked.

Signed-off-by: Lehner Florian <dev@der-flo.net>
---
 misc/ss.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 12763c9..ac94537 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -88,7 +88,7 @@ static int security_get_initial_context(char *name,
char **context)
 }
 #endif

-int resolve_hosts;
+int resolve_hosts = 0;
 int resolve_services = 1;
 int preferred_family = AF_UNSPEC;
 int show_options;
@@ -1059,7 +1059,11 @@ static void inet_addr_print(const inet_prefix *a,
int port, unsigned int ifindex
 			ap = format_host(AF_INET, 4, a->data);
 		}
 	} else {
-		ap = format_host(a->family, 16, a->data);
+		if (a->family == AF_INET6 && !resolve_hosts) {
+			sprintf(buf, "[%s]", format_host(a->family, 16, a->data));
+		} else {
+			ap = format_host(a->family, 16, a->data);
+		}
 		est_len = strlen(ap);
 		if (est_len <= addr_width)
 			est_len = addr_width;
-- 
2.9.4
