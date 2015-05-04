From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 0/5] tipc: cleanup topology server
Date: Mon, 4 May 2015 10:36:43 +0800
Message-ID: <1430707008-11141-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
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

Not only function names declared in subscr.c are very confused, but
also topology server's locking policy is not designed very well, for
instance, usually leading to panic in some special corner cases.

In this series, we attempt to eliminate the confusion of function names
and simplify topology server's locking policy to solve above mentioned
issues. More importantly, the change will make relevant code easily
understandable and maintainable.

Ying Xue (5):
  tipc: rename functions defined in subscr.c
  tipc: introduce tipc_subscrb_create routine
  tipc: involve reference counter for subscriber
  tipc: adjust locking policy of subscription
  tipc: deal with return value of tipc_conn_new callback

 net/tipc/core.c       |    4 +-
 net/tipc/name_table.c |   34 +++----
 net/tipc/server.c     |    4 +
 net/tipc/subscr.c     |  242 ++++++++++++++++++++++---------------------------
 net/tipc/subscr.h     |   18 ++--
 5 files changed, 137 insertions(+), 165 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
One dashboard for servers and applications across Physical-Virtual-Cloud 
Widest out-of-the-box monitoring support with 50+ applications
Performance metrics, stats and reports that give you Actionable Insights
Deep dive visibility with transaction tracing using APM Insight.
http://ad.doubleclick.net/ddm/clk/290420510;117567292;y
