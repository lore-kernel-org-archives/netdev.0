From: Daniele Di Proietto <daniele.di.proietto@gmail.com>
Subject: [PATCH net-next] openvswitch: Do not use private netdev_vport fields
Date: Tue,  6 Jan 2015 21:51:21 +0100
Message-ID: <1420577481-20238-1-git-send-email-daniele.di.proietto@gmail.com>
Cc: pshelar@nicira.com,
	Daniele Di Proietto <daniele.di.proietto@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:53534 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753811AbbAFUvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2015 15:51:54 -0500
Received: by mail-wi0-f171.google.com with SMTP id bs8so6161286wib.16
        for <netdev@vger.kernel.org>; Tue, 06 Jan 2015 12:51:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This commit introduces netdev_vport_index() to prevent datapath.c from directly accessing the 'dev' member of 'struct netdev_vport'.
This fix is needed to allow possible alternative netdev_vport implementations.

Signed-off-by: Daniele Di Proietto <daniele.di.proietto@gmail.com>
---
 net/openvswitch/datapath.c     | 2 +-
 net/openvswitch/vport-netdev.h | 6 ++++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 4e9a5f0..d632535 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -186,7 +186,7 @@ static int get_dpifindex(const struct datapath *dp)
 
 	local = ovs_vport_rcu(dp, OVSP_LOCAL);
 	if (local)
-		ifindex = netdev_vport_priv(local)->dev->ifindex;
+		ifindex = netdev_vport_index(local);
 	else
 		ifindex = 0;
 
diff --git a/net/openvswitch/vport-netdev.h b/net/openvswitch/vport-netdev.h
index 6f7038e..ecfcbd5 100644
--- a/net/openvswitch/vport-netdev.h
+++ b/net/openvswitch/vport-netdev.h
@@ -38,6 +38,12 @@ netdev_vport_priv(const struct vport *vport)
 	return vport_priv(vport);
 }
 
+static inline int
+netdev_vport_index(const struct vport *vport)
+{
+	return netdev_vport_priv(vport)->dev->ifindex;
+}
+
 const char *ovs_netdev_get_name(const struct vport *);
 void ovs_netdev_detach_dev(struct vport *);
 
-- 
2.1.4
