From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH v3 2/5] if_link: Add SR-IOV configuration methods
Date: Wed, 10 Feb 2010 03:43:24 -0800
Message-ID: <20100210114322.14483.35528.stgit@localhost.localdomain>
References: <20100210114303.14483.71368.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:55149 "EHLO
	qmta01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753644Ab0BJLno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 06:43:44 -0500
In-Reply-To: <20100210114303.14483.71368.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Add SR-IOV VF management methods to IFLA_LINKINFO. This allows userspace to
use rtnetlink to configure VF network devices.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/if_link.h |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 6674791..c9bf92c 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -78,6 +78,11 @@ enum {
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
 	IFLA_IFALIAS,
+	IFLA_NUM_VF,		/* Number of VFs if device is SR-IOV PF */
+	IFLA_VF_MAC,		/* Hardware queue specific attributes */
+	IFLA_VF_VLAN,
+	IFLA_VF_TX_RATE,	/* TX Bandwidth Allocation */
+	IFLA_VFINFO,
 	__IFLA_MAX
 };
 
@@ -196,4 +201,29 @@ enum macvlan_mode {
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
 };
 
+/* SR-IOV virtual function managment section */
+
+struct ifla_vf_mac {
+	__u32 vf;
+	__u8 mac[32]; /* MAX_ADDR_LEN */
+};
+
+struct ifla_vf_vlan {
+	__u32 vf;
+	__u32 vlan; /* 0 - 4095, 0 disables VLAN filter */
+	__u32 qos;
+};
+
+struct ifla_vf_tx_rate {
+	__u32 vf;
+	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
+};
+
+struct ifla_vf_info {
+	__u32 vf;
+	__u8 mac[32];
+	__u32 vlan;
+	__u32 qos;
+	__u32 tx_rate;
+};
 #endif /* _LINUX_IF_LINK_H */

