From: Florian Lehner <dev@der-flo.net>
Subject: [PATCH] ss: Enclose IPv6 address in brackets
Date: Sat, 29 Jul 2017 14:29:10 +0200
Message-ID: <fc81757c-8dbb-dbed-7a24-7011cb8bb9e0@der-flo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.der-flo.net ([193.160.39.236]:44943 "EHLO mx.der-flo.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753475AbdG2Mev (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Jul 2017 08:34:51 -0400
Received: from [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179] (unknown [IPv6:2a02:1205:c693:af80:5ee0:c5ff:fe8a:a179])
        (using TLSv1.2 with cipher ECDHE-ECDSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mx.der-flo.net (Postfix) with ESMTPSA id D9AFD47D8F
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 14:29:10 +0200 (CEST)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for RFC2732 IPv6 address format with brackets
for the tool ss. So output for ss changes from
2a00:1450:400a:804::200e:443 to [2a00:1450:400a:804::200e]:443 for IPv6
addresses with attached port number.

Signed-off-by: Lehner Florian <dev@der-flo.net>
---
 misc/ss.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index 12763c9..db39c93 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1059,7 +1059,11 @@ static void inet_addr_print(const inet_prefix *a,
int port, unsigned int ifindex
 			ap = format_host(AF_INET, 4, a->data);
 		}
 	} else {
-		ap = format_host(a->family, 16, a->data);
+		if (a->family == AF_INET6) {
+			sprintf(buf, "[%s]", format_host(a->family, 16, a->data));
+		} else {
+			ap = format_host(a->family, 16, a->data);
+		}
 		est_len = strlen(ap);
 		if (est_len <= addr_width)
 			est_len = addr_width;
-- 
2.9.4
