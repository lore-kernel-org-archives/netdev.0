From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 7/9] samples/bpf: test both pre-alloc and normal maps
Date: Sun, 6 Mar 2016 17:58:35 -0800
Message-ID: <1457315917-1970307-8-git-send-email-ast@fb.com>
References: <1457315917-1970307-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Wang Nan <wangnan0@huawei.com>, He Kuang <hekuang@huawei.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38467 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751817AbcCGB6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2016 20:58:40 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u271riFQ028845
	for <netdev@vger.kernel.org>; Sun, 6 Mar 2016 17:58:40 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 21gwus0cvq-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 06 Mar 2016 17:58:40 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1c7c10d8e40811e59c950002c9dfb610-f55d7270 for <netdev@vger.kernel.org>;	Sun,
 06 Mar 2016 17:58:39 -0800
In-Reply-To: <1457315917-1970307-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

extend test coveraged to include pre-allocated and run-time alloc maps

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/test_maps.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index af02f7518c0a..d1e63f48e39c 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -468,7 +468,7 @@ static void test_map_parallel(void)
 	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
 }
 
-int main(void)
+static void run_all_tests(void)
 {
 	test_hashmap_sanity(0, NULL);
 	test_percpu_hashmap_sanity(0, NULL);
@@ -479,6 +479,14 @@ int main(void)
 	test_map_large();
 	test_map_parallel();
 	test_map_stress();
+}
+
+int main(void)
+{
+	map_flags = 0;
+	run_all_tests();
+	map_flags = BPF_F_NO_PREALLOC;
+	run_all_tests();
 	printf("test_maps: OK\n");
 	return 0;
 }
-- 
2.6.5
