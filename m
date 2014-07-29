From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: [PATCH 0/2 net-next] Lockless netlink_lookup() with new
	concurrent hash table
Date: Tue, 29 Jul 2014 13:41:31 +0200
Message-ID: <cover.1406633945.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org,
 paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, walpole-sKt6ljEC1JY3uPMLIKxrzw@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Netlink sockets are maintained in a hash table to allow efficient lookup
via the port ID for unicast messages. However, lookups currently require
a read lock to be taken. This series adds a new generic, resizable,
scalable, concurrent hash table based on the paper referenced in the first
patch. It then makes use of the new data type to implement lockless
netlink_lookup().

Against net-next since the initial user of the new hash table is in net/

Thomas Graf (2):
  lib: Resizable, Scalable, Concurrent Hash Table
  netlink: Convert netlink_lookup() to use RCU protected hash table

 include/linux/rhashtable.h | 208 ++++++++++++
 lib/Kconfig.debug          |   8 +
 lib/Makefile               |   2 +-
 lib/rhashtable.c           | 783 +++++++++++++++++++++++++++++++++++++++++++++
 net/netlink/af_netlink.c   | 285 +++++++----------
 net/netlink/af_netlink.h   |  18 +-
 net/netlink/diag.c         |  11 +-
 7 files changed, 1119 insertions(+), 196 deletions(-)
 create mode 100644 include/linux/rhashtable.h
 create mode 100644 lib/rhashtable.c

-- 
1.9.3
