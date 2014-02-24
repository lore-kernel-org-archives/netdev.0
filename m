From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 4/5] be2net: wait longer to reap TX compls in be_close()
Date: Mon, 24 Feb 2014 12:20:52 +0530
Message-ID: <57bc5399-f8f6-4c65-8cae-131c83d548ad@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:57247 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbaBXGwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 01:52:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

be_close() currently waits for a max of 200ms to receive all pending
TX compls. This timeout value was roughly calcuated based on 10G
transmission speeds and the TX queue depth. This timeout may not be
enough when the link is operating at lower speeds or in
multi-channel/SR-IOV configs with TX-rate limiting setting.
Increase the timeout to 2000ms and also bail-out if there is
a HW-error.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a9da6f9..f6a4481 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1985,7 +1985,7 @@ static void be_tx_compl_clean(struct be_adapter *adapter)
 				pending_txqs--;
 		}
 
-		if (pending_txqs == 0 || ++timeo > 200)
+		if (pending_txqs == 0 || ++timeo > 2000 || be_hw_error(adapter))
 			break;
 
 		mdelay(1);
-- 
1.5.6.1
