From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 05/11] be2net: ignore mac-addr set call for an already programmed mac-addr
Date: Wed, 15 Jan 2014 13:23:35 +0530
Message-ID: <1389772421-24925-6-git-send-email-sathya.perla@emulex.com>
References: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:20739 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700AbaAOHtO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 02:49:14 -0500
In-Reply-To: <1389772421-24925-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

An ndo_set_mac_addr() call may be issued for a mac-addr that is already
active on an interface. If so, silently ignore the request. Sending such
a request to the FW, causes a "mac collision" error. The error is harmless
but is avoidable noise in the kernel log.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 0710f9a..ce589b4 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -258,6 +258,12 @@ static int be_mac_addr_set(struct net_device *netdev, void *p)
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	/* Proceed further only if, User provided MAC is different
+	 * from active MAC
+	 */
+	if (ether_addr_equal(addr->sa_data, netdev->dev_addr))
+		return 0;
+
 	/* The PMAC_ADD cmd may fail if the VF doesn't have FILTMGMT
 	 * privilege or if PF did not provision the new MAC address.
 	 * On BE3, this cmd will always fail if the VF doesn't have the
-- 
1.7.1
