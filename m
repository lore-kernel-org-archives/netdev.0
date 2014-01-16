From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH iproute2 v2 1/2] tbf: support sending burst/mtu to kernel directly
Date: Thu, 16 Jan 2014 11:09:13 +0800
Message-ID: <1389841754-22008-2-git-send-email-yangyingliang@huawei.com>
References: <1389841754-22008-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:20689 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522AbaAPDJo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 22:09:44 -0500
In-Reply-To: <1389841754-22008-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To avoid loss when transforming burst to buffer in userspace, send
burst/mtu to kernel directly.

Kernel commit 2e04ad424b("sch_tbf: add TBF_BURST/TBF_PBURST attribute")
make it can handle burst/mtu.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 tc/q_tbf.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/tc/q_tbf.c b/tc/q_tbf.c
index 2fbfd3b..f3022b6 100644
--- a/tc/q_tbf.c
+++ b/tc/q_tbf.c
@@ -232,12 +232,14 @@ static int tbf_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nl
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	addattr_l(n, 2024, TCA_TBF_PARMS, &opt, sizeof(opt));
+	addattr_l(n, 2124, TCA_TBF_BURST, &buffer, sizeof(buffer));
 	if (rate64 >= (1ULL << 32))
 		addattr_l(n, 2124, TCA_TBF_RATE64, &rate64, sizeof(rate64));
 	addattr_l(n, 3024, TCA_TBF_RTAB, rtab, 1024);
 	if (opt.peakrate.rate) {
 		if (prate64 >= (1ULL << 32))
 			addattr_l(n, 3124, TCA_TBF_PRATE64, &prate64, sizeof(prate64));
+		addattr_l(n, 3224, TCA_TBF_PBURST, &mtu, sizeof(mtu));
 		addattr_l(n, 4096, TCA_TBF_PTAB, ptab, 1024);
 	}
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
-- 
1.8.0
