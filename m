From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/2] bnxt_en: Fix VF virtual link state.
Date: Fri, 11 Nov 2016 00:11:43 -0500
Message-ID: <1478841103-22413-3-git-send-email-michael.chan@broadcom.com>
References: <1478841103-22413-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36069 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755815AbcKKFLy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 00:11:54 -0500
Received: by mail-pf0-f169.google.com with SMTP id 189so5331827pfz.3
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 21:11:54 -0800 (PST)
In-Reply-To: <1478841103-22413-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the physical link is down and the VF virtual link is set to "enable",
the current code does not always work.  If the link is down but the
cable is attached, the firmware returns LINK_SIGNAL instead of
NO_LINK.  The current code is treating LINK_SIGNAL as link up.
The fix is to treat link as down when the link_status != LINK.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index ec6cd18..60e2af8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -774,8 +774,8 @@ static int bnxt_vf_set_link(struct bnxt *bp, struct bnxt_vf_info *vf)
 
 		if (vf->flags & BNXT_VF_LINK_UP) {
 			/* if physical link is down, force link up on VF */
-			if (phy_qcfg_resp.link ==
-			    PORT_PHY_QCFG_RESP_LINK_NO_LINK) {
+			if (phy_qcfg_resp.link !=
+			    PORT_PHY_QCFG_RESP_LINK_LINK) {
 				phy_qcfg_resp.link =
 					PORT_PHY_QCFG_RESP_LINK_LINK;
 				phy_qcfg_resp.link_speed = cpu_to_le16(
-- 
1.8.3.1
