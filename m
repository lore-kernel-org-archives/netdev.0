From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next] net: dst: move cpu inside ifdef to avoid compilation warning
Date: Tue, 10 Oct 2017 15:05:39 -0700
Message-ID: <20171010220539.21200-1-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:46000 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754108AbdJJWFz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 18:05:55 -0400
Received: by mail-pf0-f173.google.com with SMTP id d28so3967526pfe.2
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 15:05:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If CONFIG_DST_CACHE is not selected cpu variable
will be unused and we will see a compilation warning.
Move it under the ifdef.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Fixes: d66f2b91f95b ("bpf: don't rely on the verifier lock for metadata_dst allocation")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 net/core/dst.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 8b2eafac984d..662a2d4a3d19 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -325,9 +325,9 @@ EXPORT_SYMBOL_GPL(metadata_dst_alloc_percpu);
 
 void metadata_dst_free_percpu(struct metadata_dst __percpu *md_dst)
 {
+#ifdef CONFIG_DST_CACHE
 	int cpu;
 
-#ifdef CONFIG_DST_CACHE
 	for_each_possible_cpu(cpu) {
 		struct metadata_dst *one_md_dst = per_cpu_ptr(md_dst, cpu);
 
-- 
2.14.1
