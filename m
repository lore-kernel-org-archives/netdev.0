From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH v2 net-next] liquidio: fix bug in soft reset failure detection
Date: Wed, 5 Jul 2017 11:59:27 -0700
Message-ID: <20170705185927.GA1058@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0046.outbound.protection.outlook.com ([104.47.38.46]:41120
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751772AbdGES7e (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Jul 2017 14:59:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Derek Chickles <derek.chickles@cavium.com>

The code that detects a failed soft reset of Octeon is comparing the wrong
value against the reset value of the Octeon SLI_SCRATCH_1 register,
resulting in an inability to detect a soft reset failure.  Fix it by using
the correct value in the comparison, which is any non-zero value.

Fixes: f21fb3ed364b ("Add support of Cavium Liquidio ethernet adapters")
Fixes: c0eab5b3580a ("liquidio: CN23XX firmware download")
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
Patch Changelog:
 v2: Revise patch comment, remove unnecessary "!= 0x0ULL" in if statements,
     and add "Fixes:" tags

 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c | 2 +-
 drivers/net/ethernet/cavium/liquidio/cn66xx_device.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
index 6081c31..4b0ca9f 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.c
@@ -221,7 +221,7 @@ static int cn23xx_pf_soft_reset(struct octeon_device *oct)
 	/* Wait for 100ms as Octeon resets. */
 	mdelay(100);
 
-	if (octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1) == 0x1234ULL) {
+	if (octeon_read_csr64(oct, CN23XX_SLI_SCRATCH1)) {
 		dev_err(&oct->pci_dev->dev, "OCTEON[%d]: Soft reset failed\n",
 			oct->octeon_id);
 		return 1;
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index b28253c..2df7440 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -44,7 +44,7 @@ int lio_cn6xxx_soft_reset(struct octeon_device *oct)
 	/* Wait for 10ms as Octeon resets. */
 	mdelay(100);
 
-	if (octeon_read_csr64(oct, CN6XXX_SLI_SCRATCH1) == 0x1234ULL) {
+	if (octeon_read_csr64(oct, CN6XXX_SLI_SCRATCH1)) {
 		dev_err(&oct->pci_dev->dev, "Soft reset failed\n");
 		return 1;
 	}
