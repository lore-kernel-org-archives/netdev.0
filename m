From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 1/5] netdev: introduce new NETIF_F_HW_NETFUNC_OFFLOAD feature flag for switch device offloads
Date: Thu, 22 Jan 2015 20:33:22 -0800
Message-ID: <1421987606-10884-2-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com,
	Roopa Prabhu <roopa@cumulusnetworks.com>
To: jiri@resnulli.us, sfeldma@gmail.com, jhs@mojatatu.com,
	bcrl@kvack.org, tgraf@suug.ch, john.fastabend@gmail.com,
	stephen@networkplumber.org, vyasevic@redhat.com,
	ronen.arad@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:57186 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbbAWEdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 23:33:33 -0500
Received: by mail-pa0-f51.google.com with SMTP id fb1so6059291pad.10
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 20:33:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This is a high level feature flag for all switch asic offloads

switch drivers set this flag on switch ports. Logical devices like
bridge, bonds, vxlans can inherit this flag from their slaves/ports.

The patch also adds the flag to NETIF_F_ONE_FOR_ALL, so that it gets
propagated to the upperdevices (bridges and bonds).

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 include/linux/netdev_features.h |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index 8e30685..784a461 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -66,6 +66,7 @@ enum {
 	NETIF_F_HW_VLAN_STAG_FILTER_BIT,/* Receive filtering on VLAN STAGs */
 	NETIF_F_HW_L2FW_DOFFLOAD_BIT,	/* Allow L2 Forwarding in Hardware */
 	NETIF_F_BUSY_POLL_BIT,		/* Busy poll */
+	NETIF_F_HW_NETFUNC_OFFLOAD_BIT,  /* HW switch offload */
 
 	/*
 	 * Add your fresh new feature above and remember to update
@@ -124,6 +125,7 @@ enum {
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
 #define NETIF_F_HW_L2FW_DOFFLOAD	__NETIF_F(HW_L2FW_DOFFLOAD)
 #define NETIF_F_BUSY_POLL	__NETIF_F(BUSY_POLL)
+#define NETIF_F_HW_NETFUNC_OFFLOAD	__NETIF_F(HW_NETFUNC_OFFLOAD)
 
 /* Features valid for ethtool to change */
 /* = all defined minus driver/device-class-related */
@@ -159,7 +161,9 @@ enum {
  */
 #define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
-				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED)
+				 NETIF_F_FRAGLIST | NETIF_F_VLAN_CHALLENGED | \
+				 NETIF_F_HW_NETFUNC_OFFLOAD)
+
 /*
  * If one device doesn't support one of these features, then disable it
  * for all in netdev_increment_features.
-- 
1.7.10.4
