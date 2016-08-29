From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] sky2: use napi_complete_done
Date: Mon, 29 Aug 2016 10:16:37 -0700
Message-ID: <20160829101637.4f0663e5@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mirko Lindner <mlindner@marvell.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34861 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751950AbcH2RQ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 13:16:26 -0400
Received: by mail-pf0-f169.google.com with SMTP id x72so54027300pfd.2
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 10:16:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the sky2 driver to pass number of packets done to NAPI.
The driver was never updated when napi_complete_done was added.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/ethernet/marvell/sky2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 467138b..f05ea56 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -3070,7 +3070,7 @@ static int sky2_poll(struct napi_struct *napi, int work_limit)
 			goto done;
 	}
 
-	napi_complete(napi);
+	napi_complete_done(napi, work_done);
 	sky2_read32(hw, B0_Y2_SP_LISR);
 done:
 
-- 
2.9.3
