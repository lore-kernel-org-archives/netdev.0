From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] ss: small optim in tcp_show_info()
Date: Wed, 06 May 2015 11:33:23 -0700
Message-ID: <1430937203.14545.62.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:34539 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbbEFSdZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 14:33:25 -0400
Received: by iedfl3 with SMTP id fl3so23754812ied.1
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 11:33:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Kernel can give us smaller tcp_info than our.

We copy the kernel provided structure and fill with 0
the remaining part.

Lets clear only the missing part to save some cycles, as we intend to
slightly increase tcp_info size in the future.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
diff --git a/misc/ss.c b/misc/ss.c
index 46dbb39..68961fc 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1893,8 +1893,8 @@ static void tcp_show_info(const struct nlmsghdr *nlh, struct inet_diag_msg *r,
 		/* workaround for older kernels with less fields */
 		if (len < sizeof(*info)) {
 			info = alloca(sizeof(*info));
-			memset(info, 0, sizeof(*info));
 			memcpy(info, RTA_DATA(tb[INET_DIAG_INFO]), len);
+			memset((char *)info + len, 0, sizeof(*info) - len);
 		} else
 			info = RTA_DATA(tb[INET_DIAG_INFO]);
 
