From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 12/53] perf test: Reset err after using it hold errcode in hist testcases
Date: Mon, 11 Jan 2016 13:48:03 +0000
Message-ID: <1452520124-2073-13-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Jiri Olsa <jolsa@kernel.org>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All hists test cases forget to reset err after using it to hold an
error code. If error occure in setup_fake_machine() it incorrectly
return TEST_OK.

This patch fixes it.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Suggested-by: Namhyung Kim <namhyung@kernel.org>
Acked-by: Namhyung Kim <namhyung@kernel.org>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Jiri Olsa <jolsa@kernel.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>
---
 tools/perf/tests/hists_cumulate.c | 1 +
 tools/perf/tests/hists_filter.c   | 1 +
 tools/perf/tests/hists_link.c     | 1 +
 tools/perf/tests/hists_output.c   | 1 +
 4 files changed, 4 insertions(+)

diff --git a/tools/perf/tests/hists_cumulate.c b/tools/perf/tests/hists_cumulate.c
index e360892..5e6a86e 100644
--- a/tools/perf/tests/hists_cumulate.c
+++ b/tools/perf/tests/hists_cumulate.c
@@ -706,6 +706,7 @@ int test__hists_cumulate(int subtest __maybe_unused)
 	err = parse_events(evlist, "cpu-clock", NULL);
 	if (err)
 		goto out;
+	err = TEST_FAIL;
 
 	machines__init(&machines);
 
diff --git a/tools/perf/tests/hists_filter.c b/tools/perf/tests/hists_filter.c
index 2a784be..351a424 100644
--- a/tools/perf/tests/hists_filter.c
+++ b/tools/perf/tests/hists_filter.c
@@ -120,6 +120,7 @@ int test__hists_filter(int subtest __maybe_unused)
 	err = parse_events(evlist, "task-clock", NULL);
 	if (err)
 		goto out;
+	err = TEST_FAIL;
 
 	/* default sort order (comm,dso,sym) will be used */
 	if (setup_sorting(NULL) < 0)
diff --git a/tools/perf/tests/hists_link.c b/tools/perf/tests/hists_link.c
index c764d69..64b257d 100644
--- a/tools/perf/tests/hists_link.c
+++ b/tools/perf/tests/hists_link.c
@@ -293,6 +293,7 @@ int test__hists_link(int subtest __maybe_unused)
 	if (err)
 		goto out;
 
+	err = TEST_FAIL;
 	/* default sort order (comm,dso,sym) will be used */
 	if (setup_sorting(NULL) < 0)
 		goto out;
diff --git a/tools/perf/tests/hists_output.c b/tools/perf/tests/hists_output.c
index ebe6cd4..b231265 100644
--- a/tools/perf/tests/hists_output.c
+++ b/tools/perf/tests/hists_output.c
@@ -597,6 +597,7 @@ int test__hists_output(int subtest __maybe_unused)
 	err = parse_events(evlist, "cpu-clock", NULL);
 	if (err)
 		goto out;
+	err = TEST_FAIL;
 
 	machines__init(&machines);
 
-- 
1.8.3.4
