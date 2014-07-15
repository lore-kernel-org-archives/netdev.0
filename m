From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/7] tipc: multicast and internal users to new send functions
Date: Tue, 15 Jul 2014 13:46:03 -0400
Message-ID: <1405446370-11781-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.gq1.yahoo.com ([98.137.12.179]:29055 "HELO
	smtp104.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755080AbaGORqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 13:46:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We move the remaining data transmit users: multicast, name table
distributor, and link internal protocols to use the new data
transmission framework introduced in a previous commit series
("tipc: new unicast transmission code").

Finally, we remove the code obsoleted by the new functions.

Jon Maloy (7):
  tipc: make name table distributor use new send function
  tipc: let internal link users call the new link send function
  tipc: add new functions for multicast and broadcast distribution
  tipc: start using the new multicast functions
  tipc: remove unreferenced functions
  tipc: rename temporarily named functions
  tipc: ensure sequential message delivery across dual bearers

 net/tipc/bcast.c      |   87 ++++++++------
 net/tipc/bcast.h      |    5 +-
 net/tipc/link.c       |  307 ++-----------------------------------------------
 net/tipc/link.h       |    9 +-
 net/tipc/msg.c        |   79 +++++++------
 net/tipc/msg.h        |    9 +-
 net/tipc/name_distr.c |   76 ++++++------
 net/tipc/name_distr.h |    2 +-
 net/tipc/node.c       |   13 +--
 net/tipc/port.c       |  122 +-------------------
 net/tipc/port.h       |   10 --
 net/tipc/socket.c     |  148 ++++++++++++++++--------
 net/tipc/socket.h     |    2 +
 13 files changed, 268 insertions(+), 601 deletions(-)

-- 
1.7.9.5
