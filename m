From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/3] be2net: ignore VF mac address setting for the same mac
Date: Fri, 1 Aug 2014 17:47:31 +0530
Message-ID: <1406895452-29514-3-git-send-email-sathya.perla@emulex.com>
References: <1406895452-29514-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:43569 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755242AbaHAMPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 08:15:44 -0400
In-Reply-To: <1406895452-29514-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

ndo_set_vf_mac() call may be issued for a mac-addr that is already
active on a VF. If so, silently ignore the request.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index da4d386..db4ff14 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1270,6 +1270,12 @@ static int be_set_vf_mac(struct net_device *netdev, int vf, u8 *mac)
 	if (!is_valid_ether_addr(mac) || vf >= adapter->num_vfs)
 		return -EINVAL;
 
+	/* Proceed further only if user provided MAC is different
+	 * from active MAC
+	 */
+	if (ether_addr_equal(mac, vf_cfg->mac_addr))
+		return 0;
+
 	if (BEx_chip(adapter)) {
 		be_cmd_pmac_del(adapter, vf_cfg->if_handle, vf_cfg->pmac_id,
 				vf + 1);
-- 
1.7.1
