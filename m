From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net] sch_tbf: use do_div() for 64-bit divide
Date: Thu, 12 Dec 2013 10:22:03 +0800
Message-ID: <1386814923-56180-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:44404 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751226Ab3LLCWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 21:22:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's doing a 64-bit divide which is not supported
on 32-bit architectures in psched_ns_t2l(). The
correct way to do this is to use do_div().

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/sch_tbf.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index a44928c..887e672 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -131,8 +131,10 @@ static u64 psched_ns_t2l(const struct psched_ratecfg *r,
 
 	do_div(len, NSEC_PER_SEC);
 
-	if (unlikely(r->linklayer == TC_LINKLAYER_ATM))
-		len = (len / 53) * 48;
+	if (unlikely(r->linklayer == TC_LINKLAYER_ATM)) {
+		do_div(len, 53);
+		len = len * 48;
+	}
 
 	if (len > r->overhead)
 		len -= r->overhead;
-- 
1.8.0
