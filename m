From: Marcela Maslanova <mmaslano@redhat.com>
Subject: [PATCH] [iproute2/ip] ip segfault with wrong key
Date: Fri, 04 Jul 2008 14:33:32 +0200
Message-ID: <486E189C.2010507@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040804000902090507040604"
Cc: shemminger@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46262 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653AbYGDMdk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 08:33:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040804000902090507040604
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 8bit

Wrong key in "ip xfrm state" command lead to segfault. I thought there 
could be used only hexadecimal numbers. I'm suggesting attached patch. 
The example of problem could be seen here: 
https://bugzilla.redhat.com/show_bug.cgi?id=449933

-- 
Marcela Ma¹láòová
BaseOS team Brno


--------------040804000902090507040604
Content-Type: text/x-patch;
 name="0001-The-key-should-be-hexadecimal-number.-This-fix-shoul.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-The-key-should-be-hexadecimal-number.-This-fix-shoul.pa";
 filename*1="tch"

>From e2ea8623c5d4fb761924cb7744a0bb220b65e03e Mon Sep 17 00:00:00 2001
From: =?utf-8?q?Marcela=20Ma=C5=A1l=C3=A1=C5=88ov=C3=A1?= <mmaslano@redhat.com>
Date: Fri, 4 Jul 2008 13:38:17 +0200
Subject: [PATCH] The key should be hexadecimal number. This fix should solve
 segfault with wrong key.

---
 ip/xfrm_state.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index ff309e7..9a34da4 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -160,8 +160,9 @@ static int xfrm_algo_parse(struct xfrm_algo *alg, enum xfrm_attr_type_t type,
 		if (len > 0) {
 			if (len > max)
 				invarg("\"ALGOKEY\" makes buffer overflow\n", key);
-
-			strncpy(alg->alg_key, key, len);
+			else
+				invarg("\"ALGOKEY\" is invalid", key);
+			/* strncpy(alg->alg_key, key, len); */
 		}
 	}
 
-- 
1.5.5.1


--------------040804000902090507040604--
