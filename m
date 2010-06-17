From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/5] qlcnic: fix device soft reset
Date: Thu, 17 Jun 2010 05:56:38 -0700
Message-ID: <1276779402-496-2-git-send-email-amit.salecha@qlogic.com>
References: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta@dut4145.unminc.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:1950 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751953Ab0FQM4n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 08:56:43 -0400
In-Reply-To: <1276779402-496-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta@dut4145.unminc.com>

During device soft reset, don't halt every device block.
Access to some blocks is required during recovery.

Signed-off-by: Sucheta Chakraborty <sucheta@dut4145.unminc.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_init.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 635c990..317750d 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -413,7 +413,7 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 
 	/* resetall */
 	qlcnic_rom_lock(adapter);
-	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0xffffffff);
+	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0xfeffffff);
 	qlcnic_rom_unlock(adapter);
 
 	if (qlcnic_rom_fast_read(adapter, 0, &n) != 0 || (n != 0xcafecafe) ||
-- 
1.6.0.2

