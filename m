From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 8/11 net-2.6.26] [INET]: uc_ttl assignment in inet_csk_ctl_sock_create is extra.
Date: Fri, 28 Mar 2008 12:08:55 +0300
Message-ID: <1206695338-5947-8-git-send-email-den@openvz.org>
References: <1206695071.3271.8.camel@iris.sw.ru>
Cc: netdev@vger.kernel.org, containers@lists.osdl.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:25747 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754065AbYC1JIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 05:08:31 -0400
In-Reply-To: <1206695071.3271.8.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

uc_ttl is initialized in inet(6)_create and never changed except exact
setsockopt ioctl. Remove it.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/inet_connection_sock.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 2cb3552..bfa6274 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -660,7 +660,6 @@ int inet_csk_ctl_sock_create(struct sock **sk, unsigned short family,
 	if (rc == 0) {
 		*sk = socket->sk;
 		(*sk)->sk_allocation = GFP_ATOMIC;
-		inet_sk(*sk)->uc_ttl = -1;
 		/*
 		 * Unhash it so that IP input processing does not even see it,
 		 * we do not wish this socket to see incoming packets.
-- 
1.5.3.rc5

