From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 01/15] igb: remove unused temp variable from
	stats clearing path
Date: Mon, 05 Oct 2009 09:31:25 -0700
Message-ID: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:46258 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753944AbZJEQdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:33:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

There is a temp variable in the stats clearing path that isn't needed since
the results from the stats read can be immediately discared.  Since it
isn't needed we might as well just drop it from the function call.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   96 ++++++++++++++++++++---------------------
 drivers/net/igb/e1000_mac.c   |   76 ++++++++++++++++----------------
 2 files changed, 84 insertions(+), 88 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index f8f5772..b60daf4 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -1181,61 +1181,59 @@ static s32 igb_read_mac_addr_82575(struct e1000_hw *hw)
  **/
 static void igb_clear_hw_cntrs_82575(struct e1000_hw *hw)
 {
-	u32 temp;
-
 	igb_clear_hw_cntrs_base(hw);
 
-	temp = rd32(E1000_PRC64);
-	temp = rd32(E1000_PRC127);
-	temp = rd32(E1000_PRC255);
-	temp = rd32(E1000_PRC511);
-	temp = rd32(E1000_PRC1023);
-	temp = rd32(E1000_PRC1522);
-	temp = rd32(E1000_PTC64);
-	temp = rd32(E1000_PTC127);
-	temp = rd32(E1000_PTC255);
-	temp = rd32(E1000_PTC511);
-	temp = rd32(E1000_PTC1023);
-	temp = rd32(E1000_PTC1522);
-
-	temp = rd32(E1000_ALGNERRC);
-	temp = rd32(E1000_RXERRC);
-	temp = rd32(E1000_TNCRS);
-	temp = rd32(E1000_CEXTERR);
-	temp = rd32(E1000_TSCTC);
-	temp = rd32(E1000_TSCTFC);
-
-	temp = rd32(E1000_MGTPRC);
-	temp = rd32(E1000_MGTPDC);
-	temp = rd32(E1000_MGTPTC);
-
-	temp = rd32(E1000_IAC);
-	temp = rd32(E1000_ICRXOC);
-
-	temp = rd32(E1000_ICRXPTC);
-	temp = rd32(E1000_ICRXATC);
-	temp = rd32(E1000_ICTXPTC);
-	temp = rd32(E1000_ICTXATC);
-	temp = rd32(E1000_ICTXQEC);
-	temp = rd32(E1000_ICTXQMTC);
-	temp = rd32(E1000_ICRXDMTC);
-
-	temp = rd32(E1000_CBTMPC);
-	temp = rd32(E1000_HTDPMC);
-	temp = rd32(E1000_CBRMPC);
-	temp = rd32(E1000_RPTHC);
-	temp = rd32(E1000_HGPTC);
-	temp = rd32(E1000_HTCBDPC);
-	temp = rd32(E1000_HGORCL);
-	temp = rd32(E1000_HGORCH);
-	temp = rd32(E1000_HGOTCL);
-	temp = rd32(E1000_HGOTCH);
-	temp = rd32(E1000_LENERRS);
+	rd32(E1000_PRC64);
+	rd32(E1000_PRC127);
+	rd32(E1000_PRC255);
+	rd32(E1000_PRC511);
+	rd32(E1000_PRC1023);
+	rd32(E1000_PRC1522);
+	rd32(E1000_PTC64);
+	rd32(E1000_PTC127);
+	rd32(E1000_PTC255);
+	rd32(E1000_PTC511);
+	rd32(E1000_PTC1023);
+	rd32(E1000_PTC1522);
+
+	rd32(E1000_ALGNERRC);
+	rd32(E1000_RXERRC);
+	rd32(E1000_TNCRS);
+	rd32(E1000_CEXTERR);
+	rd32(E1000_TSCTC);
+	rd32(E1000_TSCTFC);
+
+	rd32(E1000_MGTPRC);
+	rd32(E1000_MGTPDC);
+	rd32(E1000_MGTPTC);
+
+	rd32(E1000_IAC);
+	rd32(E1000_ICRXOC);
+
+	rd32(E1000_ICRXPTC);
+	rd32(E1000_ICRXATC);
+	rd32(E1000_ICTXPTC);
+	rd32(E1000_ICTXATC);
+	rd32(E1000_ICTXQEC);
+	rd32(E1000_ICTXQMTC);
+	rd32(E1000_ICRXDMTC);
+
+	rd32(E1000_CBTMPC);
+	rd32(E1000_HTDPMC);
+	rd32(E1000_CBRMPC);
+	rd32(E1000_RPTHC);
+	rd32(E1000_HGPTC);
+	rd32(E1000_HTCBDPC);
+	rd32(E1000_HGORCL);
+	rd32(E1000_HGORCH);
+	rd32(E1000_HGOTCL);
+	rd32(E1000_HGOTCH);
+	rd32(E1000_LENERRS);
 
 	/* This register should not be read in copper configurations */
 	if (hw->phy.media_type == e1000_media_type_internal_serdes ||
 	    igb_sgmii_active_82575(hw))
-		temp = rd32(E1000_SCVPC);
+		rd32(E1000_SCVPC);
 }
 
 /**
diff --git a/drivers/net/igb/e1000_mac.c b/drivers/net/igb/e1000_mac.c
index 7d76bb0..986aa90 100644
--- a/drivers/net/igb/e1000_mac.c
+++ b/drivers/net/igb/e1000_mac.c
@@ -399,45 +399,43 @@ void igb_update_mc_addr_list(struct e1000_hw *hw,
  **/
 void igb_clear_hw_cntrs_base(struct e1000_hw *hw)
 {
-	u32 temp;
-
-	temp = rd32(E1000_CRCERRS);
-	temp = rd32(E1000_SYMERRS);
-	temp = rd32(E1000_MPC);
-	temp = rd32(E1000_SCC);
-	temp = rd32(E1000_ECOL);
-	temp = rd32(E1000_MCC);
-	temp = rd32(E1000_LATECOL);
-	temp = rd32(E1000_COLC);
-	temp = rd32(E1000_DC);
-	temp = rd32(E1000_SEC);
-	temp = rd32(E1000_RLEC);
-	temp = rd32(E1000_XONRXC);
-	temp = rd32(E1000_XONTXC);
-	temp = rd32(E1000_XOFFRXC);
-	temp = rd32(E1000_XOFFTXC);
-	temp = rd32(E1000_FCRUC);
-	temp = rd32(E1000_GPRC);
-	temp = rd32(E1000_BPRC);
-	temp = rd32(E1000_MPRC);
-	temp = rd32(E1000_GPTC);
-	temp = rd32(E1000_GORCL);
-	temp = rd32(E1000_GORCH);
-	temp = rd32(E1000_GOTCL);
-	temp = rd32(E1000_GOTCH);
-	temp = rd32(E1000_RNBC);
-	temp = rd32(E1000_RUC);
-	temp = rd32(E1000_RFC);
-	temp = rd32(E1000_ROC);
-	temp = rd32(E1000_RJC);
-	temp = rd32(E1000_TORL);
-	temp = rd32(E1000_TORH);
-	temp = rd32(E1000_TOTL);
-	temp = rd32(E1000_TOTH);
-	temp = rd32(E1000_TPR);
-	temp = rd32(E1000_TPT);
-	temp = rd32(E1000_MPTC);
-	temp = rd32(E1000_BPTC);
+	rd32(E1000_CRCERRS);
+	rd32(E1000_SYMERRS);
+	rd32(E1000_MPC);
+	rd32(E1000_SCC);
+	rd32(E1000_ECOL);
+	rd32(E1000_MCC);
+	rd32(E1000_LATECOL);
+	rd32(E1000_COLC);
+	rd32(E1000_DC);
+	rd32(E1000_SEC);
+	rd32(E1000_RLEC);
+	rd32(E1000_XONRXC);
+	rd32(E1000_XONTXC);
+	rd32(E1000_XOFFRXC);
+	rd32(E1000_XOFFTXC);
+	rd32(E1000_FCRUC);
+	rd32(E1000_GPRC);
+	rd32(E1000_BPRC);
+	rd32(E1000_MPRC);
+	rd32(E1000_GPTC);
+	rd32(E1000_GORCL);
+	rd32(E1000_GORCH);
+	rd32(E1000_GOTCL);
+	rd32(E1000_GOTCH);
+	rd32(E1000_RNBC);
+	rd32(E1000_RUC);
+	rd32(E1000_RFC);
+	rd32(E1000_ROC);
+	rd32(E1000_RJC);
+	rd32(E1000_TORL);
+	rd32(E1000_TORH);
+	rd32(E1000_TOTL);
+	rd32(E1000_TOTH);
+	rd32(E1000_TPR);
+	rd32(E1000_TPT);
+	rd32(E1000_MPTC);
+	rd32(E1000_BPTC);
 }
 
 /**

