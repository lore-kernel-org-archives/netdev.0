From: greearb@candelatech.com
Subject: [PATCH] vlan:  Support sending custom Ethernet CRC.
Date: Mon,  5 Mar 2012 18:05:58 -0800
Message-ID: <1330999558-14270-1-git-send-email-greearb@candelatech.com>
Cc: kaber@trash.net, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:39711 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758204Ab2CFCGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 21:06:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

If the underlying device supports sending custom Ethernet CRC,
then enable that feature in the VLANs as well.

NOTE:  You will probably have to disable any
VLAN hardware assist on the underlying device to get
this to properly send packets with this feature enabled.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 9988d4a... 6aeb0a3... M	net/8021q/vlan_dev.c
 net/8021q/vlan_dev.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9988d4a..6aeb0a3 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -543,6 +543,9 @@ static int vlan_dev_init(struct net_device *dev)
 	dev->features |= real_dev->vlan_features | NETIF_F_LLTX;
 	dev->gso_max_size = real_dev->gso_max_size;
 
+	if (netif_supports_nofcs(real_dev))
+		dev->priv_flags |= IFF_SUPP_NOFCS;
+
 	/* ipv6 shared card related stuff */
 	dev->dev_id = real_dev->dev_id;
 
-- 
1.7.3.4
