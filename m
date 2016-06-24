From: William Tu <u9012063@gmail.com>
Subject: [PATCH] samples/bpf: set resource limit to infinity.
Date: Fri, 24 Jun 2016 15:55:24 -0700
Message-ID: <1466808924-6456-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35506 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbcFXWzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 18:55:35 -0400
Received: by mail-pa0-f65.google.com with SMTP id hf6so10025135pac.2
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 15:55:34 -0700 (PDT)
Received: from vm-dev.localdomain ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id g26sm2383107pfj.82.2016.06.24.15.55.33
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 15:55:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: William Tu <u9012063@gmail.com>
---
 samples/bpf/test_maps.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index 47bf085..d2bc96e 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -16,6 +16,7 @@
 #include <assert.h>
 #include <sys/wait.h>
 #include <stdlib.h>
+#include <sys/resource.h>
 #include "libbpf.h"
 
 static int map_flags;
@@ -483,6 +484,9 @@ static void run_all_tests(void)
 
 int main(void)
 {
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
+
+	setrlimit(RLIMIT_MEMLOCK, &r);
 	map_flags = 0;
 	run_all_tests();
 	map_flags = BPF_F_NO_PREALLOC;
-- 
2.5.0
