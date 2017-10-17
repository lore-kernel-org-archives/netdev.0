From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH] udp: make some messages more descriptive
Date: Tue, 17 Oct 2017 18:48:12 +0200
Message-ID: <20171017164812.21503-1-mcroce@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:46222 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933144AbdJQQsP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 12:48:15 -0400
Received: by mail-wr0-f181.google.com with SMTP id l1so2376370wrc.3
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 09:48:14 -0700 (PDT)
Received: from mcroce.mxp.redhat.com (nat-pool-mxp-t.redhat.com. [149.6.153.186])
        by smtp.gmail.com with ESMTPSA id w126sm9398475wme.25.2017.10.17.09.48.13
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 17 Oct 2017 09:48:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the UDP code there are two leftover error messages with very few meaning.
Replace them with a more descriptive error message as some users
reported them as "strange network error".
---
 net/ipv4/udp.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e45177ceb0ee..806b298a3bdd 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1061,7 +1061,7 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		/* ... which is an evident application bug. --ANK */
 		release_sock(sk);
 
-		net_dbg_ratelimited("cork app bug 2\n");
+		net_dbg_ratelimited("socket already corked\n");
 		err = -EINVAL;
 		goto out;
 	}
@@ -1144,7 +1144,7 @@ int udp_sendpage(struct sock *sk, struct page *page, int offset,
 	if (unlikely(!up->pending)) {
 		release_sock(sk);
 
-		net_dbg_ratelimited("udp cork app bug 3\n");
+		net_dbg_ratelimited("cork failed\n");
 		return -EINVAL;
 	}
 
-- 
2.13.6
