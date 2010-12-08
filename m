From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH] ipv6: fix nl group when advertising a new link
Date: Wed, 08 Dec 2010 10:38:31 +0100
Message-ID: <4CFF5217.6010601@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070500030805060205010006"
Cc: netdev <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:54984 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574Ab0LHJif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 04:38:35 -0500
Received: by wwa36 with SMTP id 36so948936wwa.1
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 01:38:34 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070500030805060205010006
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

please consider the following patch.

Regards,
Nicolas

--------------070500030805060205010006
Content-Type: text/x-diff;
 name="0001-ipv6-fix-nl-group-when-advertising-a-new-link.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-ipv6-fix-nl-group-when-advertising-a-new-link.patch"

>From d2ed52e7fcb639470c89045f7b0ce31eb681896a Mon Sep 17 00:00:00 2001
From: Wang Xuefu <xuefu.wang@6wind.com>
Date: Wed, 8 Dec 2010 10:24:48 +0100
Subject: [PATCH] ipv6: fix nl group when advertising a new link

New idev are advertised with NL group RTNLGRP_IPV6_IFADDR, but
should use RTNLGRP_IPV6_IFINFO.
Bug was introduced by commit 8d7a76c9.

Signed-off-by: Wang Xuefu <xuefu.wang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ab70a3f..0f695a1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4021,11 +4021,11 @@ void inet6_ifinfo_notify(int event, struct inet6_dev *idev)
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_IFADDR, NULL, GFP_ATOMIC);
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_IFINFO, NULL, GFP_ATOMIC);
 	return;
 errout:
 	if (err < 0)
-		rtnl_set_sk_err(net, RTNLGRP_IPV6_IFADDR, err);
+		rtnl_set_sk_err(net, RTNLGRP_IPV6_IFINFO, err);
 }
 
 static inline size_t inet6_prefix_nlmsg_size(void)
-- 
1.5.6.5


--------------070500030805060205010006--
