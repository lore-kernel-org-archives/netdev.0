From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/5] bnx2x: Warn about grc timeouts in register dump
Date: Tue, 16 Feb 2016 18:08:01 +0200
Message-ID: <1455638881-2527-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:23647 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933120AbcBPQIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 11:08:53 -0500
In-Reply-To: <1455638881-2527-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are several scenarios where taking a register dump from a device
might log benign GRC timeout attentions to system logs.
Most common of those is when taking the dump from a 2-port device.

Sadly, there's no easy way to mask the problematic attentions during the
flow - Changing this behvaior would require a firmware update.
For now, simply warn users to ignore the warnings.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 820b7e0..85a7800 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -981,6 +981,11 @@ static void bnx2x_get_regs(struct net_device *dev,
 	memcpy(p, &dump_hdr, sizeof(struct dump_header));
 	p += dump_hdr.header_size + 1;
 
+	/* This isn't really an error, but since attention handling is going
+	 * to print the GRC timeouts using this macro, we use the same.
+	 */
+	BNX2X_ERR("Generating register dump. Might trigger harmless GRC timeouts\n");
+
 	/* Actually read the registers */
 	__bnx2x_get_regs(bp, p);
 
-- 
1.9.3
