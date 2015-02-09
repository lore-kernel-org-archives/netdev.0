From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 00/17] tipc: new compat layer
	for the legacy NL API
Date: Mon, 9 Feb 2015 09:50:02 +0100
Message-ID: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
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

From: Richard Alpe <richard.alpe@ericsson.com>

This is a compatibility / transcoding layer for the old netlink API.
It relies on the new netlink API to collect data or perform actions
(dumpit / doit).

The main benefit of this compat layer is that it removes a lot of
complex code from the tipc core as only the new API needs to be able
harness data or perform actions. I.e. the compat layer isn't concerned
with locking or how the internal data-structures look. As long as the
new API stays relatively intact the compat layer should be fine.

The main challenge in this compat layer is the randomness of the legacy
API. Some commands send binary data and some send ASCII data, some are
very picky in optimizing there buffer sizes and some just don't care.
Most legacy commands put there data in a single TLV (data container) but some
segment the data into multiple TLV's. This list of randomness goes on and on..

Richard Alpe (17):
  tipc: move and rename the legacy nl api to "nl compat"
  tipc: convert legacy nl bearer dump to nl compat
  tipc: convert legacy nl bearer enable/disable to nl compat
  tipc: convert legacy nl link stat to nl compat
  tipc: convert legacy nl link dump to nl compat
  tipc: convert legacy nl link prop set to nl compat
  tipc: convert legacy nl link stat reset to nl compat
  tipc: convert legacy nl name table dump to nl compat
  tipc: convert legacy nl socket dump to nl compat
  tipc: convert legacy nl media dump to nl compat
  tipc: convert legacy nl node dump to nl compat
  tipc: convert legacy nl node addr set to nl compat
  tipc: convert legacy nl net id set to nl compat
  tipc: convert legacy nl net id get to nl compat
  tipc: convert legacy nl stats show to nl compat
  tipc: nl compat add noop and remove legacy nl framework
  tipc: remove tipc_snprintf

 include/uapi/linux/tipc_config.h |   20 +
 net/tipc/Makefile                |    6 +-
 net/tipc/bcast.c                 |   45 +-
 net/tipc/bcast.h                 |    1 -
 net/tipc/bearer.c                |   86 +--
 net/tipc/bearer.h                |    5 -
 net/tipc/config.c                |  332 ------------
 net/tipc/config.h                |   67 ---
 net/tipc/core.c                  |   10 +-
 net/tipc/core.h                  |    3 -
 net/tipc/link.c                  |  325 +-----------
 net/tipc/link.h                  |    8 -
 net/tipc/log.c                   |   55 --
 net/tipc/name_table.c            |  190 +------
 net/tipc/name_table.h            |    2 -
 net/tipc/net.c                   |    6 +-
 net/tipc/netlink.c               |   67 +--
 net/tipc/netlink.h               |    4 +-
 net/tipc/netlink_compat.c        | 1084 ++++++++++++++++++++++++++++++++++++++
 net/tipc/node.c                  |  131 +----
 net/tipc/node.h                  |    4 -
 net/tipc/socket.c                |   90 +---
 net/tipc/socket.h                |    1 -
 23 files changed, 1147 insertions(+), 1395 deletions(-)
 delete mode 100644 net/tipc/config.c
 delete mode 100644 net/tipc/config.h
 delete mode 100644 net/tipc/log.c
 create mode 100644 net/tipc/netlink_compat.c

-- 
2.1.4


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
