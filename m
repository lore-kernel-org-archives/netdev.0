From: Dhananjay Phadke <dhananjay.phadke@qlogic.com>
Subject: RE: [PATCH 1/2] netxen: fix detection of cut-thru firmware mode
Date: Thu, 18 Jun 2009 08:46:18 -0700
Message-ID: <7608421F3572AB4292BB2532AE89D5658187610BDB@AVEXMB1.qlogic.org>
References: <1245338871-27112-1-git-send-email-dhananjay@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:25315 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbZFRPtM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 11:49:12 -0400
In-Reply-To: <1245338871-27112-1-git-send-email-dhananjay@qlogic.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Sorry, these patches were accidentally sent again.
You have already applied both.

-Dhananjay
________________________________________
From: Dhananjay Phadke [dhananjay@qlogic.com]
Sent: Thursday, June 18, 2009 8:27 AM
To: davem@davemloft.net
Cc: netdev@vger.kernel.org
Subject: [PATCH 1/2] netxen: fix detection of cut-thru firmware mode

Fix the detection of cut-thru mode of the hardware (direct dma
to host) to mode configured in SRE (ingress block) rather than
onboard memory control.

Signed-off-by: Dhananjay Phadke <dhananjay@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hdr.h |    1 +
 drivers/net/netxen/netxen_nic_hw.c  |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 7f0ddbf..3cc0478 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -355,6 +355,7 @@ enum {
 #define NETXEN_HW_CRB_HUB_AGT_ADR_LPC  \
        ((NETXEN_HW_H6_CH_HUB_ADR << 7) | NETXEN_HW_LPC_CRB_AGT_ADR)

+#define NETXEN_SRE_MISC                        (NETXEN_CRB_SRE + 0x0002c)
 #define NETXEN_SRE_INT_STATUS          (NETXEN_CRB_SRE + 0x00034)
 #define NETXEN_SRE_PBI_ACTIVE_STATUS   (NETXEN_CRB_SRE + 0x01014)
 #define NETXEN_SRE_L1RE_CTL            (NETXEN_CRB_SRE + 0x03000)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 42ffb82..9702509 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -2041,8 +2041,8 @@ void netxen_nic_get_firmware_info(struct netxen_adapter *adapter)
                        fw_major, fw_minor, fw_build);

        if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-               i = NXRD32(adapter, NETXEN_MIU_MN_CONTROL);
-               adapter->ahw.cut_through = (i & 0x4) ? 1 : 0;
+               i = NXRD32(adapter, NETXEN_SRE_MISC);
+               adapter->ahw.cut_through = (i & 0x8000) ? 1 : 0;
                dev_info(&pdev->dev, "firmware running in %s mode\n",
                adapter->ahw.cut_through ? "cut-through" : "legacy");
        }
--
1.6.0.2

