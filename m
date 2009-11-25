From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool PATCH] ethtool: Add Direct Attach to the available connector
	ports
Date: Wed, 25 Nov 2009 02:13:15 -0800
Message-ID: <20091125101315.24481.11759.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:60101
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751387AbZKYKNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 05:13:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

This adds Direct Attach SFP+ types to the connector ports
for the GSET mode.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 ethtool-copy.h |    3 +++
 ethtool.c      |    6 ++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 3ca4e2c..7ea5a1b 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -402,6 +402,9 @@ struct ethtool_rxnfc {
 #define PORT_MII		0x02
 #define PORT_FIBRE		0x03
 #define PORT_BNC		0x04
+#define PORT_DA			0x05
+#define PORT_NONE		0xef
+#define PORT_OTHER		0xff
 
 /* Which transceiver to use. */
 #define XCVR_INTERNAL		0x00
diff --git a/ethtool.c b/ethtool.c
index 0110682..5b77614 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -942,6 +942,12 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	case PORT_FIBRE:
 		fprintf(stdout, "FIBRE\n");
 		break;
+	case PORT_DA:
+		fprintf(stdout, "Direct Attach Copper\n");
+		break;
+	case PORT_NONE:
+		fprintf(stdout, "None\n");
+		break;
 	default:
 		fprintf(stdout, "Unknown! (%i)\n", ep->port);
 		break;

