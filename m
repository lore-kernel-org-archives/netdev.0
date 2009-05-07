From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/5] ixgbe: Enable L2 header split in 82599
Date: Thu, 07 May 2009 13:39:35 -0700
Message-ID: <20090507203934.19886.45494.stgit@localhost.localdomain>
References: <20090507203854.19886.54737.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:42816
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752427AbZEGUjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 16:39:53 -0400
In-Reply-To: <20090507203854.19886.54737.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This enables L2 header split when packet split is enabled for 82599.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    3 ++-
 drivers/net/ixgbe/ixgbe_type.h |    1 +
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d64a2d7..01d8b6b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1818,7 +1818,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			u32 psrtype = IXGBE_PSRTYPE_TCPHDR |
 			              IXGBE_PSRTYPE_UDPHDR |
 			              IXGBE_PSRTYPE_IPV4HDR |
-			              IXGBE_PSRTYPE_IPV6HDR;
+			              IXGBE_PSRTYPE_IPV6HDR |
+			              IXGBE_PSRTYPE_L2HDR;
 			IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(0), psrtype);
 		}
 	} else {
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index e49e8af..9fd79a0 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1604,6 +1604,7 @@
 #define IXGBE_PSRTYPE_UDPHDR    0x00000020
 #define IXGBE_PSRTYPE_IPV4HDR   0x00000100
 #define IXGBE_PSRTYPE_IPV6HDR   0x00000200
+#define IXGBE_PSRTYPE_L2HDR     0x00001000
 
 /* SRRCTL bit definitions */
 #define IXGBE_SRRCTL_BSIZEPKT_SHIFT     10     /* so many KBs */

