From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 02/10] tcp: move tcp_simple_retransmit to tcp_input
Date: Tue, 25 Nov 2008 16:02:22 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811251534360.31282@wrl-59.cs.helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20081124.211039.01283732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-742552772-1227620276=:31282"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45533 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745AbYKYOCX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 09:02:23 -0500
In-Reply-To: <20081124.211039.01283732.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0811251601160.31282@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-742552772-1227620276=:31282
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0811251601161.31282@wrl-59.cs.helsinki.fi>

On Mon, 24 Nov 2008, David Miller wrote:

> From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Mon, 24 Nov 2008 16:21:59 +0200
> 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> I applied this with a minor modification.
> 
> tcp_skb_mark_lost_uncond_verify() can now be marked static, so I made
> that change.
> 
> BTW, that would have generated a sparse warning had you sparse on
> your changes :)

I did use sparse, that is, when I finally remembered :-) but the results 
didn't made to the series I sent but I followed up with v2 of this 
particular patch. ...I also realized that another function can be made 
static as a result of this move, patch below.

-- 
 i.


--
[PATCH] tcp: tcp_limit_reno_sacked can become static

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h    |    2 --
 net/ipv4/tcp_input.c |    2 +-
 2 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2653924..e8ae90a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -761,8 +761,6 @@ static inline unsigned int tcp_packets_in_flight(const struct tcp_sock *tp)
 	return tp->packets_out - tcp_left_out(tp) + tp->retrans_out;
 }
 
-extern int tcp_limit_reno_sacked(struct tcp_sock *tp);
-
 /* If cwnd > ssthresh, we may raise ssthresh to be half-way to cwnd.
  * The exception is rate halving phase, when cwnd is decreasing towards
  * ssthresh.
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9f8a80b..d67b6e9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1940,7 +1940,7 @@ out:
 /* Limits sacked_out so that sum with lost_out isn't ever larger than
  * packets_out. Returns zero if sacked_out adjustement wasn't necessary.
  */
-int tcp_limit_reno_sacked(struct tcp_sock *tp)
+static int tcp_limit_reno_sacked(struct tcp_sock *tp)
 {
 	u32 holes;
 
-- 
1.5.2.2

---696208474-742552772-1227620276=:31282--
