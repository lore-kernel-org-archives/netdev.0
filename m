From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 00/17] tipc: Merge port and
	socket layer code
Date: Fri, 22 Aug 2014 18:09:03 -0400
Message-ID: <1408745360-23560-1-git-send-email-jon.maloy@ericsson.com>
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

After the removal of the TIPC native interface, there is no reason to
keep a distinction between a "generic" port layer and a "specific"
socket layer in the code. Throughout the last months, we have posted
several series that aimed at facilitating removal of the port layer,
and in particular the port_lock spinlock, which in reality duplicates
the role normally kept by lock_sock()/bh_lock_sock().

In this series, we finalize this work, by making a significant number of
changes to the link, node, port and socket code, all with the aim of
reducing dependencies between the layers. In the final commits, we then
remove the port spinlock, port.c and port.h altogether.

After this series, we have a socket layer that has only few dependencies
to the rest of the stack, so that it should be possible to continue
cleanups of its code without significantly affecting other code.

It should be noted that commit ##1 and 2 are already in 'net' 
(ac32c7f705692b92fe12dcbe88fe87136fdfff6f and 
02784f1b05b8f241c8180af88869e717e2758593), but not yet in net-next.
Since they are prerequisites for the rest of the series to apply, I
prepend them to the series.

David S. Miller (1):
  tipc: Fix build.

Erik Hugne (1):
  tipc: fix message importance range check

Jon Maloy (15):
  tipc: introduce new function tipc_msg_create()
  tipc: use pseudo message to wake up sockets after link congestion
  tipc: use message to abort connections when losing contact to node
  tipc: clean up socket timer function
  tipc: eliminate function tipc_port_shutdown()
  tipc: eliminate port_connect()/port_disconnect() functions
  tipc: redefine message acknowledge function
  tipc: eliminate functions tipc_port_init and tipc_port_destroy
  tipc: use registry when scanning sockets
  tipc: replace port pointer with socket pointer in registry
  tipc: remove port_lock
  tipc: remove source file port.c
  tipc: remove include file port.h
  tipc: remove files ref.h and ref.c
  tipc: merge struct tipc_port into struct tipc_sock

 net/tipc/Makefile     |    2 +-
 net/tipc/bcast.c      |    8 +-
 net/tipc/config.c     |    4 +-
 net/tipc/core.c       |    9 +-
 net/tipc/core.h       |    5 +-
 net/tipc/link.c       |  120 +++----
 net/tipc/link.h       |    7 +-
 net/tipc/msg.c        |   38 ++-
 net/tipc/msg.h        |    5 +
 net/tipc/name_table.c |    1 -
 net/tipc/net.c        |    3 +-
 net/tipc/node.c       |   90 +++++
 net/tipc/node.h       |    7 +-
 net/tipc/port.c       |  514 ----------------------------
 net/tipc/port.h       |  187 -----------
 net/tipc/ref.c        |  266 ---------------
 net/tipc/ref.h        |   48 ---
 net/tipc/socket.c     |  884 +++++++++++++++++++++++++++++++++++++++++--------
 net/tipc/socket.h     |   55 +--
 net/tipc/subscr.c     |    1 -
 20 files changed, 956 insertions(+), 1298 deletions(-)
 delete mode 100644 net/tipc/port.c
 delete mode 100644 net/tipc/port.h
 delete mode 100644 net/tipc/ref.c
 delete mode 100644 net/tipc/ref.h

-- 
1.7.9.5


------------------------------------------------------------------------------
Slashdot TV.  
Video for Nerds.  Stuff that matters.
http://tv.slashdot.org/
