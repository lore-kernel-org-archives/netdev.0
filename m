From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH RFC 3/3] netdevice: Remove obsolete xdp_netdev_command
Date: Tue, 20 Sep 2016 15:00:24 -0700
Message-ID: <1474408824-418864-4-git-send-email-tom@herbertland.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <tariqt@mellanox.com>,
        <bblanco@plumgrid.com>, <alexei.starovoitov@gmail.com>,
        <eric.dumazet@gmail.com>, <brouer@redhat.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55377 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754971AbcITWAh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 18:00:37 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8KM0Yjg005520
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:00:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 25ka6gsj0p-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 15:00:36 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 a8337cfe7f7d11e6acc50002c9931860-42ee8a50 for <netdev@vger.kernel.org>;        Tue,
 20 Sep 2016 15:00:35 -0700
In-Reply-To: <1474408824-418864-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove XDP_SETUP_PROG and XDP_QUERY_PROG as they should no longer be
needed.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/netdevice.h | 17 +----------------
 1 file changed, 1 insertion(+), 16 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f2b7d1b..9a545ab 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -808,18 +808,6 @@ struct tc_to_netdev {
  * to the netdevice through the xdp op.
  */
 enum xdp_netdev_command {
-	/* Set or clear a bpf program used in the earliest stages of packet
-	 * rx. The prog will have been loaded as BPF_PROG_TYPE_XDP. The callee
-	 * is responsible for calling bpf_prog_put on any old progs that are
-	 * stored. In case of error, the callee need not release the new prog
-	 * reference, but on success it takes ownership and must bpf_prog_put
-	 * when it is no longer used.
-	 */
-	XDP_SETUP_PROG,
-	/* Check if a bpf program is set on the device.  The callee should
-	 * return true if a program is currently attached and running.
-	 */
-	XDP_QUERY_PROG,
 	/* Initialize XDP in the device. Called the first time an XDP hook
 	 * hook is being set on the device.
 	 */
@@ -833,10 +821,7 @@ enum xdp_netdev_command {
 struct netdev_xdp {
 	enum xdp_netdev_command command;
 	union {
-		/* XDP_SETUP_PROG */
-		struct bpf_prog *prog;
-		/* XDP_QUERY_PROG */
-		bool prog_attached;
+		/* Command parameters */
 	};
 };
 
-- 
2.8.0.rc2
