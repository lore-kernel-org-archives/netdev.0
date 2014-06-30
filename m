From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net v2 2/3] net: stmmac: Correct duplicate if/then/else case found by cppcheck
Date: Sun, 29 Jun 2014 20:34:52 -0500
Message-ID: <1404092093-18630-3-git-send-email-vbridgers2013@gmail.com>
References: <1404092093-18630-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com, vbridger@altera.com
To: netdev@vger.kernel.org, davem@davemloft.net, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:50702 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753817AbaF3Biu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Jun 2014 21:38:50 -0400
Received: by mail-ob0-f172.google.com with SMTP id uy5so8085804obc.3
        for <netdev@vger.kernel.org>; Sun, 29 Jun 2014 18:38:50 -0700 (PDT)
In-Reply-To: <1404092093-18630-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cppcheck found a duplicate if/then/else case where a receive descriptor
was being processed. This patch corrects that issue.

cppcheck --force --enable=all --inline-suppr .
...
Checking enh_desc.c...
[enh_desc.c:148] -> [enh_desc.c:144]: (style) Found duplicate if expressions.
...

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V2: No changes
---
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
index 7e6628a..1e2bcf5 100644
--- a/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/enh_desc.c
@@ -145,7 +145,7 @@ static void enh_desc_get_ext_status(void *data, struct stmmac_extra_stats *x,
 			x->rx_msg_type_delay_req++;
 		else if (p->des4.erx.msg_type == RDES_EXT_DELAY_RESP)
 			x->rx_msg_type_delay_resp++;
-		else if (p->des4.erx.msg_type == RDES_EXT_DELAY_REQ)
+		else if (p->des4.erx.msg_type == RDES_EXT_PDELAY_REQ)
 			x->rx_msg_type_pdelay_req++;
 		else if (p->des4.erx.msg_type == RDES_EXT_PDELAY_RESP)
 			x->rx_msg_type_pdelay_resp++;
-- 
1.7.9.5
