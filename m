From: Michal Kalderon <Michal.Kalderon@cavium.com>
Subject: [PATCH net] qed: Fix printk option passed when printing ipv6 addresses
Date: Sun, 9 Jul 2017 13:00:16 +0300
Message-ID: <1499594416-20850-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dan.carpenter@oracle.com>,
        Michal Kalderon <Michal.Kalderon@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <michal.kalderon@cavium.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0058.outbound.protection.outlook.com ([104.47.40.58]:2752
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751774AbdGIKBD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 9 Jul 2017 06:01:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The option "h" (host order ) exists for ipv4 only.
Remove the h when printing ipv6 addresses.

Lead to the following smatch warning:

drivers/net/ethernet/qlogic/qed/qed_iwarp.c:585 qed_iwarp_print_tcp_ramrod()
warn: '%pI6' can only be followed by c
drivers/net/ethernet/qlogic/qed/qed_iwarp.c:1521 qed_iwarp_print_cm_info()
warn: '%pI6' can only be followed by c

Fixes commit 456a584947d5 ("qed: iWARP CM add passive side connect")

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Michal Kalderon <Michal.Kalderon@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_iwarp.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
index b251eba..9d989c9 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_iwarp.c
@@ -575,7 +575,7 @@ int qed_iwarp_destroy_qp(struct qed_hwfn *p_hwfn, struct qed_rdma_qp *qp)
 
 	if (p_tcp_ramrod->tcp.ip_version == TCP_IPV4) {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
-			   "local_ip=%pI4h:%x, remote_ip=%pI4h%x, vlan=%x\n",
+			   "local_ip=%pI4h:%x, remote_ip=%pI4h:%x, vlan=%x\n",
 			   p_tcp_ramrod->tcp.local_ip,
 			   p_tcp_ramrod->tcp.local_port,
 			   p_tcp_ramrod->tcp.remote_ip,
@@ -583,7 +583,7 @@ int qed_iwarp_destroy_qp(struct qed_hwfn *p_hwfn, struct qed_rdma_qp *qp)
 			   p_tcp_ramrod->tcp.vlan_id);
 	} else {
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
-			   "local_ip=%pI6h:%x, remote_ip=%pI6h:%x, vlan=%x\n",
+			   "local_ip=%pI6:%x, remote_ip=%pI6:%x, vlan=%x\n",
 			   p_tcp_ramrod->tcp.local_ip,
 			   p_tcp_ramrod->tcp.local_port,
 			   p_tcp_ramrod->tcp.remote_ip,
@@ -1519,7 +1519,7 @@ int qed_iwarp_reject(void *rdma_cxt, struct qed_iwarp_reject_in *iparams)
 			   cm_info->vlan);
 	else
 		DP_VERBOSE(p_hwfn, QED_MSG_RDMA,
-			   "remote_ip %pI6h:%x, local_ip %pI6h:%x vlan=%x\n",
+			   "remote_ip %pI6:%x, local_ip %pI6:%x vlan=%x\n",
 			   cm_info->remote_ip, cm_info->remote_port,
 			   cm_info->local_ip, cm_info->local_port,
 			   cm_info->vlan);
-- 
1.8.3.1
