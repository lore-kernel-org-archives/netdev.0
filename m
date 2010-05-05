From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 3/6] netdev: octeon_mgmt: Fix race manipulating irq bits.
Date: Wed,  5 May 2010 16:03:10 -0700
Message-ID: <1273100593-11043-4-git-send-email-ddaney@caviumnetworks.com>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1669 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758113Ab0EEXDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 19:03:50 -0400
In-Reply-To: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't re-read the interrupt status register, clear the exact bits we
will be testing.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/octeon/octeon_mgmt.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index b975a2f..633fa89 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -598,8 +598,7 @@ static irqreturn_t octeon_mgmt_interrupt(int cpl, void *dev_id)
 	mixx_isr.u64 = cvmx_read_csr(CVMX_MIXX_ISR(port));
 
 	/* Clear any pending interrupts */
-	cvmx_write_csr(CVMX_MIXX_ISR(port),
-		       cvmx_read_csr(CVMX_MIXX_ISR(port)));
+	cvmx_write_csr(CVMX_MIXX_ISR(port), mixx_isr.u64);
 	cvmx_read_csr(CVMX_MIXX_ISR(port));
 
 	if (mixx_isr.s.irthresh) {
-- 
1.6.6.1

