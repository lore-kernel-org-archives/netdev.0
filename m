From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: [PATCH 1/3] drop_monitor: fix trace_napi_poll_hit()
Date: Thu, 27 Aug 2009 18:40:08 +0800
Message-ID: <4A966288.8020402@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751168AbZH0Kkn@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The net_dev of backlog napi is NULL, like below:

__get_cpu_var(softnet_data).backlog.dev == NULL

So, we should check it in napi tracepoint's probe function

Signed-off-by: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
---
 net/core/drop_monitor.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 9d66fa9..d311202 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -182,7 +182,8 @@ static void trace_napi_poll_hit(struct napi_struct *napi)
 	/*
 	 * Ratelimit our check time to dm_hw_check_delta jiffies
 	 */
-	if (!time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
+	if (!napi->dev ||
+	    !time_after(jiffies, napi->dev->last_rx + dm_hw_check_delta))
 		return;
 
 	rcu_read_lock();
-- 
1.6.1.2
