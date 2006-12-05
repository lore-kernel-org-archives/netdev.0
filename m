From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 1/2] [IPV6] RAW: Don't release unlocked sock.
Date: Tue,  5 Dec 2006 19:03:14 +0900
Message-ID: <11653129943938-git-send-email-nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:55566 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S967638AbWLEKDt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:03:49 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When user builds IPv6 header and send it through raw socket, kernel
tries to release unlocked sock. (Kernel log shows
"BUG: bad unlock balance detected" with enabled debug option.)

The lock is held only for non-hdrincl sock in this function
then this patch fix to do nothing about lock for hdrincl one.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 net/ipv6/raw.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index d6dedc4..aa1d420 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -855,7 +855,8 @@ back_from_confirm:
 	}
 done:
 	dst_release(dst);
-	release_sock(sk);
+	if (!inet->hdrincl)
+		release_sock(sk);
 out:	
 	fl6_sock_release(flowlabel);
 	return err<0?err:len;
-- 
1.4.2

