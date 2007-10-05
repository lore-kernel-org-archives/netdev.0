From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH net-2.6.24] ip_gre: build fix
Date: Thu, 4 Oct 2007 17:47:38 -0700
Message-ID: <20071004174738.00c64226@freepuppy.rosehill>
References: <47055FD6.5070801@intel.com>
	<20071004.151108.82373575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42542 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755585AbXJEAsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 20:48:13 -0400
In-Reply-To: <20071004.151108.82373575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IPGRE only uses header_ops in the case of CONFIG_NET_IPGRE_BROADCAST.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/net/ipv4/ip_gre.c	2007-10-04 17:40:34.000000000 -0700
+++ b/net/ipv4/ip_gre.c	2007-10-04 17:41:20.000000000 -0700
@@ -1092,6 +1092,10 @@ static int ipgre_header(struct sk_buff *
 	return -t->hlen;
 }
 
+static const struct header_ops ipgre_header_ops = {
+	.create	= ipgre_header,
+};
+
 static int ipgre_open(struct net_device *dev)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
@@ -1131,10 +1135,6 @@ static int ipgre_close(struct net_device
 
 #endif
 
-static const struct header_ops ipgre_header_ops = {
-	.create	= ipgre_header,
-};
-
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
 	dev->uninit		= ipgre_tunnel_uninit;
