From: Wei-Chun Chao <weichunc@plumgrid.com>
Subject: [PATCH net-next] bpf: fix verifier
Date: Wed, 12 Aug 2015 00:39:34 -0700
Message-ID: <1439365174-4285-1-git-send-email-weichunc@plumgrid.com>
Cc: davem@davemloft.net, ast@plumgrid.com, xiakaixu@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35962 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933463AbbHLHji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 03:39:38 -0400
Received: by pdco4 with SMTP id o4so4586081pdc.3
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 00:39:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrong array boundary is used.

Fixes: 35578d798400 bpf: Implement function bpf_perf_event_read())
Cc: Kaixu Xia <xiakaixu@huawei.com>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Signed-off-by: Wei-Chun Chao <weichunc@plumgrid.com>
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
