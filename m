From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net 2/2] net: stmmac: Correct duplicate if/then/else case found by cppcheck
Date: Sun, 22 Jun 2014 19:35:01 -0500
Message-ID: <1403483701-21199-3-git-send-email-vbridgers2013@gmail.com>
References: <1403483701-21199-1-git-send-email-vbridgers2013@gmail.com>
Cc: vbridgers2013@gmail.com
To: netdev@vger.kernel.org, peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:42382 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbaFWAjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jun 2014 20:39:03 -0400
Received: by mail-ig0-f176.google.com with SMTP id c1so2372363igq.15
        for <netdev@vger.kernel.org>; Sun, 22 Jun 2014 17:39:01 -0700 (PDT)
In-Reply-To: <1403483701-21199-1-git-send-email-vbridgers2013@gmail.com>
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
