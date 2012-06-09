From: Jonathan Nieder <jrnieder@gmail.com>
Subject: [2.6.32.y] Re: [PATCH] appletalk:: da.s_net not copied but assigned
 to itself in aarp_rcv()
Date: Sat, 9 Jun 2012 02:07:20 -0500
Message-ID: <20120609070719.GA24246@burratino>
References: <4B4F7F4B.8000302@gmail.com>
 <20100114210001.GE20221@ghostprotocols.net>
 <20100115.014943.39860500.davem@davemloft.net>
 <20120302193416.GA22055@burratino>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, roel.kluin@gmail.com,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mason Loring Bliss <mason@blisses.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:43394 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922Ab2FIHHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2012 03:07:30 -0400
Content-Disposition: inline
In-Reply-To: <20120302193416.GA22055@burratino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <roel.kluin@gmail.com>
Date: Fri, 15 Jan 2010 01:49:28 -0800
Subject: appletalk:: da.s_net not copied but assigned to itself in aarp_rcv()

commit 2a04cd4c7d41c4549764734dcf5a883d304e3229 upstream.

da.s_net was not copied but assigned to itself.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Jonathan Nieder <jrnieder@gmail.com>
---
(culling cc list)
Hi Willy,

Please consider

  2a04cd4c7d41 appletalk:: da.s_net not copied bu assigned to itself
               in aarp_rcv()

for application to the 2.6.32.y tree.

Without this patch, Mason (cc-ed) is not able to use appletalk[1]:

| With Linux 2.6.32 as supplied with Debian Squeeze, Netatalk is unable
| to thrive. Connections made to afpd will open, but attempting to transfer
| files will take a very long time and/or eventually time out.
|
| I've noted this with both Netatalk as supplied with Squeeze and with
| Netatalk 2.2.1 built from the Wheezy source package, which I evidently
| need for AFP 3 support.

Though this bug is very old.  Presumably no one noticed because no one
was using proxy-AARP.

The patch was merged upstream in 2.6.33-rc6.  Mason tested it against
Debian's 2.6.32.y-based kernel in March and found it to work, and the
patch has been part of Debian's stable kernel since then without
triggering any complaints.

Hope that helps,
Jonathan

[1] http://bugs.debian.org/660902

 net/appletalk/aarp.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
index 9d4adfd22757..f2b3b56aa779 100644
--- a/net/appletalk/aarp.c
+++ b/net/appletalk/aarp.c
@@ -819,7 +819,7 @@ static int aarp_rcv(struct sk_buff *skb, struct net_device *dev,
 				ma = &ifa->address;
 			else { /* We need to make a copy of the entry. */
 				da.s_node = sa.s_node;
-				da.s_net = da.s_net;
+				da.s_net = sa.s_net;
 				ma = &da;
 			}
 
-- 
1.7.10
