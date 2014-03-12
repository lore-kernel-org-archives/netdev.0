From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 0/7] tipc: simplifications in socket and port layer
Date: Wed, 12 Mar 2014 11:31:06 -0400
Message-ID: <1394638273-6127-1-git-send-email-jon.maloy@ericsson.com>
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
Received: from smtp104.biz.mail.ne1.yahoo.com ([98.138.207.11]:33790 "HELO
	smtp104.biz.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754899AbaCLPbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 11:31:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the removal of the tipc native API the relation between
tipc_port and its API types is strictly one-to-one, i.e, the latter
can now only be a socket API. This change opens up for
simplifications both in the code, data and locking structure. 

We start with this series, where we ensure that port and socket
structures are co-allocated. Note that the first commit in the
series is unrelated to the above.

Jon Maloy (7):
  tipc: replace reference table rwlock with spinlock
  tipc: remove redundant 'peer_name' field in struct tipc_sock
  tipc: aggregate port structure into socket structure
  tipc: eliminate upcall function pointers between port and socket
  tipc: eliminate redundant locking
  tipc: align usage of variable names and macros in socket
  tipc: eliminate redundant lookups in registry

 net/tipc/link.c   |    4 +-
 net/tipc/port.c   |  208 +++++++++++-----------------------------------
 net/tipc/port.h   |  112 ++++++++++++++++---------
 net/tipc/ref.c    |   27 ++----
 net/tipc/ref.h    |    1 -
 net/tipc/socket.c |  240 +++++++++++++++++++++++++----------------------------
 net/tipc/socket.h |   72 ++++++++++++++++
 7 files changed, 314 insertions(+), 350 deletions(-)
 create mode 100644 net/tipc/socket.h

-- 
1.7.9.5
