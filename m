From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 7/9] bpf: ixgbe: Report bpf_prog ID during XDP_QUERY_PROG
Date: Thu, 15 Jun 2017 17:29:15 -0700
Message-ID: <20170616002917.2976329-8-kafai@fb.com>
References: <20170616002917.2976329-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        John Fastabend <john.fastabend@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45220 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751739AbdFPA3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 20:29:20 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5G0O7UN026772
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:19 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b3we81nap-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:19 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 d5e24394522a11e7ae4b0002c9dfb610-f27398f0 for <netdev@vger.kernel.org>;        Thu,
 15 Jun 2017 17:29:18 -0700
In-Reply-To: <20170616002917.2976329-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to ixgbe to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: John Fastabend <john.fastabend@gmail.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f3dc5dea9300..f1dbdf26d8e1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9815,6 +9815,8 @@ static int ixgbe_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 		return ixgbe_xdp_setup(dev, xdp->prog);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!(adapter->xdp_prog);
+		xdp->prog_id = adapter->xdp_prog ?
+			adapter->xdp_prog->aux->id : 0;
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.9.3
