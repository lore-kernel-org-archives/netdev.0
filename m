From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 3/9] kasan: change allocation and freeing stack traces headers
Date: Tue, 28 Mar 2017 16:00:45 +0200
Message-ID: <7191548e9fda9658cea0d6a2313bc8ba0424e5c4.1490383597.git.andreyknvl__49933.8011876263$1490709697$gmane$org@google.com>
References: <cover.1490709552.git.andreyknvl@google.com>
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: "David S . Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Craig Gallek <cgallek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:34691 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751711AbdC1OBH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 10:01:07 -0400
Received: by mail-wr0-f182.google.com with SMTP id l43so106456672wre.1
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 07:01:06 -0700 (PDT)
In-Reply-To: <cover.1490709552.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change stack traces headers from:

Allocated:
PID = 42

to:

Allocated by task 42:

Makes the report one line shorter and look better.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index fc0577d15671..382d4d2b9052 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -175,9 +175,9 @@ static void kasan_end_report(unsigned long *flags)
 	kasan_enable_current();
 }
 
-static void print_track(struct kasan_track *track)
+static void print_track(struct kasan_track *track, const char *prefix)
 {
-	pr_err("PID = %u\n", track->pid);
+	pr_err("%s by task %u:\n", prefix, track->pid);
 	if (track->stack) {
 		struct stack_trace trace;
 
@@ -199,10 +199,8 @@ static void kasan_object_err(struct kmem_cache *cache, void *object)
 	if (!(cache->flags & SLAB_KASAN))
 		return;
 
-	pr_err("Allocated:\n");
-	print_track(&alloc_info->alloc_track);
-	pr_err("Freed:\n");
-	print_track(&alloc_info->free_track);
+	print_track(&alloc_info->alloc_track, "Allocated");
+	print_track(&alloc_info->free_track, "Freed");
 }
 
 void kasan_report_double_free(struct kmem_cache *cache, void *object,
-- 
2.12.1.578.ge9c3154ca4-goog
