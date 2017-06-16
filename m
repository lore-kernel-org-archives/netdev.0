From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 9/9] bpf: qede: Report bpf_prog ID during XDP_QUERY_PROG
Date: Thu, 15 Jun 2017 17:29:17 -0700
Message-ID: <20170616002917.2976329-10-kafai@fb.com>
References: <20170616002917.2976329-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Mintz Yuval <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52083 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751882AbdFPA3V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 20:29:21 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5G0NVJD012868
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b3xk714ae-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 d5e6664a522a11e7ae4b0002c9dfb610-f27398f0 for <netdev@vger.kernel.org>;        Thu,
 15 Jun 2017 17:29:18 -0700
In-Reply-To: <20170616002917.2976329-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to qede to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Mintz Yuval <Yuval.Mintz@cavium.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/qlogic/qede/qede_filter.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_filter.c b/drivers/net/ethernet/qlogic/qede/qede_filter.c
index 13955a3bd3b3..f939db5bac5f 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_filter.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_filter.c
@@ -1037,6 +1037,7 @@ int qede_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 		return qede_xdp_set(edev, xdp->prog);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!edev->xdp_prog;
+		xdp->prog_id = edev->xdp_prog ? edev->xdp_prog->aux->id : 0;
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.9.3
