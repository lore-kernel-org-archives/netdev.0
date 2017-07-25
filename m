From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [PATCH net-next 2/3] bnxt_en: use SWITCHDEV_SET_OPS() for setting vf_rep_switchdev_ops
Date: Tue, 25 Jul 2017 06:49:32 -0400
Message-ID: <20170725104933.9633-2-sathya.perla@broadcom.com>
References: <20170725104933.9633-1-sathya.perla@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.232.149]:44494 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbdGYKzd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 06:55:33 -0400
Received: from Sathya-S84.localdomain (unknown [10.192.238.84])
        by relay.smtp.broadcom.com (Postfix) with ESMTP id 23E0F1A0029
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 03:49:36 -0700 (PDT)
In-Reply-To: <20170725104933.9633-1-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the build error:
‘struct net_device’ has no member named ‘switchdev_ops’

Reported-by: kbuild test robot <lkp@intel.com>
Fixes: c124a62ff2dd ("bnxt_en: add support for port_attr_get and and get_phys_port_name")
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index 86850ae..9ba505f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -304,7 +304,7 @@ static void bnxt_vf_rep_netdev_init(struct bnxt *bp, struct bnxt_vf_rep *vf_rep,
 
 	dev->netdev_ops = &bnxt_vf_rep_netdev_ops;
 	dev->ethtool_ops = &bnxt_vf_rep_ethtool_ops;
-	dev->switchdev_ops = &bnxt_vf_rep_switchdev_ops;
+	SWITCHDEV_SET_OPS(dev, &bnxt_vf_rep_switchdev_ops);
 	/* Just inherit all the featues of the parent PF as the VF-R
 	 * uses the RX/TX rings of the parent PF
 	 */
-- 
1.8.3.1
