From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 2/3] tcp: use read mostly for CUBIC parameters
Date: Mon, 12 Feb 2007 08:03:19 -0800
Message-ID: <20070212160336.527416565@linux-foundation.org>
References: <20070212160317.545906075@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:59953 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964829AbXBLQEi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 11:04:38 -0500
Content-Disposition: inline; filename=bic-mostly.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These module parameters should be in the read mostly area
to avoid cache pollution.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/ipv4/tcp_cubic.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

--- tcp.orig/net/ipv4/tcp_cubic.c	2007-02-12 07:28:55.000000000 -0800
+++ tcp/net/ipv4/tcp_cubic.c	2007-02-12 07:32:33.000000000 -0800
@@ -26,16 +26,16 @@
 					  */
 #define	BICTCP_HZ		10	/* BIC HZ 2^10 = 1024 */
 
-static int fast_convergence = 1;
-static int max_increment = 16;
-static int beta = 819;		/* = 819/1024 (BICTCP_BETA_SCALE) */
-static int initial_ssthresh = 100;
-static int bic_scale = 41;
-static int tcp_friendliness = 1;
-
-static u32 cube_rtt_scale;
-static u32 beta_scale;
-static u64 cube_factor;
+static int fast_convergence __read_mostly = 1;
+static int max_increment __read_mostly = 16;
+static int beta __read_mostly = 819;	/* = 819/1024 (BICTCP_BETA_SCALE) */
+static int initial_ssthresh __read_mostly = 100;
+static int bic_scale __read_mostly = 41;
+static int tcp_friendliness __read_mostly = 1;
+
+static u32 cube_rtt_scale __read_mostly;
+static u32 beta_scale __read_mostly;
+static u64 cube_factor __read_mostly;
 
 /* Note parameters that are used for precomputing scale factors are read-only */
 module_param(fast_convergence, int, 0644);

--

