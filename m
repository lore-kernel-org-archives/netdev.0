From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: net-next-2.6 [PATCH 1/1] tcp: add missing initial window (RFC
	3390) for tcp_output
Date: Wed, 1 Sep 2010 12:28:35 +0200
Message-ID: <20100901102835.GA5686@gerrit.erg.abdn.ac.uk>
References: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-2-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-3-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-4-git-send-email-gerrit@erg.abdn.ac.uk> <alpine.DEB.2.00.1008301557590.31318@wel-95.cs.helsinki.fi> <20100901052355.GA5379@gerrit.erg.abdn.ac.uk> <20100901053443.GB5379@gerrit.erg.abdn.ac.uk> <428BF15F-19DC-459A-B54A-EC273ECF537E@comsys.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:63122 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752155Ab0IAK2q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 06:28:46 -0400
Content-Disposition: inline
In-Reply-To: <428BF15F-19DC-459A-B54A-EC273ECF537E@comsys.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Addressing comments from Alexander, removing comment.

>>>>>>>>>>>>>>>>>>>>>>> Patch v2 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
tcp: update also tcp_output with regard to RFC 5681

Thanks to Ilpo Jarvinen, this updates also the initial window
setting for tcp_output with regard to RFC 5681.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv4/tcp_output.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -224,16 +224,10 @@ void tcp_select_initial_window(int __spa
 		}
 	}
 
-	/* Set initial window to value enough for senders,
-	 * following RFC2414. Senders, not following this RFC,
-	 * will be satisfied with 2.
-	 */
+	/* Set initial window to value enough for senders, following RFC5681. */
 	if (mss > (1 << *rcv_wscale)) {
-		int init_cwnd = 4;
-		if (mss > 1460 * 3)
-			init_cwnd = 2;
-		else if (mss > 1460)
-			init_cwnd = 3;
+		int init_cwnd = rfc3390_bytes_to_packets(mss);
+
 		/* when initializing use the value from init_rcv_wnd
 		 * rather than the default from above
 		 */
