From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 9/9] kasan: separate report parts by empty lines
Date: Tue, 28 Mar 2017 16:00:54 +0200
Message-ID: <b0d3a20a010c7b50367b06c9e840d18680f31a02.1490383597.git.andreyknvl__27685.1895418533$1490709712$gmane$org@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f54.google.com ([209.85.215.54]:35808 "EHLO
        mail-lf0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753528AbdC1OBc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:32 -0400
Received: by mail-lf0-f54.google.com with SMTP id j90so38858059lfk.2
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:26 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Makes the report easier to read.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 2368b8cf5f95..a79fc1036161 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -218,7 +218,9 @@ static void describe_object(struct kmem_cache *cache, void *object,
 
 	if (cache->flags & SLAB_KASAN) {
 		print_track(&alloc_info->alloc_track, "Allocated");
+		pr_err("\n");
 		print_track(&alloc_info->free_track, "Freed");
+		pr_err("\n");
 	}
 
 	describe_object_addr(cache, object, addr);
@@ -229,6 +231,7 @@ static void print_address_description(void *addr)
 	struct page *page = addr_to_page(addr);
 
 	dump_stack();
+	pr_err("\n");
 
 	if (page && PageSlab(page)) {
 		struct kmem_cache *cache = page->slab_cache;
@@ -307,7 +310,9 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
 
 	kasan_start_report(&flags);
 	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", ip);
+	pr_err("\n");
 	print_address_description(object);
+	pr_err("\n");
 	print_shadow_for_address(object);
 	kasan_end_report(&flags);
 }
@@ -319,11 +324,13 @@ static void kasan_report_error(struct kasan_access_info *info)
 	kasan_start_report(&flags);
 
 	print_error_description(info);
+	pr_err("\n");
 
 	if (!addr_has_shadow(info)) {
 		dump_stack();
 	} else {
 		print_address_description((void *)info->access_addr);
+		pr_err("\n");
 		print_shadow_for_address(info->first_bad_addr);
 	}
 
-- 
2.12.1.578.ge9c3154ca4-goog
