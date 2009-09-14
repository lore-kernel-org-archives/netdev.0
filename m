From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] ixgbe: Create separate media type for CX4
	adapters
Date: Mon, 14 Sep 2009 10:48:10 -0700
Message-ID: <20090914174809.4560.72843.stgit@localhost.localdomain>
References: <20090914174659.4560.28814.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:55787
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753464AbZINRs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 13:48:26 -0400
In-Reply-To: <20090914174659.4560.28814.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Currently the media type detection for CX4 adapters lumps them into a
type of fiber.  This causes some strange fallout when firmware verification
is done on the NIC, and certain fiber NIC rules get enforced incorrectly.

This patch introduces a new media type for CX4, and puts both 82598 and
82599 CX4 adapters into this bucket.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |    6 ++++--
 drivers/net/ixgbe/ixgbe_82599.c |    2 +-
 drivers/net/ixgbe/ixgbe_type.h  |    1 +
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index cb7f0c3..56b12f3 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -322,14 +322,16 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 		break;
 	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
 	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
-	case IXGBE_DEV_ID_82598EB_CX4:
-	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
 	case IXGBE_DEV_ID_82598_DA_DUAL_PORT:
 	case IXGBE_DEV_ID_82598_SR_DUAL_PORT_EM:
 	case IXGBE_DEV_ID_82598EB_XF_LR:
 	case IXGBE_DEV_ID_82598EB_SFP_LOM:
 		media_type = ixgbe_media_type_fiber;
 		break;
+	case IXGBE_DEV_ID_82598EB_CX4:
+	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
+		media_type = ixgbe_media_type_cx4;
+		break;
 	case IXGBE_DEV_ID_82598AT:
 	case IXGBE_DEV_ID_82598AT2:
 		media_type = ixgbe_media_type_copper;
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index c9006bb..2ec58dc 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -338,7 +338,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82599(struct ixgbe_hw *hw)
 		media_type = ixgbe_media_type_fiber;
 		break;
 	case IXGBE_DEV_ID_82599_CX4:
-		media_type = ixgbe_media_type_fiber;
+		media_type = ixgbe_media_type_cx4;
 		break;
 	default:
 		media_type = ixgbe_media_type_unknown;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 37303a1..8761d78 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2144,6 +2144,7 @@ enum ixgbe_media_type {
 	ixgbe_media_type_fiber,
 	ixgbe_media_type_copper,
 	ixgbe_media_type_backplane,
+	ixgbe_media_type_cx4,
 	ixgbe_media_type_virtual
 };
 

