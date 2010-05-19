From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/7] ixgbe: remove some redundant code in setting
	FCoE FIP filter
Date: Tue, 18 May 2010 19:00:07 -0700
Message-ID: <20100519020007.18654.62574.stgit@localhost.localdomain>
References: <20100519020003.18654.94899.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:33525
	"EHLO qmta13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751045Ab0ESCAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:00:07 -0400
In-Reply-To: <20100519020003.18654.94899.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

The ETQS setup for FIP out side the if..else is enough for the ETQS
setup for FIP, so remove redundant code.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index a82d2fc..45182ab 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -539,12 +539,6 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 		}
 		IXGBE_WRITE_REG(hw, IXGBE_FCRECTL, IXGBE_FCRECTL_ENA);
 		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FCOE), 0);
-		fcoe_i = f->mask;
-		fcoe_i &= IXGBE_FCRETA_ENTRY_MASK;
-		fcoe_q = adapter->rx_ring[fcoe_i]->reg_idx;
-		IXGBE_WRITE_REG(hw, IXGBE_ETQS(IXGBE_ETQF_FILTER_FIP),
-				IXGBE_ETQS_QUEUE_EN |
-				(fcoe_q << IXGBE_ETQS_RX_QUEUE_SHIFT));
 	} else  {
 		/* Use single rx queue for FCoE */
 		fcoe_i = f->mask;

