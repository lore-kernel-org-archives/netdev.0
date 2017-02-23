From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net] bpf: Fix bpf_xdp_event_output
Date: Thu, 23 Feb 2017 10:40:34 -0800
Message-ID: <1487875234-886444-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kernel Team <kernel-team@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58240 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751170AbdBWSki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 13:40:38 -0500
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1NId2em020225
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 10:40:37 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28t3tnrbu5-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 10:40:37 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 9039a23cf9f711e6962424be05956610-302f3a00 for <netdev@vger.kernel.org>;        Thu,
 23 Feb 2017 10:40:35 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a typo. xdp->data instead of xdp should be copied to the perf-event's
dst_buff.

Fixes: 4de16969523c ("bpf: enable event output helper also for xdp types")
Reported-by: Huapeng Zhou <hzhou@fb.com>
Tested-by: Feixiong Zhang <feixiong@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 net/core/filter.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index e466e0040137..ebaeaf2e46e8 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2584,8 +2584,8 @@ BPF_CALL_5(bpf_xdp_event_output, struct xdp_buff *, xdp, struct bpf_map *, map,
 	if (unlikely(xdp_size > (unsigned long)(xdp->data_end - xdp->data)))
 		return -EFAULT;
 
-	return bpf_event_output(map, flags, meta, meta_size, xdp, xdp_size,
-				bpf_xdp_copy);
+	return bpf_event_output(map, flags, meta, meta_size, xdp->data,
+				xdp_size, bpf_xdp_copy);
 }
 
 static const struct bpf_func_proto bpf_xdp_event_output_proto = {
-- 
2.5.1
