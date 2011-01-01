From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/20] Delete more semi-useless stuff from TIPC.
Date: Fri, 31 Dec 2010 23:59:15 -0500
Message-ID: <1293857975-30267-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53095 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300Ab1AAE76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Dec 2010 23:59:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There really isn't a lot to see here technically.  There is a bunch of
stuff in TIPC that I guess falls into the category of "seemed like a
good idea at the time", but is now just inactive or at best unstable
prototype code for things like slave nodes and routing features and
mulitcluster support.  My favourite is this one:

 ----------
config TIPC_CLUSTERS
       int "Maximum number of clusters in a zone"
       depends on TIPC_ADVANCED
       range 1 1
       default "1"
       help
         Specifies how many clusters can be supported in a TIPC zone.

         *** Currently TIPC only supports a single cluster per zone. ***
 ----------

The remaining commits are just de-uglifying what is left, fixing whitespace
crimes and other common errors typically picked up in janitor patches.

Thanks,
Paul.

-----------------

Allan Stephens (19):
  tipc: Remove prototype code for supporting multiple zones
  tipc: Remove prototype code for supporting slave nodes
  tipc: Remove prototype code for supporting inter-cluster routing
  tipc: Remove prototype code for supporting multiple clusters
  tipc: Eliminate use of user registry by configuration service
  tipc: Eliminate use of user registry by topology service
  tipc: Remove user registry subsystem
  tipc: Remove internal linked list of node objects
  tipc: rename dbg.[ch] to log.[ch]
  tipc: remove calls to dbg() and msg_dbg()
  tipc: remove dump() and tipc_dump_dbg()
  tipc: Prune down link-specific debugging code
  tipc: Finish streamlining of debugging code
  tipc: remove redundant #includes
  tipc: remove pointless check for NULL prior to kfree
  tipc: cleanup various cosmetic whitespace issues
  tipc: split variable assignments out of conditional expressions
  tipc: remove zeroing assignments to static global variables
  tipc: remove extraneous braces from single statements

Paul Gortmaker (1):
  tipc: recode getsockopt error handling for better readability

 include/linux/tipc.h        |   18 +-
 include/linux/tipc_config.h |   76 +++----
 net/tipc/Kconfig            |   35 +--
 net/tipc/Makefile           |    4 +-
 net/tipc/addr.c             |    8 -
 net/tipc/addr.h             |   25 --
 net/tipc/bcast.c            |   42 +---
 net/tipc/bcast.h            |    1 +
 net/tipc/bearer.c           |   10 +-
 net/tipc/cluster.c          |  550 -------------------------------------------
 net/tipc/cluster.h          |   92 -------
 net/tipc/config.c           |  106 ++-------
 net/tipc/core.c             |   60 ++---
 net/tipc/core.h             |   64 +-----
 net/tipc/dbg.c              |  432 ---------------------------------
 net/tipc/dbg.h              |   67 ------
 net/tipc/discover.c         |   12 +-
 net/tipc/eth_media.c        |   11 +-
 net/tipc/handler.c          |    2 +-
 net/tipc/link.c             |  369 ++++++-----------------------
 net/tipc/link.h             |    9 +-
 net/tipc/log.c              |  351 +++++++++++++++++++++++++++
 net/tipc/log.h              |   67 ++++++
 net/tipc/msg.c              |   73 +++---
 net/tipc/msg.h              |   17 +-
 net/tipc/name_distr.c       |   45 ++--
 net/tipc/name_table.c       |   55 +----
 net/tipc/name_table.h       |    2 +-
 net/tipc/net.c              |   67 ++----
 net/tipc/net.h              |   14 +-
 net/tipc/node.c             |  294 ++++-------------------
 net/tipc/node.h             |   27 +--
 net/tipc/port.c             |   55 ++---
 net/tipc/port.h             |    9 +-
 net/tipc/ref.c              |    8 +-
 net/tipc/socket.c           |  148 +++++-------
 net/tipc/subscr.c           |   36 +--
 net/tipc/user_reg.c         |  218 -----------------
 net/tipc/user_reg.h         |   51 ----
 net/tipc/zone.c             |  159 -------------
 net/tipc/zone.h             |   70 ------
 41 files changed, 866 insertions(+), 2893 deletions(-)
 delete mode 100644 net/tipc/cluster.c
 delete mode 100644 net/tipc/cluster.h
 delete mode 100644 net/tipc/dbg.c
 delete mode 100644 net/tipc/dbg.h
 create mode 100644 net/tipc/log.c
 create mode 100644 net/tipc/log.h
 delete mode 100644 net/tipc/user_reg.c
 delete mode 100644 net/tipc/user_reg.h
 delete mode 100644 net/tipc/zone.c
 delete mode 100644 net/tipc/zone.h

-- 
1.7.3.3

