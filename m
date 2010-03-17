From: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Subject: [PATCH] tcp: Fix tcp_mark_head_lost() with packets == 0
Date: Wed, 17 Mar 2010 13:16:29 +0100
Message-ID: <1268828189-22182-1-git-send-email-lennart.schulte@nets.rwth-aachen.de>
Content-Transfer-Encoding: 7BIT
Cc: ilpo.jarvinen@helsinki.fi,
	Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:62202 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754710Ab0CQMPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 08:15:47 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KZF0028QE29CVB0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 17 Mar 2010 13:15:45 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A packet is marked as lost in case packets == 0, although nothing should be done.
This results in a too early retransmitted packet during recovery in some cases.
This small patch fixes this issue by returning immediately.

Signed-off-by: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
---
 net/ipv4/tcp_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 788851c..c096a42 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2511,6 +2511,9 @@ static void tcp_mark_head_lost(struct sock *sk, int packets)
 	int err;
 	unsigned int mss;
 
+	if (packets == 0)
+		return;
+
 	WARN_ON(packets > tp->packets_out);
 	if (tp->lost_skb_hint) {
 		skb = tp->lost_skb_hint;
-- 
1.6.4.1

