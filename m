From: Ben Greear <greearb@candelatech.com>
Subject: [net-next] net:  More verbose message for too-many-orphans.
Date: Mon,  9 Aug 2010 12:00:02 -0700
Message-ID: <1281380402-14608-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:51652 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362Ab0HITAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 15:00:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original message doesn't give much clue as to what
is actually going wrong or how to fix it.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 808bb92... 96a7ec2... M	net/ipv4/tcp_timer.c
 net/ipv4/tcp_timer.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 808bb92..96a7ec2 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -79,7 +79,11 @@ static int tcp_out_of_resources(struct sock *sk, int do_reset)
 
 	if (tcp_too_many_orphans(sk, orphans)) {
 		if (net_ratelimit())
-			printk(KERN_INFO "Out of socket memory\n");
+			printk(KERN_INFO "Out of socket memory, orphans: %d/%d"
+			       " tcp_memory_allocated: %d/%d\n",
+			       orphans, sysctl_tcp_max_orphans,
+			       atomic_read(&tcp_memory_allocated),
+			       sysctl_tcp_mem[2]);
 
 		/* Catch exceptional cases, when connection requires reset.
 		 *      1. Last segment was sent recently. */
-- 
1.6.2.5

