From: roopa@cumulusnetworks.com
Subject: [PATCH 1/3] netdev: introduce new NETIF_F_HW_SWITCH_OFFLOAD feature flag for switch device offloads
Date: Thu,  4 Dec 2014 18:26:39 -0800
Message-ID: <1417746401-8140-2-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, linville@tuxdriver.com,
	nhorman@tuxdriver.com, nicolas.dichtel@6wind.com,
	vyasevic@redhat.com, f.fainelli@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38152 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932378AbaLEC0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 21:26:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This is a generic high level feature flag for all switch asic features today.

switch drivers set this flag on switch ports. Logical devices like
bridge, bonds, vxlans can inherit this flag from their slaves/ports.

I had to use SWITCH in the name to avoid ambiguity with other feature
flags. But, since i have been harping about not calling it 'switch',
I am welcome to any suggestions :)

An alternative to using a feature flag is to use a IFF_HW_OFFLOAD
in net_device_flags.
---
 include/linux/netdev_features.h |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 8e30685..68db1de 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -66,6 +66,7 @@ enum {
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
+	NETIF_F_HW_SWITCH_OFFLOAD_BIT,  /* HW switch offload */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -124,6 +125,7 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
+#define NETIF_F_HW_SWITCH_OFFLOAD	__NETIF_F(HW_SWITCH_OFFLOAD)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
-- 
1.7.10.4
