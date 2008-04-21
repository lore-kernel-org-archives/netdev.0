From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS]: Don't initialize err variable twice.
Date: Mon, 21 Apr 2008 14:26:11 -0700 (PDT)
Message-ID: <20080421.142611.218552151.davem@davemloft.net>
References: <480C91A9.4030004@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48969
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752814AbYDUV0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 17:26:09 -0400
In-Reply-To: <480C91A9.4030004@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 21 Apr 2008 17:07:53 +0400

> The ip6_route_net_init() performs some unneeded actions.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, except that I put the initialization with the
variable declaration to save screen real-estate when
people look at this code :-)  Like so:

commit 633d424bf33dab99e77b36210fbd1b996e7823df
Author: Pavel Emelyanov <xemul@openvz.org>
Date:   Mon Apr 21 14:25:23 2008 -0700

    [NETNS]: Don't initialize err variable twice.
    
    The ip6_route_net_init() performs some unneeded actions.
    
    Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 1f42bc9..a493ad9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2614,9 +2614,8 @@ struct ctl_table *ipv6_route_sysctl_init(struct net *net)
 
 static int ip6_route_net_init(struct net *net)
 {
-	int ret = 0;
+	int ret = -ENOMEM;
 
-	ret = -ENOMEM;
 	net->ipv6.ip6_dst_ops = kmemdup(&ip6_dst_ops_template,
 					sizeof(*net->ipv6.ip6_dst_ops),
 					GFP_KERNEL);
