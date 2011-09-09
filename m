From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [BUG?] tcp: potential bug in tcp_is_sackblock_valid()
Date: Fri, 09 Sep 2011 09:45:52 +0800
Message-ID: <4E696FD0.7060702@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	herbert@gondor.apana.org.au,
	"sfr@c
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32033 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932067Ab1IIBpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Sep 2011 21:45:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I found a check in tcp_is_sackblock_valid() is suspicious. It against
its comment and RFC. I think the correct check should be:

---
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 385c470..a5d01b1 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1124,7 +1124,7 @@ static int tcp_is_sackblock_valid(struct tcp_sock *tp, int is_dsack,
                return 0;
 
        /* ...Then it's D-SACK, and must reside below snd_una completely */
-       if (!after(end_seq, tp->snd_una))
+       if (after(end_seq, tp->snd_una))
                return 0;
 
        if (!before(start_seq, tp->undo_marker))
---

I also checked /proc/net/netstat of my laptop, found TCPDSACKIgnoredOld
field is not zero. Maybe it's caused by the bug.

Regards
Yan, Zheng
