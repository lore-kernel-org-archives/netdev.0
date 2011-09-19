From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] tcp: fix validation of D-SACK
Date: Mon, 19 Sep 2011 10:05:31 +0800
Message-ID: <4E76A36B.4060109@intel.com>
References: <4E696FD0.7060702@intel.com> <1316374544.31335.16.camel@edumazet-laptop> <20110918.210725.2061666096968958448.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24636 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752178Ab1ISCFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Sep 2011 22:05:33 -0400
In-Reply-To: <20110918.210725.2061666096968958448.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

D-SACK is allowed to reside below snd_una. But the corresponding check
in tcp_is_sackblock_valid() is the exact opposite. It looks like a typo.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ea0d218..21fab3e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1124,7 +1124,7 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
 		return 0;
 
 	/* ...Then it's D-SACK, and must reside below snd_una completely */
-	if (!after(end_seq, tp->snd_una))
+	if (after(end_seq, tp->snd_una))
 		return 0;
 
 	if (!before(start_seq, tp->undo_marker))
