From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 2/5] igb: ethtool -d reads EICR which is incorrect as it is
	read on clear
Date: Tue, 26 Aug 2008 04:25:05 -0700
Message-ID: <20080826112505.15627.9993.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:37230 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbYHZLZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:25:06 -0400
Received: by rv-out-0506.google.com with SMTP id k40so2099147rvb.1
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:25:06 -0700 (PDT)
In-Reply-To: <20080826112503.15627.3855.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Ethtool -d is reading the EICR and ICR registers which is currently
clearing these registers and masking off interrupts.  To prevent this we
read the EICS and ICS equivilents as they can be read without clearing or
masking.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index 6c0a8c2..58906c9 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -373,13 +373,17 @@ static void igb_get_regs(struct net_device *netdev,
 	regs_buff[12] = rd32(E1000_EECD);
 
 	/* Interrupt */
-	regs_buff[13] = rd32(E1000_EICR);
+	/* Reading EICS for EICR because they read the
+	 * same but EICS does not clear on read */
+	regs_buff[13] = rd32(E1000_EICS);
 	regs_buff[14] = rd32(E1000_EICS);
 	regs_buff[15] = rd32(E1000_EIMS);
 	regs_buff[16] = rd32(E1000_EIMC);
 	regs_buff[17] = rd32(E1000_EIAC);
 	regs_buff[18] = rd32(E1000_EIAM);
-	regs_buff[19] = rd32(E1000_ICR);
+	/* Reading ICS for ICR because they read the
+	 * same but ICS does not clear on read */
+	regs_buff[19] = rd32(E1000_ICS);
 	regs_buff[20] = rd32(E1000_ICS);
 	regs_buff[21] = rd32(E1000_IMS);
 	regs_buff[22] = rd32(E1000_IMC);

