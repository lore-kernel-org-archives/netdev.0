From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 37/53] perf record: Force enable --timestamp-filename when --switch-output is provided
Date: Mon, 11 Jan 2016 13:48:28 +0000
Message-ID: <1452520124-2073-38-git-send-email-wangnan0@huawei.com>
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

Without this patch, the last output doesn't have timestamp appended if
--timestamp-filename is not explicitly provided. For example:

 # perf record -a --switch-output &
 [1] 11224
 # kill -s SIGUSR2 11224
 [ perf record: dump data: Woken up 1 times ]
 # [ perf record: Dump perf.data.2015122622372823 ]

 # fg
 perf record -a --switch-output
 ^C[ perf record: Woken up 1 times to write data ]
 [ perf record: Captured and wrote 0.027 MB perf.data (540 samples) ]

 # ls -l
 total 836
 -rw------- 1 root root  33256 Dec 26 22:37 perf.data   <---- *Odd*
 -rw------- 1 root root 817156 Dec 26 22:37 perf.data.2015122622372823

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index e8f930c..d32facd 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -1343,6 +1343,9 @@ int cmd_record(int argc, const char **argv, const char *prefix __maybe_unused)
 		return -EINVAL;
 	}
 
+	if (rec->switch_output)
+		rec->timestamp_filename = true;
+
 	if (!rec->itr) {
 		rec->itr = auxtrace_record__init(rec->evlist, &err);
 		if (err)
-- 
1.8.3.4
