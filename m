From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 00/16] tipc: make tipc support
	namespace
Date: Fri, 9 Jan 2015 15:26:57 +0800
Message-ID: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
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

This patchset aims to add net namespace support for TIPC stack.

Currently TIPC module declares the following global resources:
- TIPC network idenfication number
- TIPC node table
- TIPC bearer list table
- TIPC broadcast link
- TIPC socket reference table
- TIPC name service table
- TIPC node address
- TIPC service subscriber server
- TIPC random value
- TIPC netlink

In order that TIPC is aware of namespace, above each resource must be
allocated, initialized and destroyed inside per namespace. Therefore,
the major works of this patchset are to isolate these global resources
and make them private for each namespace. However, before these changes
come true, some necessary preparation works must be first done: convert
socket reference table with generic rhashtable, cleanup core.c and
core.h files, remove unnecessary wrapper functions for kernel timer
interfaces and so on.

It should be noted that commit ##1 ("tipc: fix bug in broadcast
retransmit code") was already submitted to 'net' tree, so please see
below link:

http://patchwork.ozlabs.org/patch/426717/

Since it is prerequisite for the rest of the series to apply, I
prepend them to the series.

Jon Maloy (1):
  tipc: fix bug in broadcast retransmit code

Ying Xue (15):
  tipc: remove tipc_core_start/stop routines
  tipc: remove unnecessary wrapper functions of kernel timer APIs
  tipc: cleanup core.c and core.h files
  tipc: feed tipc sock pointer to tipc_sk_timeout routine
  tipc: remove unused tipc_link_get_max_pkt routine
  tipc: involve namespace infrastructure
  tipc: make tipc node table aware of net namespace
  tipc: make bearer list support net namespace
  tipc: make tipc broadcast link support net namespace
  tipc: make tipc socket support net namespace
  tipc: name tipc name table support net namespace
  tipc: make tipc node address support net namespace
  tipc: make subscriber server support net namespace
  tipc: make tipc random value aware of net namespace
  tipc: make netlink support net namespace

 net/tipc/addr.c       |   45 +++++-
 net/tipc/addr.h       |   45 ++----
 net/tipc/bcast.c      |  372 ++++++++++++++++++++++++-------------------------
 net/tipc/bcast.h      |  113 ++++++++++-----
 net/tipc/bearer.c     |  141 ++++++++++---------
 net/tipc/bearer.h     |   46 +++---
 net/tipc/config.c     |   66 +++++----
 net/tipc/config.h     |    6 +-
 net/tipc/core.c       |  140 ++++++++-----------
 net/tipc/core.h       |  167 ++++++----------------
 net/tipc/discover.c   |   84 ++++++-----
 net/tipc/discover.h   |    8 +-
 net/tipc/link.c       |  322 +++++++++++++++++++++++-------------------
 net/tipc/link.h       |   36 +++--
 net/tipc/msg.c        |   71 +++++++---
 net/tipc/msg.h        |   60 +++++---
 net/tipc/name_distr.c |  115 ++++++++-------
 net/tipc/name_distr.h |   16 +--
 net/tipc/name_table.c |  180 +++++++++++++-----------
 net/tipc/name_table.h |   33 ++---
 net/tipc/net.c        |   54 ++++---
 net/tipc/net.h        |    4 +-
 net/tipc/netlink.c    |   17 ++-
 net/tipc/netlink.h    |    3 +
 net/tipc/node.c       |  159 +++++++++++----------
 net/tipc/node.h       |   35 ++---
 net/tipc/server.c     |    6 +-
 net/tipc/server.h     |   17 ++-
 net/tipc/socket.c     |  255 ++++++++++++++++++---------------
 net/tipc/socket.h     |   19 ++-
 net/tipc/subscr.c     |  131 +++++++++--------
 net/tipc/subscr.h     |   14 +-
 32 files changed, 1503 insertions(+), 1277 deletions(-)

-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
