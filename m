From: clsoto@linux.vnet.ibm.com
Subject: [PATCH 2/2] Do not set shared_ports when nreq > MAX_MSIX
Date: Tue,  6 Oct 2015 17:27:09 -0400
Message-ID: <1444166829-17638-2-git-send-email-clsoto@linux.vnet.ibm.com>
References: <1444166829-17638-1-git-send-email-clsoto@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, ogerlitz@mellanox.com,
	brking@linux.vnet.ibm.com, Carol L Soto <clsoto@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:54703 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbJFV1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 17:27:43 -0400
Received: from /spool/local
	by e24smtp05.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <clsoto@linux.vnet.ibm.com>;
	Tue, 6 Oct 2015 18:27:39 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 63507352006E
	for <netdev@vger.kernel.org>; Tue,  6 Oct 2015 17:26:26 -0400 (EDT)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t96LPq8R15598026
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 18:25:53 -0300
Received: from d24av02.br.ibm.com (localhost [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t96LRYUu017423
	for <netdev@vger.kernel.org>; Tue, 6 Oct 2015 18:27:34 -0300
In-Reply-To: <1444166829-17638-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carol L Soto <clsoto@linux.vnet.ibm.com>

If we get MAX_MSIX interrupts would like to have each receive ring
with his own msix interrupt line.

Fixes: 9293267a3e2a ('net/mlx4_core: Capping number of requested MSIXs to MAX_MSIX')
Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

---
 drivers/net/ethernet/mellanox/mlx4/main.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 006757f..f03f513 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -2673,10 +2673,8 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 
 		nreq = min_t(int, dev->caps.num_eqs - dev->caps.reserved_eqs,
 			     nreq);
-		if (nreq > MAX_MSIX) {
+		if (nreq > MAX_MSIX)
 			nreq = MAX_MSIX;
-			shared_ports = true;
-		}
 
 		entries = kcalloc(nreq, sizeof *entries, GFP_KERNEL);
 		if (!entries)
-- 
1.8.3.1
