From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 10/53] tools build: Add BPF feature check to test-all
Date: Mon, 11 Jan 2016 13:48:01 +0000
Message-ID: <1452520124-2073-11-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	"Namhyung Kim" <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Existing test-all.c doesn't check BPF related features. For environment
with all other features enabled, BPF would be considered enabled
without doing real feature check.

This patch adds test-bpf.c into test-all.c.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Acked-by: Jiri Olsa <jolsa@redhat.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Namhyung Kim <namhyung@kernel.org>
---
 tools/build/feature/test-all.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/tools/build/feature/test-all.c b/tools/build/feature/test-all.c
index 33cf6f2..81025ca 100644
--- a/tools/build/feature/test-all.c
+++ b/tools/build/feature/test-all.c
@@ -125,6 +125,10 @@
 # include "test-get_cpuid.c"
 #undef main
 
+#define main main_test_bpf
+# include "test-bpf.c"
+#undef main
+
 int main(int argc, char *argv[])
 {
 	main_test_libpython();
@@ -153,6 +157,7 @@ int main(int argc, char *argv[])
 	main_test_pthread_attr_setaffinity_np();
 	main_test_lzma();
 	main_test_get_cpuid();
+	main_test_bpf();
 
 	return 0;
 }
-- 
1.8.3.4
