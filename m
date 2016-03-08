From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 09/12] samples/bpf: test both pre-alloc and normal maps
Date: Mon, 7 Mar 2016 21:57:21 -0800
Message-ID: <1457416641-306326-10-git-send-email-ast@fb.com>
References: <1457416641-306326-1-git-send-email-ast@fb.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457416641-306326-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

extend test coveraged to include pre-allocated and run-time alloc maps

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/test_maps.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index 7bd9edd02d9b..47bf0858f9e4 100644
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
2.8.0.rc1
