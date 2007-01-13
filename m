From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/8] e1000: clear ip csum info from context descriptor
Date: Fri, 12 Jan 2007 16:37:51 -0800
Message-ID: <20070113003751.16816.51187.stgit@gitlost.site>
References: <20070113003650.16816.34076.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1201 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161187AbXAMAyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Jan 2007 19:54:11 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20070113003650.16816.34076.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Since the driver sets the IP checksum insertion bit (IXSM in Status
field) in transmit context descriptors, it should clear the IP checksum
bits of any garbage so as not to confuse the hardware.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 43dde27..8c6c74d 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2975,8 +2975,9 @@ e1000_tx_csum(struct e1000_adapter *adapter, struct e1000_tx_ring *tx_ring,
 		buffer_info = &tx_ring->buffer_info[i];
 		context_desc = E1000_CONTEXT_DESC(*tx_ring, i);
 
+		context_desc->lower_setup.ip_config = 0;
 		context_desc->upper_setup.tcp_fields.tucss = css;
-		context_desc->upper_setup.tcp_fields.tucso = css + skb->csum_offset;
+		context_desc->upper_setup.tcp_fields.tucso = css + skb->csum;
 		context_desc->upper_setup.tcp_fields.tucse = 0;
 		context_desc->tcp_seg_setup.data = 0;
 		context_desc->cmd_and_length = cpu_to_le32(E1000_TXD_CMD_DEXT);



---
Auke Kok <auke-jan.h.kok@intel.com>
