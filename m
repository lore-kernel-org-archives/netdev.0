From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] net: prevent setting ttl=0 via IP_TTL
Date: Tue,  8 Jan 2013 15:17:00 +0800
Message-ID: <1357629420-29725-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: nitin padalia <padalia.nitin@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f171.google.com ([209.85.216.171]:49062 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab3AHHRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 02:17:14 -0500
Received: by mail-qc0-f171.google.com with SMTP id d1so130748qca.30
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 23:17:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

A regression is introduced by the following commit:

	commit 4d52cfbef6266092d535237ba5a4b981458ab171
	Author: Eric Dumazet <eric.dumazet@gmail.com>
	Date:   Tue Jun 2 00:42:16 2009 -0700

	    net: ipv4/ip_sockglue.c cleanups
	    
	    Pure cleanups

but it is not a pure cleanup...

	-               if (val != -1 && (val < 1 || val>255))
	+               if (val != -1 && (val < 0 || val > 255))

Since there is no reason provided to allow ttl=0, change it back.

Reported-by: nitin padalia <padalia.nitin@gmail.com>
Cc: nitin padalia <padalia.nitin@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 3c9d208..d9c4f11 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -590,7 +590,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	case IP_TTL:
 		if (optlen < 1)
 			goto e_inval;
-		if (val != -1 && (val < 0 || val > 255))
+		if (val != -1 && (val < 1 || val > 255))
 			goto e_inval;
 		inet->uc_ttl = val;
 		break;
