From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 2/2] staging: octeon-ethernet: Use proper phy addresses for Movidis hardware.
Date: Thu,  1 Apr 2010 18:17:55 -0700
Message-ID: <1270171075-12741-3-git-send-email-ddaney@caviumnetworks.com>
References: <1270171075-12741-1-git-send-email-ddaney@caviumnetworks.com>
Cc: davem@davemloft.net, David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:10726 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756879Ab0DBBSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 21:18:55 -0400
In-Reply-To: <1270171075-12741-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/cvmx-helper-board.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/staging/octeon/cvmx-helper-board.c b/drivers/staging/octeon/cvmx-helper-board.c
index 3085e38..00a555b 100644
--- a/drivers/staging/octeon/cvmx-helper-board.c
+++ b/drivers/staging/octeon/cvmx-helper-board.c
@@ -153,6 +153,14 @@ int cvmx_helper_board_get_mii_address(int ipd_port)
 		 * through switch.
 		 */
 		return -1;
+
+	case CVMX_BOARD_TYPE_CUST_WSX16:
+		if (ipd_port >= 0 && ipd_port <= 3)
+			return ipd_port;
+		else if (ipd_port >= 16 && ipd_port <= 19)
+			return ipd_port - 16 + 4;
+		else
+			return -1;
 	}
 
 	/* Some unknown board. Somebody forgot to update this function... */
-- 
1.6.6.1

