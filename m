From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 5/9] bpf: bnxt: Report bpf_prog ID during XDP_QUERY_PROG
Date: Thu, 15 Jun 2017 17:29:13 -0700
Message-ID: <20170616002917.2976329-6-kafai@fb.com>
References: <20170616002917.2976329-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        Michael Chan <michael.chan@broadcom.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39693 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751845AbdFPA3U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 20:29:20 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5G0OwlM011879
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b42harcr5-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 17:29:20 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (2401:db00:2050:5102:face:0000:0037:0000) with ESMTP       id
 d625a170522a11e78faa75369c678944-fc9368f0 for <netdev@vger.kernel.org>;        Thu,
 15 Jun 2017 17:29:19 -0700
In-Reply-To: <20170616002917.2976329-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to bnxt to report bpf_prog ID during XDP_QUERY_PROG.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Cc: Michael Chan <michael.chan@broadcom.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 8ce793a0d030..7d67552e70d7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -218,6 +218,7 @@ int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 		break;
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!bp->xdp_prog;
+		xdp->prog_id = bp->xdp_prog ? bp->xdp_prog->aux->id : 0;
 		rc = 0;
 		break;
 	default:
-- 
2.9.3
