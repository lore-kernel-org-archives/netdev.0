From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/6] tcp_cubic: enable high resolution ack time if needed
Date: Thu, 10 Mar 2011 08:51:28 -0800
Message-ID: <20110310165329.281291096@vyatta.com>
References: <20110310165119.224046957@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sangtae.ha@gmail.com, rhee@ncsu.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:45018 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753358Ab1CJQ4W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2011 11:56:22 -0500
Content-Disposition: inline; filename=tcp-cubic-rtt-cong.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a refined version of an earlier patch by Lucas Nussbaum.
Cubic needs RTT values in milliseconds. If HZ < 1000 then
the values will be too coarse.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/tcp_cubic.c	2011-03-10 08:35:59.968882888 -0800
+++ b/net/ipv4/tcp_cubic.c	2011-03-10 08:36:10.241016524 -0800
@@ -459,6 +459,10 @@ static int __init cubictcp_register(void
 	/* divide by bic_scale and by constant Srtt (100ms) */
 	do_div(cube_factor, bic_scale * 10);
 
+	/* hystart needs ms clock resolution */
+	if (hystart && HZ < 1000)
+		cubictcp.flags |= TCP_CONG_RTT_STAMP;
+
 	return tcp_register_congestion_control(&cubictcp);
 }
 


