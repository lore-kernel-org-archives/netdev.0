From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 00/13] tipc: new unicast transmission code
Date: Wed, 25 Jun 2014 20:41:29 -0500
Message-ID: <1403746902-20408-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.ne1.yahoo.com ([98.138.207.12]:24102 "HELO
	smtp105.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755308AbaFZBsm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jun 2014 21:48:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a step towards making the data transmission code more maintainable
and performant, we introduce a number of new functions, both for
building, sending and rejecting messages. The new functions will
eventually be used for alla data transmission, user data unicast,
service internal messaging, and multicast/broadcast.

We start with this series, where we introduce the functions, and
let user data unicast and the internal connection protocol use them.
The remaining users will come in a later series.

There are only minor changes to data structures, and no protocol
changes, so the older functions can still be used in parallel for
some time. Until the old functions are removed, we use temporary
names for the new functions, such as tipc_build_msg2, tipc_link_xmit2.

It should be noted that the first two commits are unrelated to the
rest of the series.

Jon Maloy (13):
  tipc: eliminate case of writing to freed memory
  tipc: use negative error return values in functions
  tipc: introduce send functions for chained buffers in link
  tipc: make link mtu easily accessible from socket
  tipc: introduce direct iovec to buffer chain fragmentation function
  tipc: separate building and sending of rejected messages
  tipc: introduce message evaluation function
  tipc: RDM/DGRAM transport uses new fragmenting and sending functions
  tipc: connection oriented transport uses new send functions
  tipc: let port protocol senders use new link send function
  tipc: same receive code path for connection protocol and data
    messages
  tipc: clean up connection protocol reception function
  tipc: simplify connection congestion handling

 net/tipc/link.c        |  417 ++++++++++++++++-------------------------
 net/tipc/link.h        |    2 +
 net/tipc/msg.c         |  282 ++++++++++++++++++++++++++--
 net/tipc/msg.h         |   32 +++-
 net/tipc/net.c         |   63 +------
 net/tipc/net.h         |    2 -
 net/tipc/node.c        |   25 ++-
 net/tipc/node.h        |   17 ++
 net/tipc/node_subscr.c |    6 +-
 net/tipc/port.c        |  328 +++-----------------------------
 net/tipc/port.h        |   40 ----
 net/tipc/socket.c      |  487 ++++++++++++++++++++++++++++--------------------
 net/tipc/socket.h      |   14 ++
 13 files changed, 827 insertions(+), 888 deletions(-)

-- 
1.7.9.5
