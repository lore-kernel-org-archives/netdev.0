From: John Fastabend <john.fastabend@gmail.com>
Subject: [PATCH] bpf: testing: fix devmap tests
Date: Wed, 26 Jul 2017 17:32:07 -0700
Message-ID: <20170727003206.16649.50637.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, jakub.kicinski@netronome.com,
        daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33568 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751078AbdG0AcT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 20:32:19 -0400
Received: by mail-pf0-f194.google.com with SMTP id k72so13276756pfj.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 17:32:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apparently through one of my revisions of the initial patches
series I lost the devmap test. We can add more testing later but
for now lets fix the simple one we have.

Fixes: 546ac1ffb70d "bpf: add devmap, a map for storing net device references"
Reported-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 tools/testing/selftests/bpf/test_maps.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index ce2988b..1579cab 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -104,6 +104,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_LPM_TRIE,
 	BPF_MAP_TYPE_ARRAY_OF_MAPS,
 	BPF_MAP_TYPE_HASH_OF_MAPS,
+	BPF_MAP_TYPE_DEVMAP,
 };
 
 enum bpf_prog_type {
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index 36d6ac3..c991ab6 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -440,7 +440,7 @@ static void test_arraymap_percpu_many_keys(void)
 
 static void test_devmap(int task, void *data)
 {
-	int next_key, fd;
+	int fd;
 	__u32 key, value;
 
 	fd = bpf_create_map(BPF_MAP_TYPE_DEVMAP, sizeof(key), sizeof(value),
@@ -620,6 +620,8 @@ static void run_all_tests(void)
 
 	test_arraymap_percpu_many_keys();
 
+	test_devmap(0, NULL);
+
 	test_map_large();
 	test_map_parallel();
 	test_map_stress();
