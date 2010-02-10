From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [iproute2 PATCH v2 1/4] if_link: Sync if_link header with kernel to
	get new VF configuration defines
Date: Wed, 10 Feb 2010 03:46:17 -0800
Message-ID: <20100210114617.14570.87620.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:60380
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752760Ab0BJLqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2010 06:46:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/if_link.h |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index cbefb3b..014ca50 100644
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
 
@@ -194,4 +199,33 @@ enum macvlan_mode {
 	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
 };
 
+/* subqueue managment section */
+
+struct ifla_vf_mac
+{
+	__u32 vf;
+	__u8 mac[32]; /* MAX_ADDR_LEN */
+};
+
+struct ifla_vf_vlan
+{
+	__u32 vf;
+	__u32 vlan; /* 0 - 4095, 0 disables VLAN filter */
+	__u32 qos;
+};
+
+struct ifla_vf_tx_rate
+{
+	__u32 vf;
+	__u32 rate; /* Max TX bandwidth in Mbps, 0 disables throttling */
+};
+
+struct ifla_vf_info
+{
+	__u32 vf;
+	__u8 mac[32];
+	__u32 vlan;
+	__u32 qos;
+	__u32 tx_rate;
+};
 #endif /* _LINUX_IF_LINK_H */

