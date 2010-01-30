From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 2/5] if_link: Add SR-IOV configuration methods
Date: Sat, 30 Jan 2010 02:39:49 -0800
Message-ID: <20100130103947.26633.78452.stgit@localhost.localdomain>
References: <20100130103842.26633.73429.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:54555
	"EHLO qmta08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932065Ab0A3KkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 05:40:08 -0500
In-Reply-To: <20100130103842.26633.73429.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Williams, Mitch A <mitch.a.williams@intel.com>

Add SR-IOV VF management methods to IFLA_LINKINFO. This allows userspace to
use rtnetlink to configure VF network devices.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/if_link.h |   28 ++++++++++++++++++++++++++++
 1 files changed, 28 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 6674791..7d0c687 100644
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
 
@@ -196,4 +201,27 @@ enum macvlan_mode {
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
+	__s32 vlan; /* 0 - 4095, -1 disables VLAN filter */
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
+	__s32 vlan;
+	__u32 tx_rate;
+};
 #endif /* _LINUX_IF_LINK_H */

