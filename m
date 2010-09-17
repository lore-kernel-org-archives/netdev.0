From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [PATCH -tip] perf: Document of netdev-times perf script
Date: Fri, 17 Sep 2010 17:23:45 +0900
Message-ID: <4C932591.5090101@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com,
	acme@ghostprotocols.net, fweisbec@gmail.com, mingo@elte.hu,
	rostedt@goodmis.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a document of netdev-times which is used by perf.
This document shows how to use it.

Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
---
 tools/perf/Documentation/netdev-times.txt |   70 +++++++++++++++++++++++++++++
 1 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/tools/perf/Documentation/netdev-times.txt b/tools/perf/Documentation/netdev-times.txt
new file mode 100644
index 0000000..a905650
--- /dev/null
+++ b/tools/perf/Documentation/netdev-times.txt
@@ -0,0 +1,70 @@
+netdev-times(1)
+===============
+
+NAME
+----
+netdev-times - Tool to analysis packets processing
+
+SYNOPSIS
+--------
+'perf trace record netdev-times' [<script>]
+or
+'perf trace report netdev-times' [<options>]
+
+DESCRIPTION
+-----------
+This script shows packets processing and processed time.
+There are two steps to use it:
+
+ 'perf trace record netdev-times' [<script>] to record the events
+ which relates to packets processing.
+
+ 'perf trace report netdev-times' [<options>] to report a time-chart of
+ pakcets processing and processed time.
+
+OPTIONS
+-------
+tx::
+	Show only transmited packets processing.
+
+rx::
+	Show only received packets procssing.
+
+dev=<device>::
+	Show processing on the specified device.
+
+debug::
+	Work with debug mode. It shows buffer status.
+
+EXAMPLES
+--------
+If you want to use this, you need to record a perf.data like following.
+
+ # perf trace record netdev-times [<script>]
+
+If you set script, perf gathers events until it ends.
+If not, you must do Ctrl-C to stop recording.
+
+And if you want a report from the recorded data,
+
+ # perf trace report netdev-times [<options>]
+
+If you use some options, you can limit an output.
+For example, if you want to show a process of received packets associated
+with eth4,
+
+#perf trace report netdev-times rx dev=eth4
+106133.171439sec cpu=0
+  irq_entry(+0.000msec irq=24:eth4)
+         |
+  softirq_entry(+0.006msec)
+         |
+         |---netif_receive_skb(+0.010msec skb=f2d15900 len=100)
+         |            |
+         |      skb_copy_datagram_iovec(+0.039msec 10291::10291)
+         |
+  napi_poll_exit(+0.022msec eth4)
+
+SEE ALSO
+--------
+linkperf:perf-record[1], linkperf:perf-report[1], linkperf:perf-trace[1]
