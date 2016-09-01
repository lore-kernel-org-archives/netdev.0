From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/3] tipc: improve broadcast NACK
	mechanism
Date: Thu,  1 Sep 2016 13:52:48 -0400
Message-ID: <1472752371-30338-1-git-send-email-jon.maloy@ericsson.com>
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

The broadcast protocol has turned out to not scale well beyond 70-80
nodes, while it is now possible to build TIPC clusters of at least ten
times that size. This commit series improves the NACK/retransmission
mechanism of the broadcast protocol to make is at scalable as the rest
of TIPC.

Jon Maloy (3):
  tipc: transfer broadcast nacks in link state messages
  tipc: rate limit broadcast retransmissions
  tipc: send broadcast nack directly upon sequence gap detection

 net/tipc/bcast.c |   8 ++--
 net/tipc/bcast.h |   4 +-
 net/tipc/link.c  | 131 ++++++++++++++++++++++++++++++++++++++++++++++---------
 net/tipc/link.h  |   6 +--
 net/tipc/msg.h   |  10 +++++
 net/tipc/node.c  |  32 +++++++++++++-
 net/tipc/node.h  |  11 +++--
 7 files changed, 167 insertions(+), 35 deletions(-)

-- 
2.7.4


------------------------------------------------------------------------------
