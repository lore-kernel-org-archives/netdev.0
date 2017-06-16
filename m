From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 8/9] bpf: nfp: Report bpf_prog ID during XDP_QUERY_PROG
Date: Thu, 15 Jun 2017 17:29:16 -0700
Message-ID: <20170616002917.2976329-9-kafai@fb.com>
References: <20170616002917.2976329-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52080 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751836AbdFPA3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 20:29:20 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5G0NVJB012868
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b3xk714ae-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 d5e55caa522a11e7ae4b0002c9dfb610-f27398f0 for <netdev@vger.kernel.org>;        Thu,
 15 Jun 2017 17:29:18 -0700
In-Reply-To: <20170616002917.2976329-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to nfp to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 49d1756d6a8e..378512dec80d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3256,6 +3256,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 		return nfp_net_xdp_setup(nn, xdp);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!nn->dp.xdp_prog;
+		xdp->prog_id = nn->dp.xdp_prog ? nn->dp.xdp_prog->aux->id : 0;
 		return 0;
 	default:
 		return -EINVAL;
-- 
2.9.3
