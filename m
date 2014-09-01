From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCHv2 net 1/6] cxgb4: Fix for handling 1Gb/s SFP+ Transceiver Modules
Date: Mon,  1 Sep 2014 19:54:55 +0530
Message-ID: <1409581500-11264-2-git-send-email-hariprasad@chelsio.com>
References: <1409581500-11264-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	kumaras@chelsio.com, anish@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:51395
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753977AbaIAOTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 10:19:25 -0400
In-Reply-To: <1409581500-11264-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We previously assumed that a Port's Capabilities and Advertised Capabilities
would never change from Port Initialization time.  This is no longer true
when we can have 10Gb/s and 1Gb/s SFP+ Transceiver Modules randomly swapped.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index a853133..6b92c4c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3742,6 +3742,7 @@ int t4_handle_fw_rpl(struct adapter *adap, const __be64 *rpl)
 			lc->link_ok = link_ok;
 			lc->speed = speed;
 			lc->fc = fc;
+			lc->supported = be16_to_cpu(p->u.info.pcap);
 			t4_os_link_changed(adap, port, link_ok);
 		}
 		if (mod != pi->mod_type) {
-- 
1.7.1
