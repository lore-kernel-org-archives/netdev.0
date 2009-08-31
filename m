From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/8] dcbnl: Add support for setapp/getapp commands to
	dcbnl
Date: Mon, 31 Aug 2009 15:32:34 -0700
Message-ID: <20090831223234.30995.75956.stgit@localhost.localdomain>
References: <20090831223110.30995.61162.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta12.emeryville.ca.mail.comcast.net ([76.96.27.227]:49594
	"EHLO QMTA12.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752100AbZHaWcv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 18:32:51 -0400
In-Reply-To: <20090831223110.30995.61162.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This patch adds dcbnl command definitions to support setapp/getapp
functionality from the IEEE 802.1Qaz Data Center Bridging Capability
Exchange protocol (DCBX) specification. Section 3.3 defines the
application protocol and its 802.1p user priority in DCBX, which is
implemented here as a pair of setapp/getapp commands in the kernel
dcbnl for setting and retrieving the user priority for an given
application protocol. The protocol is identified by the combination of
an id and an idtype. Currently, when idtype is 0, the corresponding
id gives the ether type of this protocol, e.g., for FCoE, it will be
0x8906; when idtype is 1, then the corresponding id gives the TCP or
UDP port number.

For more information regarding DCBX spec., please refer to the following:
http://www.ieee802.org/1/files/public/docs2008/
az-wadekar-dcbx-capability-exchange-discovery-protocol-1108-v1.01.pdf

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 include/linux/dcbnl.h |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/include/linux/dcbnl.h b/include/linux/dcbnl.h
index 7d2e100..b7cdbb4 100644
--- a/include/linux/dcbnl.h
+++ b/include/linux/dcbnl.h
@@ -50,6 +50,8 @@ struct dcbmsg {
  * @DCB_CMD_SNUMTCS: set the number of traffic classes
  * @DCB_CMD_GBCN: set backward congestion notification configuration
  * @DCB_CMD_SBCN: get backward congestion notification configration.
+ * @DCB_CMD_GAPP: get application protocol configuration
+ * @DCB_CMD_SAPP: set application protocol configuration
  */
 enum dcbnl_commands {
 	DCB_CMD_UNDEFINED,
@@ -80,6 +82,9 @@ enum dcbnl_commands {
 	DCB_CMD_BCN_GCFG,
 	DCB_CMD_BCN_SCFG,
 
+	DCB_CMD_GAPP,
+	DCB_CMD_SAPP,
+
 	__DCB_CMD_ENUM_MAX,
 	DCB_CMD_MAX = __DCB_CMD_ENUM_MAX - 1,
 };
@@ -114,6 +119,7 @@ enum dcbnl_attrs {
 	DCB_ATTR_CAP,
 	DCB_ATTR_NUMTCS,
 	DCB_ATTR_BCN,
+	DCB_ATTR_APP,
 
 	__DCB_ATTR_ENUM_MAX,
 	DCB_ATTR_MAX = __DCB_ATTR_ENUM_MAX - 1,
@@ -338,5 +344,17 @@ enum dcb_general_attr_values {
 	DCB_ATTR_VALUE_UNDEFINED = 0xff
 };
 
+#define DCB_APP_IDTYPE_ETHTYPE	0x00
+#define DCB_APP_IDTYPE_PORTNUM	0x01
+enum dcbnl_app_attrs {
+	DCB_APP_ATTR_UNDEFINED,
+
+	DCB_APP_ATTR_IDTYPE,
+	DCB_APP_ATTR_ID,
+	DCB_APP_ATTR_PRIORITY,
+
+	__DCB_APP_ATTR_ENUM_MAX,
+	DCB_APP_ATTR_MAX = __DCB_APP_ATTR_ENUM_MAX - 1,
+};
 
 #endif /* __LINUX_DCBNL_H__ */

