From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/6] igb: Make arrays on stack static const to avoid reallocation
Date: Fri,  6 Mar 2015 03:06:04 -0800
Message-ID: <1425639966-6829-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:46782 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756081AbbCFLGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Mar 2015 06:06:12 -0500
In-Reply-To: <1425639966-6829-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@redhat.com>

While addressing the pin problem I noticed that all of the pin register
values where having to be pushed onto the stack each time the function was
called.  To avoid that I am making them static const so that they should
only need to be allocated once and we can avoid all the instructions to get
them onto the stack..

size before:
   text	   data	    bss	    dec	    hex	filename
 161477	  10512	      8	 171997	  29fdd	drivers/net/ethernet/intel/igb/igb.ko

size after:
   text	   data	    bss	    dec	    hex	filename
 161205	  10512	      8	 171725	  29ecd	drivers/net/ethernet/intel/igb/igb.ko

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 525e5c4..d6be4c6 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -358,7 +358,7 @@ static int igb_ptp_settime_i210(struct ptp_clock_info *ptp,
 static void igb_pin_direction(int pin, int input, u32 *ctrl, u32 *ctrl_ext)
 {
 	u32 *ptr = pin < 2 ? ctrl : ctrl_ext;
-	u32 mask[IGB_N_SDP] = {
+	static const u32 mask[IGB_N_SDP] = {
 		E1000_CTRL_SDP0_DIR,
 		E1000_CTRL_SDP1_DIR,
 		E1000_CTRL_EXT_SDP2_DIR,
@@ -373,16 +373,16 @@ static void igb_pin_direction(int pin, int input, u32 *ctrl, u32 *ctrl_ext)
 
 static void igb_pin_extts(struct igb_adapter *igb, int chan, int pin)
 {
-	struct e1000_hw *hw = &igb->hw;
-	u32 aux0_sel_sdp[IGB_N_SDP] = {
+	static const u32 aux0_sel_sdp[IGB_N_SDP] = {
 		AUX0_SEL_SDP0, AUX0_SEL_SDP1, AUX0_SEL_SDP2, AUX0_SEL_SDP3,
 	};
-	u32 aux1_sel_sdp[IGB_N_SDP] = {
+	static const u32 aux1_sel_sdp[IGB_N_SDP] = {
 		AUX1_SEL_SDP0, AUX1_SEL_SDP1, AUX1_SEL_SDP2, AUX1_SEL_SDP3,
 	};
-	u32 ts_sdp_en[IGB_N_SDP] = {
+	static const u32 ts_sdp_en[IGB_N_SDP] = {
 		TS_SDP0_EN, TS_SDP1_EN, TS_SDP2_EN, TS_SDP3_EN,
 	};
+	struct e1000_hw *hw = &igb->hw;
 	u32 ctrl, ctrl_ext, tssdp = 0;
 
 	ctrl = rd32(E1000_CTRL);
@@ -409,28 +409,28 @@ static void igb_pin_extts(struct igb_adapter *igb, int chan, int pin)
 
 static void igb_pin_perout(struct igb_adapter *igb, int chan, int pin)
 {
-	struct e1000_hw *hw = &igb->hw;
-	u32 aux0_sel_sdp[IGB_N_SDP] = {
+	static const u32 aux0_sel_sdp[IGB_N_SDP] = {
 		AUX0_SEL_SDP0, AUX0_SEL_SDP1, AUX0_SEL_SDP2, AUX0_SEL_SDP3,
 	};
-	u32 aux1_sel_sdp[IGB_N_SDP] = {
+	static const u32 aux1_sel_sdp[IGB_N_SDP] = {
 		AUX1_SEL_SDP0, AUX1_SEL_SDP1, AUX1_SEL_SDP2, AUX1_SEL_SDP3,
 	};
-	u32 ts_sdp_en[IGB_N_SDP] = {
+	static const u32 ts_sdp_en[IGB_N_SDP] = {
 		TS_SDP0_EN, TS_SDP1_EN, TS_SDP2_EN, TS_SDP3_EN,
 	};
-	u32 ts_sdp_sel_tt0[IGB_N_SDP] = {
+	static const u32 ts_sdp_sel_tt0[IGB_N_SDP] = {
 		TS_SDP0_SEL_TT0, TS_SDP1_SEL_TT0,
 		TS_SDP2_SEL_TT0, TS_SDP3_SEL_TT0,
 	};
-	u32 ts_sdp_sel_tt1[IGB_N_SDP] = {
+	static const u32 ts_sdp_sel_tt1[IGB_N_SDP] = {
 		TS_SDP0_SEL_TT1, TS_SDP1_SEL_TT1,
 		TS_SDP2_SEL_TT1, TS_SDP3_SEL_TT1,
 	};
-	u32 ts_sdp_sel_clr[IGB_N_SDP] = {
+	static const u32 ts_sdp_sel_clr[IGB_N_SDP] = {
 		TS_SDP0_SEL_FC1, TS_SDP1_SEL_FC1,
 		TS_SDP2_SEL_FC1, TS_SDP3_SEL_FC1,
 	};
+	struct e1000_hw *hw = &igb->hw;
 	u32 ctrl, ctrl_ext, tssdp = 0;
 
 	ctrl = rd32(E1000_CTRL);
-- 
1.9.3
