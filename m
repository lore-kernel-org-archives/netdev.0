From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/3] bnxt_en: use SWITCHDEV_SET_OPS() for setting vf_rep_switchdev_ops
Date: Tue, 25 Jul 2017 13:28:40 -0400
Message-ID: <1501003721-12407-3-git-send-email-michael.chan@broadcom.com>
References: <1501003721-12407-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f180.google.com ([209.85.216.180]:38539 "EHLO
        mail-qt0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751592AbdGYR26 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 13:28:58 -0400
Received: by mail-qt0-f180.google.com with SMTP id t37so37476251qtg.5
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 10:28:58 -0700 (PDT)
In-Reply-To: <1501003721-12407-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@broadcom.com>

This fixes the build error:
‘struct net_device’ has no member named ‘switchdev_ops’

Reported-by: kbuild test robot <lkp@intel.com>
Fixes: c124a62ff2dd ("bnxt_en: add support for port_attr_get and and get_phys_port_name")
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index a52e292..c00352a 100644
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
