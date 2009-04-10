From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 01/10] ixgbe: Enable another bit for flow control operation
Date: Fri, 10 Apr 2009 01:26:21 -0700
Message-ID: <20090410082618.14372.86091.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:49152 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S937682AbZDJQyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 12:54:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

The discard pause frames bit was not enabled, so flow control frames could
be passed up to the host.  Enabled DPF to keep the frames off the stack.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c  |    1 +
 drivers/net/ixgbe/ixgbe_common.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 4791238..982783c 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -322,6 +322,7 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	}
 
 	/* Enable 802.3x based flow control settings. */
+	fctrl_reg |= IXGBE_FCTRL_DPF;
 	IXGBE_WRITE_REG(hw, IXGBE_FCTRL, fctrl_reg);
 	IXGBE_WRITE_REG(hw, IXGBE_RMCS, rmcs_reg);
 
diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index 5567519..c1b9045 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1700,6 +1700,7 @@ s32 ixgbe_fc_enable(struct ixgbe_hw *hw, s32 packetbuf_num)
 	}
 
 	/* Enable 802.3x based flow control settings. */
+	mflcn_reg |= IXGBE_MFLCN_DPF;
 	IXGBE_WRITE_REG(hw, IXGBE_MFLCN, mflcn_reg);
 	IXGBE_WRITE_REG(hw, IXGBE_FCCFG, fccfg_reg);
 

