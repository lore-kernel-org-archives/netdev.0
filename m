From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 3/5] qede: Prevent VFs from using XDP
Date: Fri, 7 Apr 2017 11:04:59 +0300
Message-ID: <1491552301-23953-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ast@fb.com>, Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:56670 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753888AbdDGIGX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 04:06:23 -0400
In-Reply-To: <1491552301-23953-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current implementation of VFs is very tight in regard to queue
resources. VFs support for XDP would require quite a bit of additional
infrastructure in qede and qed [sharing of queue-zones between queues,
more VF cids, mapping of the doorbell bar, etc.].

For now, prevent XDP programs from being attached to VFs.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_filter.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 107c3fd..ecd5b3a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -537,6 +537,11 @@ int qede_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 {
 	struct qede_dev *edev = netdev_priv(dev);
 
+	if (IS_VF(edev)) {
+		DP_NOTICE(edev, "VFs don't support XDP\n");
+		return -EOPNOTSUPP;
+	}
+
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
 		return qede_xdp_set(edev, xdp->prog);
-- 
1.9.3
