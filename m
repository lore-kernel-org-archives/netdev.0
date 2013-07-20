From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] ip: initialize hash list
Date: Sat, 20 Jul 2013 10:26:57 -0700
Message-ID: <20130720102657.768a11ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:37619 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754470Ab3GTR1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 13:27:00 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro2so5550138pbb.13
        for <netdev@vger.kernel.org>; Sat, 20 Jul 2013 10:27:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than relying on the assumption that zero means empty on
hash list head, the code should use the initialization macro.
Same effect, but follows API and avoids future breakage if hlist
implementation changes.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/net/ipv4/ip_tunnel.c	2013-07-19 09:12:37.213529343 -0700
+++ b/net/ipv4/ip_tunnel.c	2013-07-19 09:37:00.960764421 -0700
@@ -838,10 +838,15 @@ int ip_tunnel_init_net(struct net *net,
 {
 	struct ip_tunnel_net *itn = net_generic(net, ip_tnl_net_id);
 	struct ip_tunnel_parm parms;
+	unsigned i;
 
-	itn->tunnels = kzalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head), GFP_KERNEL);
+	itn->tunnels = kmalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head),
+			       GFP_KERNEL);
 	if (!itn->tunnels)
 		return -ENOMEM;
+
+	for (i = 0; i < IP_TNL_HASH_SIZE; i++)
+		INIT_HLIST_HEAD(&itn->tunnels[i]);
 
 	if (!ops) {
 		itn->fb_tunnel_dev = NULL;
