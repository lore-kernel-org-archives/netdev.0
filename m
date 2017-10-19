From: Matteo Croce <mcroce@redhat.com>
Subject: [PATCH v2] udp: make some messages more descriptive
Date: Thu, 19 Oct 2017 14:22:17 +0200
Message-ID: <20171019122217.11928-1-mcroce@redhat.com>
References: <20171017164812.21503-1-mcroce@redhat.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:51461 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753144AbdJSMWU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:22:20 -0400
Received: by mail-wr0-f194.google.com with SMTP id j14so8128482wre.8
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 05:22:19 -0700 (PDT)
In-Reply-To: <20171017164812.21503-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the UDP code there are two leftover error messages with very few meaning.
Replace them with a more descriptive error message as some users
reported them as "strange network error".

Signed-off-by: Matteo Croce <mcroce@redhat.com>
---
v2: added proper signed off tag

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
