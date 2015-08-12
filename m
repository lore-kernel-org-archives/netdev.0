From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: [PATCH v2 net-next] bpf: fix bpf_perf_event_read() loop upper bound
Date: Wed, 12 Aug 2015 07:57:12 -0700
Message-ID: <1439391432-4690-1-git-send-email-weichunc@plumgrid.com>
Cc: davem@davemloft.net, ast@plumgrid.com, xiakaixu@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:35887 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750949AbbHLO5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 10:57:17 -0400
Received: by pacrr5 with SMTP id rr5so16220275pac.3
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 07:57:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Verifier rejects programs incorrectly.

Fixes: 35578d798400 ("bpf: Implement function bpf_perf_event_read()")
Cc: Kaixu Xia <xiakaixu@huawei.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
---

v2: better subject line
---
 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 48e1c71..ed12e38 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -853,7 +853,7 @@ static int check_map_func_compatibility(struct bpf_map *map, int func_id)
 	if (!map)
 		return 0;
 
-	for (i = 0; i <= ARRAY_SIZE(func_limit); i++) {
+	for (i = 0; i < ARRAY_SIZE(func_limit); i++) {
 		bool_map = (map->map_type == func_limit[i].map_type);
 		bool_func = (func_id == func_limit[i].func_id);
 		/* only when map & func pair match it can continue.
-- 
1.9.1
