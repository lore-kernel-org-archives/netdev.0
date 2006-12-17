From: "Leigh Brown" <leigh@solinno.co.uk>
Subject: [TCP]: Trivial fix to message in tcp_v4_inbound_md5_hash
Date: Sun, 17 Dec 2006 18:04:15 -0000 (GMT)
Message-ID: <42087.81.105.127.245.1166378655.squirrel@www.solinno.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mwuml021.modern-world.net ([193.110.88.84]:4466 "EHLO
	mwuml021.modern-world.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932202AbWLQSEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 13:04:16 -0500
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The message logged in tcp_v4_inbound_md5_hash when the hash was expected
but not found was reversed.

Signed-off-by: Leigh Brown <leigh@solinno.co.uk>

diff -uprN a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	2006-12-17 10:05:54.000000000 +0000
+++ b/net/ipv4/tcp_ipv4.c	2006-12-17 17:54:27.000000000 +0000
@@ -1187,7 +1187,7 @@ done_opts:
 		return 0;

 	if (hash_expected && !hash_location) {
-		LIMIT_NETDEBUG(KERN_INFO "MD5 Hash NOT expected but found "
+		LIMIT_NETDEBUG(KERN_INFO "MD5 Hash expected but NOT found "
 			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
 			       NIPQUAD(iph->saddr), ntohs(th->source),
 			       NIPQUAD(iph->daddr), ntohs(th->dest));


