From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] net: napi fix
Date: Tue, 11 Dec 2007 21:46:34 -0800
Message-ID: <20071211214634.4dedb274@freepuppy.rosehill>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
	<20071211213939.122de1db@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Joonwoo Park" <joonwpark81@gmail.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jgarzik@pobox.com>,
	<baum@tehutinetworks.net>, <andy@greyhouse.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50835 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750820AbXLLFsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 00:48:17 -0500
In-Reply-To: <20071211213939.122de1db@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Isn't this a better fix for all drivers, rather than peppering every
driver with the special case. This is how the logic worked up until
2.6.24.


--- a/net/core/dev.c	2007-12-11 12:16:20.000000000 -0800
+++ b/net/core/dev.c	2007-12-11 21:43:39.000000000 -0800
@@ -2184,7 +2184,7 @@ static void net_rx_action(struct softirq
 
 		have = netpoll_poll_lock(n);
 
-		weight = n->weight;
+		weight = min(n->weight, budget);
 
 		/* This NAPI_STATE_SCHED test is for avoiding a race
 		 * with netpoll's poll_napi().  Only the entity which
