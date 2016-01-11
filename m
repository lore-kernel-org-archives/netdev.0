From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 49/53] perf tools: Consider TAILSIZE bit when caclulate is_pos
Date: Mon, 11 Jan 2016 13:48:40 +0000
Message-ID: <1452520124-2073-50-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	He Kuang <hekuang@huawei.com>,
	"Arnaldo Carvalho de Melo" <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Namhyung Kim <namhyung@kernel.org>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

evsel->is_pos indicates event id location in a event (count backward).
It is used to find id for tracking events (mmap, exit...). If TAILSIZE
is selected, this location should be changed accordingly.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/util/evsel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/perf/util/evsel.c b/tools/perf/util/evsel.c
index 6932b8b..c59ea34 100644
--- a/tools/perf/util/evsel.c
+++ b/tools/perf/util/evsel.c
@@ -144,10 +144,10 @@ static int __perf_evsel__calc_id_pos(u64 sample_type)
  */
 static int __perf_evsel__calc_is_pos(u64 sample_type)
 {
-	int idx = 1;
+	int idx = 1 + (sample_type & PERF_SAMPLE_TAILSIZE ? 1 : 0);
 
 	if (sample_type & PERF_SAMPLE_IDENTIFIER)
-		return 1;
+		return idx;
 
 	if (!(sample_type & PERF_SAMPLE_ID))
 		return -1;
-- 
1.8.3.4
