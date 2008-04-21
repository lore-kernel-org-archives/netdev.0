From: Jesper Juhl <jesper.juhl@gmail.com>
Subject: [PATCH] make use of before macro in tcp_input.c (fwd)
Date: Mon, 21 Apr 2008 22:14:28 +0200 (CEST)
Message-ID: <alpine.LNX.1.00.0804212214230.1777@dragon.funnycrock.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	trivial@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:29808 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbYDUUO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 16:14:26 -0400
Received: by fg-out-1718.google.com with SMTP id l27so1878781fgb.17
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 13:14:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David; I was about to put this in the trivial tree, but I think it should 
probably be merged via the net tree instead.

The change looks sane to me.


/Jesper Juhl


---------- Forwarded message ----------
Date: Mon, 03 Mar 2008 22:38:26 +0100
From: Arnd Hannemann <hannemann@nets.rwth-aachen.de>
To: trivial@kernel.org
Subject: [PATCH] make use of before macro in tcp_input.c

Make use of tcp before macro.

Signed-off-by: Arnd Hannemann <hannemann@nets.rwth-aachen.de>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 19c449f..e08d616 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2265,7 +2265,7 @@ static inline int tcp_packet_delayed(struct tcp_sock *tp)
 {
    return !tp->retrans_stamp ||
        (tp->rx_opt.saw_tstamp && tp->rx_opt.rcv_tsecr &&
-        (__s32)(tp->rx_opt.rcv_tsecr - tp->retrans_stamp) < 0);
+        before(tp->rx_opt.rcv_tsecr, tp->retrans_stamp));
 }

 /* Undo procedures. */
