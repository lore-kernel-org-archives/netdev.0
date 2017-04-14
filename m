From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 2/6] bpf: lru: Cleanup test_lru_map.c
Date: Fri, 14 Apr 2017 10:30:26 -0700
Message-ID: <20170414173030.2853860-3-kafai@fb.com>
References: <20170414173030.2853860-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49890 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754002AbdDNRac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 13:30:32 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3EHNSVg030510
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 29u27a087e-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:31 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 0e77b398213811e7b9420002c9dfb610-5d7f09a0 for <netdev@vger.kernel.org>;        Fri,
 14 Apr 2017 10:30:30 -0700
In-Reply-To: <20170414173030.2853860-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does the following cleanup on test_lru_map.c
1) Fix indentation (Replace spaces by tabs)
2) Remove redundant BPF_F_NO_COMMON_LRU test
3) Simplify some comments

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/testing/selftests/bpf/test_lru_map.c | 32 +++++++++---------------------
 1 file changed, 9 insertions(+), 23 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 04b2242937cc..87c05e5bdfdd 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -191,12 +191,7 @@ static void test_lru_sanity1(int map_type, int map_flags, unsigned int tgt_free)
 	int next_cpu = 0;
 
 	if (map_flags & BPF_F_NO_COMMON_LRU)
-		/* Ther percpu lru list (i.e each cpu has its own LRU
-		 * list) does not have a local free list.  Hence,
-		 * it will only free old nodes till there is no free
-		 * from the LRU list.  Hence, this test does not apply
-		 * to BPF_F_NO_COMMON_LRU
-		 */
+		/* This test is only applicable to common LRU list */
 		return;
 
 	printf("%s (map_type:%d map_flags:0x%X): ", __func__, map_type,
@@ -227,7 +222,7 @@ static void test_lru_sanity1(int map_type, int map_flags, unsigned int tgt_free)
 	for (key = 1; key < end_key; key++) {
 		assert(!bpf_map_lookup_elem(lru_map_fd, &key, value));
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
-				            BPF_NOEXIST));
+					    BPF_NOEXIST));
 	}
 
 	/* Insert 1+tgt_free to 2*tgt_free
@@ -273,12 +268,7 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 	int next_cpu = 0;
 
 	if (map_flags & BPF_F_NO_COMMON_LRU)
-		/* Ther percpu lru list (i.e each cpu has its own LRU
-		 * list) does not have a local free list.  Hence,
-		 * it will only free old nodes till there is no free
-		 * from the LRU list.  Hence, this test does not apply
-		 * to BPF_F_NO_COMMON_LRU
-		 */
+		/* This test is only applicable to common LRU list */
 		return;
 
 	printf("%s (map_type:%d map_flags:0x%X): ", __func__, map_type,
@@ -290,11 +280,7 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 	assert(batch_size * 2 == tgt_free);
 
 	map_size = tgt_free + batch_size;
-	if (map_flags & BPF_F_NO_COMMON_LRU)
-		lru_map_fd = create_map(map_type, map_flags,
-					map_size * nr_cpus);
-	else
-		lru_map_fd = create_map(map_type, map_flags, map_size);
+	lru_map_fd = create_map(map_type, map_flags, map_size);
 	assert(lru_map_fd != -1);
 
 	expected_map_fd = create_map(BPF_MAP_TYPE_HASH, 0, map_size);
@@ -341,7 +327,7 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 		assert(!bpf_map_lookup_elem(lru_map_fd, &key, value));
 		assert(value[0] == 4321);
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
-				            BPF_NOEXIST));
+					    BPF_NOEXIST));
 	}
 
 	value[0] = 1234;
@@ -361,7 +347,7 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 		assert(!bpf_map_update_elem(lru_map_fd, &key, value,
 					    BPF_NOEXIST));
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
-				            BPF_NOEXIST));
+					    BPF_NOEXIST));
 	}
 
 	assert(map_equal(lru_map_fd, expected_map_fd));
@@ -419,7 +405,7 @@ static void test_lru_sanity3(int map_type, int map_flags, unsigned int tgt_free)
 	for (key = 1; key < end_key; key++) {
 		assert(!bpf_map_lookup_elem(lru_map_fd, &key, value));
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
-				            BPF_NOEXIST));
+					    BPF_NOEXIST));
 	}
 
 	/* Add 1+2*tgt_free to tgt_free*5/2
@@ -431,7 +417,7 @@ static void test_lru_sanity3(int map_type, int map_flags, unsigned int tgt_free)
 		assert(!bpf_map_update_elem(lru_map_fd, &key, value,
 					    BPF_NOEXIST));
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
-				            BPF_NOEXIST));
+					    BPF_NOEXIST));
 	}
 
 	assert(map_equal(lru_map_fd, expected_map_fd));
@@ -491,7 +477,7 @@ static void test_lru_sanity4(int map_type, int map_flags, unsigned int tgt_free)
 		assert(!bpf_map_update_elem(lru_map_fd, &key, value,
 					    BPF_NOEXIST));
 		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
-				            BPF_NOEXIST));
+					    BPF_NOEXIST));
 	}
 
 	assert(map_equal(lru_map_fd, expected_map_fd));
-- 
2.9.3
