From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: [PATCH net-next] tcp: cdg: use div_u64()
Date: Fri, 12 Jun 2015 17:24:03 +0200
Message-ID: <1434122643-16330-1-git-send-email-kennetkl@ifi.uio.no>
Cc: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:50956 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752681AbbFLPYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jun 2015 11:24:15 -0400
Received: from mail-mx3.uio.no ([129.240.10.44])
	by mail-out4.uio.no with esmtp (Exim 4.80.1)
	(envelope-from <kennetkl@ifi.uio.no>)
	id 1Z3QoX-000584-NS
	for netdev@vger.kernel.org; Fri, 12 Jun 2015 17:24:13 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes cross-compile to mips.

Signed-off-by: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
---
Fixes build error for mips-allyesconfig:

  net/built-in.o: In function `tcp_cdg_cong_avoid':
>> tcp_cdg.c:(.text+0x217774): undefined reference to `__udivdi3'

https://lists.01.org/pipermail/kbuild-all/2015-June/010142.html
---
 net/ipv4/tcp_cdg.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp_cdg.c
index a52ce2d..8c6fd3d 100644
--- a/net/ipv4/tcp_cdg.c
+++ b/net/ipv4/tcp_cdg.c
@@ -145,7 +145,7 @@ static void tcp_cdg_hystart_update(struct sock *sk)
 		return;
 
 	if (hystart_detect & HYSTART_ACK_TRAIN) {
-		u32 now_us = local_clock() / NSEC_PER_USEC;
+		u32 now_us = div_u64(local_clock(), NSEC_PER_USEC);
 
 		if (ca->last_ack == 0 || !tcp_is_cwnd_limited(sk)) {
 			ca->last_ack = now_us;
-- 
2.1.0
