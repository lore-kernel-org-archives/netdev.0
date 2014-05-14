From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 0/8] tipc: bug fixes and
	improvements
Date: Wed, 14 May 2014 05:39:07 -0400
Message-ID: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
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

Intensive and extensive testing has revealed some rather infrequent
problems related to flow control, buffer handling and link
establishment. Commits ##1 to 4 deal with these problems.

The remaining four commits are just code improvments, aiming at
making the code more comprehensible and maintainable. There are
no functional enhancements in this series.

v2: Fixed a typo in commit log #2. Otherwise no changes from v1.


Jon Maloy (8):
  tipc: decrease connection flow control window
  tipc: compensate for double accounting in socket rcv buffer
  tipc: don't record link RESET or ACTIVATE messages as traffic
  tipc: mark head of reassembly buffer as non-linear
  tipc: rename and move message reassembly function
  tipc: improve and extend media address conversion functions
  tipc: clean up neigbor discovery message reception
  tipc: merge port message reception into socket reception function

 net/tipc/bcast.c     |   10 +--
 net/tipc/bearer.c    |   36 ++------
 net/tipc/bearer.h    |   35 ++++----
 net/tipc/core.c      |    7 +-
 net/tipc/core.h      |    2 +
 net/tipc/discover.c  |  221 +++++++++++++++++++++++++-------------------------
 net/tipc/eth_media.c |   51 +++++++-----
 net/tipc/ib_media.c  |   34 +++++---
 net/tipc/link.c      |   75 +++--------------
 net/tipc/link.h      |   14 +---
 net/tipc/msg.c       |   55 ++++++++++++-
 net/tipc/msg.h       |    5 +-
 net/tipc/net.c       |    3 +-
 net/tipc/node.c      |    7 +-
 net/tipc/node.h      |    6 +-
 net/tipc/port.c      |   39 +--------
 net/tipc/port.h      |   10 +--
 net/tipc/socket.c    |   85 ++++++++++++-------
 net/tipc/socket.h    |    4 +-
 19 files changed, 348 insertions(+), 351 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
