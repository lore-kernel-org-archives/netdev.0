From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH iproute2 net-next] bpf: Add support for IFLA_XDP_PROG_ID
Date: Wed, 21 Jun 2017 14:29:42 -0700
Message-ID: <20170621212942.2333878-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:44656 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751835AbdFUV3t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 17:29:49 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5LLTRxi011448
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 14:29:44 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2b802p05wu-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 14:29:44 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.89) with ESMTP id
 bd902d2256c811e79f0c0002c95209d8-57b348f0 for <netdev@vger.kernel.org>;        Wed,
 21 Jun 2017 14:29:43 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to the newly added IFLA_XDP_PROG_ID.

./ip link show dev eth0
3: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 xdpgeneric/id:2 qdisc [...]

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 include/linux/if_link.h |  1 +
 ip/iplink_xdp.c         | 12 +++++++++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index a536a24b1c28..75e6824094e3 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -905,6 +905,7 @@ enum {
 	IFLA_XDP_FD,
 	IFLA_XDP_ATTACHED,
 	IFLA_XDP_FLAGS,
+	IFLA_XDP_PROG_ID,
 	__IFLA_XDP_MAX,
 };
 
diff --git a/ip/iplink_xdp.c b/ip/iplink_xdp.c
index 98503fab7d3c..4857f50c80de 100644
--- a/ip/iplink_xdp.c
+++ b/ip/iplink_xdp.c
@@ -90,9 +90,15 @@ void xdp_dump(FILE *fp, struct rtattr *xdp)
 	if (mode == XDP_ATTACHED_NONE)
 		return;
 	else if (mode == XDP_ATTACHED_DRV)
-		fprintf(fp, "xdp ");
+		fprintf(fp, "xdp");
 	else if (mode == XDP_ATTACHED_SKB)
-		fprintf(fp, "xdpgeneric ");
+		fprintf(fp, "xdpgeneric");
 	else
-		fprintf(fp, "xdp[%u] ", mode);
+		fprintf(fp, "xdp[%u]", mode);
+
+	if (tb[IFLA_XDP_PROG_ID])
+		fprintf(fp, "/id:%u",
+			rta_getattr_u32(tb[IFLA_XDP_PROG_ID]));
+
+	fprintf(fp, " ");
 }
-- 
2.9.3
