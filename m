From: Colin King <colin.king@canonical.com>
Subject: [PATCH][V2] nfp: check idx is -ENOSPC before using it is an index
Date: Mon, 11 Jul 2016 16:54:20 +0100
Message-ID: <1468252460-15117-1-git-send-email-colin.king@canonical.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S . Miller" <davem@davemloft.net>,
	Rolf Neugebauer <rolf.neugebauer@netronome.com>,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>,
	oss-drivers@netronome.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:38600 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085AbcGKPy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 11:54:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

idx can be returned as -ENOSPC, so we should check for this first
before using it as an index into nn->vxlan_usecnt[] to avoid an
out of bounds array offset read.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 1e74b91..88678c1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2578,7 +2578,7 @@ static void nfp_net_del_vxlan_port(struct net_device *netdev,
 		return;
 
 	idx = nfp_net_find_vxlan_idx(nn, ti->port);
-	if (!nn->vxlan_usecnt[idx] || idx == -ENOSPC)
+	if (idx == -ENOSPC || !nn->vxlan_usecnt[idx])
 		return;
 
 	if (!--nn->vxlan_usecnt[idx])
-- 
2.8.1
