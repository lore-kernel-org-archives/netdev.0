From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 7/9] kasan: print page description after stacks
Date: Tue, 28 Mar 2017 16:00:52 +0200
Message-ID: <06d2e8e2e4ae9f2794fa8026c292fb90eb9e362c.1490383597.git.andreyknvl__46625.163316685$1490709722$gmane$org@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f172.google.com ([209.85.128.172]:33034 "EHLO
        mail-wr0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752743AbdC1OBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:32 -0400
Received: by mail-wr0-f172.google.com with SMTP id w43so92176309wrb.0
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:12 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves page description after the stacks since it's less important.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 06e27a342d1d..e0f7dbf9e883 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -242,9 +242,6 @@ static void print_address_description(struct kasan_access_info *info)
 	void *addr = (void *)info->access_addr;
 	struct page *page = addr_to_page(addr);
 
-	if (page)
-		dump_page(page, "kasan: bad access detected");
-
 	dump_stack();
 
 	if (page && PageSlab(page)) {
@@ -254,9 +251,14 @@ static void print_address_description(struct kasan_access_info *info)
 		describe_object(cache, object, addr);
 	}
 
-	if (kernel_or_module_addr(addr)) {
-		if (!init_task_stack_addr(addr))
-			pr_err("Address belongs to variable %pS\n", addr);
+	if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
+		pr_err("The buggy address belongs to the variable:\n");
+		pr_err(" %pS\n", addr);
+	}
+
+	if (page) {
+		pr_err("The buggy address belongs to the page:\n");
+		dump_page(page, "kasan: bad access detected");
 	}
 }
 
-- 
2.12.1.578.ge9c3154ca4-goog
