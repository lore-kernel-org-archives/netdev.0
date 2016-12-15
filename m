From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH] bpf: cgroup: annotate pointers in struct cgroup_bpf with __rcu
Date: Thu, 15 Dec 2016 10:53:21 +0100
Message-ID: <20161215095321.10571-1-daniel@zonque.org>
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, davem@davemloft.net,
        Daniel Mack <daniel@zonque.org>
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:55718 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752534AbcLOKE2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 05:04:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The member 'effective' in 'struct cgroup_bpf' is protected by RCU.
Annotate it accordingly to squelch a sparse warning.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/linux/bpf-cgroup.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 7b6e5d1..92bc89a 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -20,7 +20,7 @@ struct cgroup_bpf {
 	 * when this cgroup is accessed.
 	 */
 	struct bpf_prog *prog[MAX_BPF_ATTACH_TYPE];
-	struct bpf_prog *effective[MAX_BPF_ATTACH_TYPE];
+	struct bpf_prog __rcu *effective[MAX_BPF_ATTACH_TYPE];
 };
 
 void cgroup_bpf_put(struct cgroup *cgrp);
-- 
2.9.3
