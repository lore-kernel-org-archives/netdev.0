From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH NEXT 6/6] netxen: report valid speed and duplex status when link is down
Date: Fri, 3 Feb 2012 13:35:15 -0800
Message-ID: <1328304915-12858-7-git-send-email-rajesh.borundia@qlogic.com>
References: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:13244
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757952Ab2BCVvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 16:51:13 -0500
In-Reply-To: <1328304915-12858-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

o Update version to 4.0.78

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |    4 ++--
 .../ethernet/qlogic/netxen/netxen_nic_ethtool.c    |    5 +++++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index 8a35430..2eeac32 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -53,8 +53,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 77
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.77"
+#define _NETXEN_NIC_LINUX_SUBVERSION 78
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.78"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
index 3e73d35..8c39299 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ethtool.c
@@ -248,6 +248,11 @@ skip:
 		}
 	}
 
+	if (!netif_running(dev) || !adapter->ahw.linkup) {
+		ecmd->duplex = DUPLEX_UNKNOWN;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+	}
+
 	return 0;
 }
 
-- 
1.7.3.3
