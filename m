From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio VF: fix incorrect struct being used
Date: Wed, 4 Jan 2017 11:31:55 -0800
Message-ID: <20170104193155.GA19084@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0076.outbound.protection.outlook.com ([104.47.34.76]:25891
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1761805AbdADTd0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 4 Jan 2017 14:33:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasad Kanneganti <prasad.kanneganti@cavium.com>

The VF driver is using the wrong struct when sending commands to the NIC
firmware, sometimes causing adverse effects in the firmware.  The right
struct is the one that the PF is using, so make the VF use that as well.

Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index c3d6a82..0243be8 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -49,7 +49,7 @@ octeon_alloc_soft_command_resp(struct octeon_device    *oct,
 	/* Add in the response related fields. Opcode and Param are already
 	 * there.
 	 */
-	if (OCTEON_CN23XX_PF(oct)) {
+	if (OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct)) {
 		ih3      = (struct octeon_instr_ih3 *)&sc->cmd.cmd3.ih3;
 		rdp     = (struct octeon_instr_rdp *)&sc->cmd.cmd3.rdp;
 		irh     = (struct octeon_instr_irh *)&sc->cmd.cmd3.irh;
@@ -70,7 +70,7 @@ octeon_alloc_soft_command_resp(struct octeon_device    *oct,
 
 	*sc->status_word = COMPLETION_WORD_INIT;
 
-	if (OCTEON_CN23XX_PF(oct))
+	if (OCTEON_CN23XX_PF(oct) || OCTEON_CN23XX_VF(oct))
 		sc->cmd.cmd3.rptr =  sc->dmarptr;
 	else
 		sc->cmd.cmd2.rptr =  sc->dmarptr;
