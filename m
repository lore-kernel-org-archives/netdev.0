From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/7] tcp_cubic: enable high resolution ack time if needed
Date: Mon, 14 Mar 2011 10:52:16 -0700
Message-ID: <20110314175439.657008198@vyatta.com>
References: <20110314175211.788224699@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58248 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757055Ab1CNSCE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 14:02:04 -0400
Content-Disposition: inline; filename=tcp-cubic-rtt-cong.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a refined version of an earlier patch by Lucas Nussbaum.
Cubic needs RTT values in milliseconds. If HZ < 1000 then
the values will be too coarse.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Reported-by: Lucas Nussbaum <lucas.nussbaum@loria.fr>

--- a/net/ipv4/tcp_cubic.c	2011-03-14 08:22:42.486690594 -0700
+++ b/net/ipv4/tcp_cubic.c	2011-03-14 08:27:24.435852847 -0700
@@ -459,6 +459,10 @@ static int __init cubictcp_register(void
 	/* divide by bic_scale and by constant Srtt (100ms) */
 	do_div(cube_factor, bic_scale * 10);
 
+	/* hystart needs ms clock resolution */
+	if (hystart && HZ < 1000)
+		cubictcp.flags |= TCP_CONG_RTT_STAMP;
+
 	return tcp_register_congestion_control(&cubictcp);
 }
 


