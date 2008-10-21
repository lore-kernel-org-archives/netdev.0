From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: should use number of sack blocks instead of -1
Date: Tue, 21 Oct 2008 11:58:05 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810211153300.7072@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-765704183-1224579485=:7072"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59955 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbYJUI6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 04:58:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-765704183-1224579485=:7072
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


While looking for the recent "sack issue" I also read all eff_sacks
usage that was played around by some relevant commit. I found
out that there's another thing that is asking for a fix (unrelated
to the "sack issue" though).

This feature has probably very little significance in practice.
Opposite direction timeout with bidirectional tcp comes to me as
the most likely scenario though there might be other cases as
well related to non-data segments we send (e.g., response to the
opposite direction segment). Also some ACK losses or option space
wasted for other purposes is necessary to prevent the earlier
SACK feedback getting to the sender.

This is not too critical fix, so you might want to delay this to
net-next if you're afraid that Linus will get you because of
this...

I suppose we might not need eff_sacks at all but I'll leave
figuring that out to net-next :-).

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 990a584..de54f02 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -432,7 +432,7 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 
 		if (tp->rx_opt.dsack) {
 			tp->rx_opt.dsack = 0;
-			tp->rx_opt.eff_sacks--;
+			tp->rx_opt.eff_sacks = tp->rx_opt.num_sacks;
 		}
 	}
 }
-- 
1.5.2.2

---696208474-765704183-1224579485=:7072--
