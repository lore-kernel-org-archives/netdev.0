From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 0/7] tipc: multicast and internal users to new send functions
Date: Wed, 16 Jul 2014 20:18:31 -0400
Message-ID: <1405556318-14240-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp102.biz.mail.ne1.yahoo.com ([98.138.207.9]:28252 "EHLO
	smtp102.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753720AbaGQATM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 20:19:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We move the remaining data transmit users: multicast, name table
distributor, and link internal protocols to use the new data
transmission framework introduced in a previous commit series
("tipc: new unicast transmission code").

Finally, we remove the code obsoleted by the new functions.

v2: - Fixed a braindead, but harmless return sequence in commit #3, as
      reported by David Miller.
    - Rebased series to 3.16.0-rc5+

Jon Maloy (7):
  tipc: make name table distributor use new send function
  tipc: let internal link users call the new link send function
  tipc: add new functions for multicast and broadcast distribution
  tipc: start using the new multicast functions
  tipc: remove unreferenced functions
  tipc: rename temporarily named functions
  tipc: ensure sequential message delivery across dual bearers

 net/tipc/bcast.c      |   82 +++++++------
 net/tipc/bcast.h      |    5 +-
 net/tipc/link.c       |  307 ++-----------------------------------------------
 net/tipc/link.h       |    9 +-
 net/tipc/msg.c        |   76 ++++++------
 net/tipc/msg.h        |    9 +-
 net/tipc/name_distr.c |   76 ++++++------
 net/tipc/name_distr.h |    2 +-
 net/tipc/node.c       |   13 +--
 net/tipc/port.c       |  122 +-------------------
 net/tipc/port.h       |   10 --
 net/tipc/socket.c     |  148 ++++++++++++++++--------
 net/tipc/socket.h     |    2 +
 13 files changed, 260 insertions(+), 601 deletions(-)

-- 
1.7.9.5
