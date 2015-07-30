From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 00/12] tipc: separate link
	aggregation from link layer
Date: Thu, 30 Jul 2015 18:24:14 -0400
Message-ID: <1438295066-29655-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
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

We continue the work on separating the roles of the link aggregation and
link layers, as well as making code cleanups in general.

This second commit batch focuses on moving the orchestration of link
failover and synchronization to the node level, as well as preparing the
node lock structure for further future impovements. We also make some
changes to message delivery between link and socket layer, in order to
make this mechanism safer and less obscure.


Jon Maloy (12):
  tipc: eliminate function tipc_link_activate()
  tipc: move all link_reset() calls to link aggregation level
  tipc: reverse call order for link_reset()->node_link_down()
  tipc: extend node FSM
  tipc: move link synch and failover to link aggregation level
  tipc: move protocol message sending away from link FSM
  tipc: merge link->exec_mode and link->state into one FSM
  tipc: move received discovery data evaluation inside node.c
  tipc: make resetting of links non-atomic
  tipc: remove implicit message delivery in node_unlock()
  tipc: use temporary, non-protected skb queue for bundle reception
  tipc: clean up link creation

 net/tipc/bearer.c   |    4 +-
 net/tipc/core.h     |    5 +
 net/tipc/discover.c |  116 +-----
 net/tipc/link.c     | 1060 +++++++++++++++++++--------------------------------
 net/tipc/link.h     |   61 ++-
 net/tipc/msg.h      |   83 ++--
 net/tipc/node.c     |  663 ++++++++++++++++++++++++--------
 net/tipc/node.h     |   41 +-
 8 files changed, 1009 insertions(+), 1024 deletions(-)

-- 
1.9.1


------------------------------------------------------------------------------
