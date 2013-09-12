From: Chris Healy <cphealy@gmail.com>
Subject: [PATCH 1/1] resubmit bridge: fix message_age_timer calculation
Date: Wed, 11 Sep 2013 21:37:47 -0700
Message-ID: <1378960667-5092-1-git-send-email-cphealy@gmail.com>
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	buytenh@wantstofly.org, Chris Healy <cphealy@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:64849 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752592Ab3ILEh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 00:37:56 -0400
Received: by mail-oa0-f41.google.com with SMTP id j6so10382288oag.28
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 21:37:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes the message_age_timer calculation to use the BPDU's max age as
opposed to the local bridge's max age.  This is in accordance with section
8.6.2.3.2 Step 2 of the 802.1D-1998 sprecification.

With the current implementation, when running with very large bridge
diameters, convergance will not always occur even if a root bridge is 
configured to have a longer max age.

Tested successfully on bridge diameters of ~200.

Signed-off-by: Chris Healy <cphealy@gmail.com>
---
 net/bridge/br_stp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 1c0a50f..f1887ba 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -209,7 +209,7 @@ static void br_record_config_information(struct net_bridge_port *p,
 	p->designated_age = jiffies - bpdu->message_age;
 
 	mod_timer(&p->message_age_timer, jiffies
-		  + (p->br->max_age - bpdu->message_age));
+		  + (bpdu->max_age - bpdu->message_age));
 }
 
 /* called under bridge lock */
-- 
1.8.1.2
