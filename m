From: Thomas Richter <tmricht@linux.vnet.ibm.com>
Subject: [PATCH] if_link.h add support for IEEE 802.1 Qbg ratified standard
Date: Wed, 20 Nov 2013 16:26:55 +0100
Message-ID: <1384961215-29572-1-git-send-email-tmricht@linux.vnet.ibm.com>
Cc: davem@davemloft.net, Thomas Richter <tmricht@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:54733 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752828Ab3KTP2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 10:28:25 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <tmricht@linux.vnet.ibm.com>;
	Wed, 20 Nov 2013 15:28:23 -0000
Received: from b06cxnps3075.portsmouth.uk.ibm.com (d06relay10.portsmouth.uk.ibm.com [9.149.109.195])
	by d06dlp01.portsmouth.uk.ibm.com (Postfix) with ESMTP id 9DFA217D805A
	for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 15:28:04 +0000 (GMT)
Received: from d06av09.portsmouth.uk.ibm.com (d06av09.portsmouth.uk.ibm.com [9.149.37.250])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rAKFQquD655814
	for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 15:26:52 GMT
Received: from d06av09.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av09.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rAKFR4hn012531
	for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 08:27:04 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds 2 netlink message attributes and structures to
support the IEEE 802.1 Qbg ratified standard VDP protocol.

The changes are needed to communication filter information
such as MAC address and VLAN identifier to the hardware for
virtual machine identification.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 include/uapi/linux/if_link.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b78566f..69a2db8 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -423,6 +423,8 @@ enum {
 	IFLA_PORT_HOST_UUID,		/* binary UUID */
 	IFLA_PORT_REQUEST,		/* __u8 */
 	IFLA_PORT_RESPONSE,		/* __u16, output only */
+	IFLA_PORT_VSI_TYPE22,		/* 802.1Qbg ratified standard VDP */
+	IFLA_PORT_VSI_FILTER,		/* 802.1Qbg ratified standard VDP */
 	__IFLA_PORT_MAX,
 };
 
@@ -463,6 +465,27 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
+/*
+ * Filter information data. The array size and structure members carriing
+ * valid data are determined by the members vsi_filter_num and vsi_filter_fmt
+ * structure ifla_port_vsi22 below.
+ */
+struct ifla_port_vsi_filter {
+	__u32 gpid;			/* Group Identifier*/
+	__u16 vlanid;			/* Vlan identifier and QoS bits */
+	__u8 mac[6];			/* MAC address */
+};
+
+struct ifla_port_vsi22 {	/* 802.1 Qbg Ratified standard */
+	__u8 vsi_mgrid[PORT_UUID_MAX];	/* Manager identifier */
+	__u8 vsi_uuid[PORT_UUID_MAX];	/* VSI identifier */
+	__u8 vsi_uuidfmt;		/* Format of UUID string */
+	__u8 vsi_type_id[3];
+	__u8 vsi_type_version;
+	__u8 vsi_hints;			/* Hint bits */
+	__u8 vsi_filter_fmt;		/* Filter information format */
+	__u16 vsi_filter_num;		/* # of filter data entries */
+};
 
 /* IPoIB section */
 
-- 
1.8.3.1
