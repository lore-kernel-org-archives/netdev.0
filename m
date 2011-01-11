From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] xfrm: check trunc_len in XFRMA_ALG_AUTH_TRUNC
Date: Tue, 11 Jan 2011 19:04:12 +0100
Message-ID: <4D2C9B9C.9020800@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040401050009090205060801"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38340 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753913Ab1AKSEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 13:04:16 -0500
Received: by wwa36 with SMTP id 36so2064423wwa.1
        for <netdev@vger.kernel.org>; Tue, 11 Jan 2011 10:04:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040401050009090205060801
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

patch is attached.


Regards,
Nicolas

--------------040401050009090205060801
Content-Type: text/x-patch;
 name="0001-xfrm-check-trunc_len-in-XFRMA_ALG_AUTH_TRUNC.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-xfrm-check-trunc_len-in-XFRMA_ALG_AUTH_TRUNC.patch"

>From 48dd29c69f150fc55bf3a477b9365d1575a9cfbe Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue, 11 Jan 2011 13:23:51 -0500
Subject: [PATCH] xfrm: check trunc_len in XFRMA_ALG_AUTH_TRUNC

Maximum trunc length is defined by MAX_AH_AUTH_LEN (in bytes)
and need to be checked when this value is set (in bits) by
the user. In ah4.c and ah6.c a BUG_ON() checks this condiftion.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/xfrm/xfrm_user.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8bae6b2..b45288f 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -26,6 +26,7 @@
 #include <net/sock.h>
 #include <net/xfrm.h>
 #include <net/netlink.h>
+#include <net/ah.h>
 #include <asm/uaccess.h>
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 #include <linux/in6.h>
@@ -296,7 +297,8 @@ static int attach_auth_trunc(struct xfrm_algo_auth **algpp, u8 *props,
 	algo = xfrm_aalg_get_byname(ualg->alg_name, 1);
 	if (!algo)
 		return -ENOSYS;
-	if (ualg->alg_trunc_len > algo->uinfo.auth.icv_fullbits)
+	if ((ualg->alg_trunc_len / 8) > MAX_AH_AUTH_LEN ||
+	    ualg->alg_trunc_len > algo->uinfo.auth.icv_fullbits)
 		return -EINVAL;
 	*props = algo->desc.sadb_alg_id;
 
-- 
1.5.6.5


--------------040401050009090205060801--
