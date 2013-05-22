From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv6: use ipv6_addr_scope() helper
Date: Wed, 22 May 2013 23:52:22 +0800
Message-ID: <1369237942-24533-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:45410 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752633Ab3EVPwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 11:52:45 -0400
Received: by mail-pa0-f45.google.com with SMTP id lj1so1931569pab.32
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 08:52:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK could be replaced
by ipv6_addr_scope(), which is slightly faster.

Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d684d23..bceaaa7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1126,8 +1126,7 @@ retry:
 
 	ift = !max_addresses ||
 	      ipv6_count_addresses(idev) < max_addresses ?
-		ipv6_add_addr(idev, &addr, tmp_plen,
-			      ipv6_addr_type(&addr)&IPV6_ADDR_SCOPE_MASK,
+		ipv6_add_addr(idev, &addr, tmp_plen, ipv6_addr_scope(&addr),
 			      addr_flags) : NULL;
 	if (IS_ERR_OR_NULL(ift)) {
 		in6_ifa_put(ifp);
