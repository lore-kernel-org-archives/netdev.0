From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 00/10] tipc: cleanups,
	fixes & improvements for topology server
Date: Tue, 2 Feb 2016 10:52:07 +0100
Message-ID: <1454406737-5806-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This series contains topology server cleanups, fixes and improvements.

Cleanups in #1-#4:
We remove duplicate data structures and aligin the rest of the code accordingly.

Fixes in #5-#8:
The bugs occur either during configuration or while running on SMP targets,
which are race conditions that pop up under different situations.

Improvements in #9-#10:
Updates to decrease timer usage and improve readability.

v2: Updated commit message in patch 6 based on feedback from
    Sergei Shtylyov sergei.shtylyov@cogentembedded.com

Parthasarathy Bhuvaragan (10):
  tipc: remove incorrect check for subscription timeout value
  tipc: remove filter and timeout elements from struct tipc_subscription
  tipc: remove struct tipc_name_seq from struct tipc_subscription
  tipc: introduce tipc_subscrb_subscribe() routine
  tipc: fix connection abort during subscription cancellation
  tipc: fix connection abort when receiving invalid cancel request
  tipc: hold subscriber->lock for tipc_nametbl_subscribe()
  tipc: protect tipc_subscrb_get() with subscriber spin lock
  tipc: donot create timers if subscription timeout = TIPC_WAIT_FOREVER
  tipc: use alloc_ordered_workqueue() instead of WQ_UNBOUND w/
    max_active = 1

 net/tipc/name_table.c |  14 ++++--
 net/tipc/server.c     |   4 +-
 net/tipc/subscr.c     | 131 ++++++++++++++++++++++++++++++--------------------
 net/tipc/subscr.h     |  11 ++---
 4 files changed, 96 insertions(+), 64 deletions(-)

-- 
2.1.4


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
