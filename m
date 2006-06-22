From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 11/21] e1000: disable CRC stripping workaround
Date: Wed, 21 Jun 2006 22:20:29 -0700
Message-ID: <20060622052029.25497.67575.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:53768 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932801AbWFVFOc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:32 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


CRC stripping is breaking SMBUS-connected BMC's. We disable this
feature to make it work. This fixes related bugs regarding SOL.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_main.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index c44ed6f..7787299 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1628,8 +1628,11 @@ e1000_setup_rctl(struct e1000_adapter *a
 		E1000_RCTL_LBM_NO | E1000_RCTL_RDMTS_HALF |
 		(adapter->hw.mc_filter_type << E1000_RCTL_MO_SHIFT);
 
+	/* disable hardware stripping of CRC because it breaks
+	 * BMC firmware connected over SMBUS
 	if (adapter->hw.mac_type > e1000_82543)
 		rctl |= E1000_RCTL_SECRC;
+	 */
 
 	if (adapter->hw.tbi_compatibility_on == 1)
 		rctl |= E1000_RCTL_SBP;
@@ -1696,7 +1699,9 @@ e1000_setup_rctl(struct e1000_adapter *a
 		rfctl |= E1000_RFCTL_IPV6_DIS;
 		E1000_WRITE_REG(&adapter->hw, RFCTL, rfctl);
 
-		rctl |= E1000_RCTL_DTYP_PS | E1000_RCTL_SECRC;
+		/* disable the stripping of CRC because it breaks
+		 * BMC firmware connected over SMBUS */
+		rctl |= E1000_RCTL_DTYP_PS /* | E1000_RCTL_SECRC */;
 
 		psrctl |= adapter->rx_ps_bsize0 >>
 			E1000_PSRCTL_BSIZE0_SHIFT;



--
Auke Kok <auke-jan.h.kok@intel.com>
