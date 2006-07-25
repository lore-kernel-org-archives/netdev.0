From: James Morris <jmorris@namei.org>
Subject: [PATCH][IPv4/IPv6] Setting 0 for unused port field. (fwd)
Date: Tue, 25 Jul 2006 10:45:51 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0607251045470.21222@d.namei>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:28302 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S932368AbWGYOpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 10:45:53 -0400
Received: from megaweapon.nightmoose.net (HELO d.namei) ([66.92.66.197])
          (envelope-sender <jmorris@namei.org>)
          by mail1.sea5.speakeasy.net (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <netdev@vger.kernel.org>; 25 Jul 2006 14:45:52 -0000
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


---------- Forwarded message ----------
Date: Tue, 25 Jul 2006 16:38:05 +0900
From: from-linux-kernel@i-love.sakura.ne.jp
To: linux-kernel@vger.kernel.org
Subject: [PATCH][IPv4/IPv6] Setting 0 for unused port field.

Hello.

The recvmsg() for raw socket seems to return random u16 value
from the kernel stack memory since port field is not initialized.
But I'm not sure this patch is correct.
Does raw socket return any information stored in port field?

---------- Start of patch ----------
diff -ur before/net/ipv4/raw.c after/net/ipv4/raw.c
--- before/net/ipv4/raw.c       2006-06-18 10:49:35.000000000 +0900
+++ after/net/ipv4/raw.c        2006-07-25 16:15:26.000000000 +0900
@@ -609,6 +609,7 @@
        if (sin) {
                sin->sin_family = AF_INET;
                sin->sin_addr.s_addr = skb->nh.iph->saddr;
+               sin->sin_port = 0;
                memset(&sin->sin_zero, 0, sizeof(sin->sin_zero));
        }
        if (inet->cmsg_flags)
diff -ur before/net/ipv6/raw.c after/net/ipv6/raw.c
--- before/net/ipv6/raw.c       2006-06-18 10:49:35.000000000 +0900
+++ after/net/ipv6/raw.c        2006-07-25 16:16:52.000000000 +0900
@@ -411,6 +411,7 @@
        /* Copy the address. */
        if (sin6) {
                sin6->sin6_family = AF_INET6;
+               sin6->sin6_port = 0;
                ipv6_addr_copy(&sin6->sin6_addr, &skb->nh.ipv6h->saddr);
                sin6->sin6_flowinfo = 0;
                sin6->sin6_scope_id = 0;
---------- End of patch ----------

Regards.
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/
