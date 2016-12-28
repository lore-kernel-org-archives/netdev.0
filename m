From: Dave Jones <davej@codemonkey.org.uk>
Subject: ipv6: remove unnecessary inet6_sk check
Date: Wed, 28 Dec 2016 11:53:18 -0500
Message-ID: <20161228165318.5afrtlbulsgymc4c@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:43096 "EHLO
        arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750966AbcL1QxV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2016 11:53:21 -0500
Received: from c-65-96-119-39.hsd1.ma.comcast.net ([65.96.119.39] helo=wopr.kernelslacker.org)
        by arcturus.aphlor.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
        (Exim 4.88)
        (envelope-from <davej@codemonkey.org.uk>)
        id 1cMHTc-0001Jn-5X
        for netdev@vger.kernel.org; Wed, 28 Dec 2016 16:53:20 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

np is already assigned in the variable declaration of ping_v6_sendmsg.
At this point, we have already dereferenced np several times, so the
NULL check is also redundant.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index e1f8b34d7a2e..9b522fa90e6d 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -126,12 +126,6 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 		return PTR_ERR(dst);
 	rt = (struct rt6_info *) dst;
 
-	np = inet6_sk(sk);
-	if (!np) {
-		err = -EBADF;
-		goto dst_err_out;
-	}
-
 	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
 		fl6.flowi6_oif = np->mcast_oif;
 	else if (!fl6.flowi6_oif)
@@ -166,7 +160,6 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	}
 	release_sock(sk);
 
-dst_err_out:
 	dst_release(dst);
 
 	if (err)
