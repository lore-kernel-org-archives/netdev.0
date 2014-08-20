From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] ipconfig: Use time_before
Date: Wed, 20 Aug 2014 23:14:10 +0530
Message-ID: <20140820174410.GA4225@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:43666 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbaHTRoW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 13:44:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions time_before, time_before_eq, time_after, and time_after_eq
are more robust for comparing jiffies against other values.

A simplified version of the Coccinelle semantic patch making this change
is as follows:

@change@
expression E1,E2;
@@
- jiffies - E1 < E2
+ time_before(jiffies, E1+E2)

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 net/ipv4/ipconfig.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 5bbef4f..648fa14 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -262,7 +262,8 @@ static int __init ic_open_devs(void)
 	/* wait for a carrier on at least one device */
 	start = jiffies;
 	next_msg = start + msecs_to_jiffies(CONF_CARRIER_TIMEOUT/12);
-	while (jiffies - start < msecs_to_jiffies(CONF_CARRIER_TIMEOUT)) {
+	while (time_before(jiffies, start +
+			   msecs_to_jiffies(CONF_CARRIER_TIMEOUT))) {
 		int wait, elapsed;
 
 		for_each_netdev(&init_net, dev)
-- 
1.9.1
