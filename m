From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/42] appletalk: convert aarp to net_device_ops
Date: Tue, 06 Jan 2009 16:33:17 -0800
Message-ID: <20090107003345.513599743@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, acme@ghostprotcols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58975 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754376AbZAGAw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:52:59 -0500
Content-Disposition: inline; filename=atalk-aarp.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/appletalk/aarp.c	2009-01-03 20:42:09.251514959 -0800
+++ b/net/appletalk/aarp.c	2009-01-03 20:44:24.182763615 -0800
@@ -443,13 +443,14 @@ static void aarp_send_probe_phase1(struc
 {
 	struct ifreq atreq;
 	struct sockaddr_at *sa = (struct sockaddr_at *)&atreq.ifr_addr;
+	const struct net_device_ops *ops = iface->dev->netdev_ops;
 
 	sa->sat_addr.s_node = iface->address.s_node;
 	sa->sat_addr.s_net = ntohs(iface->address.s_net);
 
 	/* We pass the Net:Node to the drivers/cards by a Device ioctl. */
-	if (!(iface->dev->do_ioctl(iface->dev, &atreq, SIOCSIFADDR))) {
-		(void)iface->dev->do_ioctl(iface->dev, &atreq, SIOCGIFADDR);
+	if (!(ops->ndo_do_ioctl(iface->dev, &atreq, SIOCSIFADDR))) {
+		ops->ndo_do_ioctl(iface->dev, &atreq, SIOCGIFADDR);
 		if (iface->address.s_net != htons(sa->sat_addr.s_net) ||
 		    iface->address.s_node != sa->sat_addr.s_node)
 			iface->status |= ATIF_PROBE_FAIL;

-- 

