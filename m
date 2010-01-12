From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/5] tg3: Fix std prod ring nicaddr for 5787 and 57765
Date: Tue, 12 Jan 2010 12:11:36 -0800
Message-ID: <1263327100-13554-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net,
	"Matt Carlson" <mcarlson@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1291 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753569Ab0ALUMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jan 2010 15:12:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 87668d352aa8d135bd695a050f18bbfc7b50b506, titled "tg3: Don't
touch RCB nic addresses", tried to avoid assigning the nic address of
the standard producer ring.  Unfortunately, the default nic address is
not correct for the 5787, the 5755M, or the 57765.  This patch
reenables the old behavior and opts out of the assignment only
for the 5717.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Tested-by: Chow Loong Jin <hyperair@ubuntu.com>
Tested-by: Dmitry Torokhov <dtor@mail.ru>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 3a74d21..5c77e6a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7742,7 +7742,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	     ((u64) tpr->rx_std_mapping >> 32));
 	tw32(RCVDBDI_STD_BD + TG3_BDINFO_HOST_ADDR + TG3_64BIT_REG_LOW,
 	     ((u64) tpr->rx_std_mapping & 0xffffffff));
-	if (!(tp->tg3_flags3 & TG3_FLG3_5755_PLUS))
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717)
 		tw32(RCVDBDI_STD_BD + TG3_BDINFO_NIC_ADDR,
 		     NIC_SRAM_RX_BUFFER_DESC);
 
-- 
1.6.4.4


