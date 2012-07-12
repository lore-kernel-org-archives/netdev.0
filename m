From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/8] tipc: kill off struct print_buf/log
Date: Thu, 12 Jul 2012 12:39:53 -0400
Message-ID: <1342111201-9426-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>, ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43523 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161220Ab2GLQk0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2012 12:40:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

The main thrust of what happens in this series is to deal with
the request you'd made a while ago about making it so TIPC did
not have its own specific (and complex) logging infrastructure.

It used to have tipc_printf taking an arg of this struct print_buf
thing, with a length field in it.  There was also a function to
set/validate string lengths etc.  So the approach was to first
wean off as many users of tipc_printf as possible (e.g. by deleting
old debug code, etc.) and then changing tipc_printf into something
much simpler that conveyed string lengths via normal return values
one would expect from snprintf-like functions.  Finally, with the
core code no longer using the print_buf struct, it and the log
code associated with it are removed.

A side bonus is that we get rid of a couple TIPC related Kconfig
options along the way, and about 600 lines of code too.

The folks at Ericsson did most of the work here, and I just
refactored things a bit and made a few suggestions here and there.
I've also run the server/client tests on this series atop of the
net-next baseline of 48ee3569f "ipv6: Move ipv6 twsk accessors
outside of CONFIG_IPV6 ifdefs."

If there no obvious problems spotted by anyone in the next day
or so, I would like to issue a pull request for these.

Thanks,
Paul.
---

Erik Hugne (5):
  tipc: use standard printk shortcut macros (pr_err etc.)
  tipc: remove TIPC packet debugging functions and macros
  tipc: simplify print buffer handling in tipc_printf
  tipc: phase out most of the struct print_buf usage
  tipc: remove print_buf and deprecated log buffer code

Paul Gortmaker (3):
  tipc: factor stats struct out of the larger link struct
  tipc: limit error messages relating to memory leak to one line
  tipc: simplify link_print by divorcing it from using tipc_printf

 include/linux/tipc_config.h |    4 +-
 net/tipc/Kconfig            |   25 ----
 net/tipc/bcast.c            |   65 +++++-----
 net/tipc/bearer.c           |   62 +++++----
 net/tipc/bearer.h           |    2 +-
 net/tipc/config.c           |   41 +++---
 net/tipc/core.c             |   15 +--
 net/tipc/core.h             |   63 +--------
 net/tipc/discover.c         |   10 +-
 net/tipc/handler.c          |    4 +-
 net/tipc/link.c             |  297 ++++++++++++++++++------------------------
 net/tipc/link.h             |   63 ++++-----
 net/tipc/log.c              |  302 ++-----------------------------------------
 net/tipc/log.h              |   66 ----------
 net/tipc/msg.c              |  242 ----------------------------------
 net/tipc/name_distr.c       |   25 ++--
 net/tipc/name_table.c       |  132 ++++++++++---------
 net/tipc/net.c              |    8 +-
 net/tipc/netlink.c          |    2 +-
 net/tipc/node.c             |   23 ++--
 net/tipc/node_subscr.c      |    3 +-
 net/tipc/port.c             |   66 +++++-----
 net/tipc/ref.c              |   10 +-
 net/tipc/socket.c           |    4 +-
 net/tipc/subscr.c           |   14 +-
 25 files changed, 430 insertions(+), 1118 deletions(-)
 delete mode 100644 net/tipc/log.h

-- 
1.7.9.7
