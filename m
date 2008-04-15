From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.26] [TCP]: Remove superflushious skb == write_queue_tail()
 check
Date: Tue, 15 Apr 2008 12:06:47 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0804151206010.17123@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-485574052-1208250407=:17123"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49542 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbYDOJGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 05:06:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-485574052-1208250407=:17123
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Needed can only be more strict than what was checked by the
earlier common case check for non-tail skbs, thus
cwnd_len <= needed will never match in that case anyway.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 90270cb..debf235 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1057,7 +1057,7 @@ static unsigned int tcp_mss_split_point(struct sock *sk, struct sk_buff *skb,
 
 	needed = min(skb->len, window);
 
-	if (skb == tcp_write_queue_tail(sk) && cwnd_len <= needed)
+	if (cwnd_len <= needed)
 		return cwnd_len;
 
 	return needed - needed % mss_now;
-- 
1.5.2.2

---696208474-485574052-1208250407=:17123--
