From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-next-2.6 [PATCH 1/1] tcp: add missing initial window (RFC
	3390) for tcp_output
Date: Wed, 1 Sep 2010 07:34:43 +0200
Message-ID: <20100901053443.GB5379@gerrit.erg.abdn.ac.uk>
References: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-2-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-3-git-send-email-gerrit@erg.abdn.ac.uk> <1283145794-5615-4-git-send-email-gerrit@erg.abdn.ac.uk> <alpine.DEB.2.00.1008301557590.31318@wel-95.cs.helsinki.fi> <20100901052355.GA5379@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:56593 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751132Ab0IAFe6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 01:34:58 -0400
Content-Disposition: inline
In-Reply-To: <20100901052355.GA5379@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please can you have a look, I have checked it, appears to be correct
and compiles cleanly. Thanks again to Ilpo.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
tcp: update also tcp_output with regard to RFC 5681

Thanks to Ilpo Jarvinen, his updates also the initial window
setting for tcp_output with regard to RFC 5681.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/ipv4/tcp_output.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -225,15 +225,11 @@ void tcp_select_initial_window(int __spa
 	}
 
 	/* Set initial window to value enough for senders,
-	 * following RFC2414. Senders, not following this RFC,
-	 * will be satisfied with 2.
+	 * following RFC5681 (which updates RFC3390).
 	 */
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
