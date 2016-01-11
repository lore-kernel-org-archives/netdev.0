From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 34/53] perf record: Use OPT_BOOLEAN_SET for buildid cache related options
Date: Mon, 11 Jan 2016 13:48:25 +0000
Message-ID: <1452520124-2073-35-git-send-email-wangnan0@huawei.com>
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

'perf record' knows whether buildid cache is enabled (via
--no-no-buildid-cache) deliberately. Buildid cache can be turned off
in some situations.

Output switching support needs this feature to turn off buildid cache
by default.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Signed-off-by: He Kuang <hekuang@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
Cc: Namhyung Kim <namhyung@kernel.org>
Cc: Zefan Li <lizefan@huawei.com>
Cc: pi3orama@163.com
---
 tools/perf/builtin-record.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/tools/perf/builtin-record.c b/tools/perf/builtin-record.c
index 91bf4b1..7a26cb5 100644
--- a/tools/perf/builtin-record.c
+++ b/tools/perf/builtin-record.c
@@ -50,7 +50,9 @@ struct record {
 	const char		*progname;
 	int			realtime_prio;
 	bool			no_buildid;
+	bool			no_buildid_set;
 	bool			no_buildid_cache;
+	bool			no_buildid_cache_set;
 	unsigned long long	samples;
 };
 
@@ -1176,10 +1178,12 @@ struct option __record_options[] = {
 	OPT_BOOLEAN('P', "period", &record.opts.period, "Record the sample period"),
 	OPT_BOOLEAN('n', "no-samples", &record.opts.no_samples,
 		    "don't sample"),
-	OPT_BOOLEAN('N', "no-buildid-cache", &record.no_buildid_cache,
-		    "do not update the buildid cache"),
-	OPT_BOOLEAN('B', "no-buildid", &record.no_buildid,
-		    "do not collect buildids in perf.data"),
+	OPT_BOOLEAN_SET('N', "no-buildid-cache", &record.no_buildid_cache,
+			&record.no_buildid_cache_set,
+			"do not update the buildid cache"),
+	OPT_BOOLEAN_SET('B', "no-buildid", &record.no_buildid,
+			&record.no_buildid_set,
+			"do not collect buildids in perf.data"),
 	OPT_CALLBACK('G', "cgroup", &record.evlist, "name",
 		     "monitor event in cgroup name only",
 		     parse_cgroups),
-- 
1.8.3.4
