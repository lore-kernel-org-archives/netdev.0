From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 00/20] misc tipc updates / enhancements
Date: Fri, 24 Jun 2011 18:07:07 -0400
Message-ID: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34336 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab1FXWHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bit more dead code removal, some collapsing of functions with
too many arguments, and some cosmetic stuff with no real impact.

But I think the best part in this lot is getting rid of the internal
(to tipc) duplication of "almost" linked list like code, and just
having it use the normal shared kernel code for the task. 
The diffstat summary reflects the net gain here:

       12 files changed, 276 insertions(+), 381 deletions(-)

All credit to Al for the work to get here.  I'm just an intermediate
reviewer -- and happy to see my value-add in that role becoming smaller
and smaller each time as tipc-2 leaves the SF tipc-1.7.x further behind.

I've independently tested using the basic tipcTS/tipcTC tests between
an x86-32 and an x86-64 host, in both directions.

Thanks,
Paul.

---

The following changes since commit 21e842579a5fd1ce746be4e34ac53ef67d6f0a6b:

  Merge branch 'master' of master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 (2011-06-23 23:39:33 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/net-next-2.6.git tipc-Jun24-2011

Allan Stephens (20):
  tipc: Convert fatal broadcast sanity check to non-fatal check
  tipc: Remove unused sanity test macro
  tipc: Standardize exit logic for message rejection handling
  tipc: Add sanity check to detect rejection of non-payload messages
  tipc: Optimize routing of returned payload messages
  tipc: Optimizations & corrections to message rejection
  tipc: Eliminate message header routines for caching destination node
  tipc: Eliminate redundant masking in message header routines
  tipc: Partition name table instance array info into two parts
  tipc: Convert name table publication lists to standard kernel lists
  tipc: Eliminate checks for empty zone list during name translation
  tipc: Correct typo in link statistics output
  tipc: Eliminate unused field in bearer structure
  tipc: Remove unnecessary includes in socket code
  tipc: Eliminate useless check when creating internal message
  tipc: Cleanup of message header size terminology
  tipc: Optimize creation of FIN messages
  tipc: Reject connection protocol message sent to unconnected port
  tipc: Don't create payload message using connection protocol routine
  tipc: Optimize creation of connection protocol messages

 net/tipc/bcast.c      |    6 +-
 net/tipc/bearer.c     |    1 -
 net/tipc/bearer.h     |    2 -
 net/tipc/core.h       |    6 -
 net/tipc/link.c       |    6 +-
 net/tipc/msg.c        |    6 +-
 net/tipc/msg.h        |   34 ++-----
 net/tipc/name_distr.c |    6 +-
 net/tipc/name_table.c |  289 ++++++++++++++++++++-----------------------------
 net/tipc/name_table.h |   14 ++--
 net/tipc/port.c       |  284 ++++++++++++++++++++++--------------------------
 net/tipc/socket.c     |    3 -
 12 files changed, 276 insertions(+), 381 deletions(-)

-- 
1.7.4.4

