From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net-next 0/4] tipc: emulate multicast through replication
Date: Wed, 18 Jan 2017 13:50:49 -0500
Message-ID: <1484765453-16258-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org, parthasarathy.bhuvaragan@ericsson.com,
        ying.xue@windriver.com, maloy@donjonn.com,
        tipc-discussion@lists.sourceforge.net,
        Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.biz.mail.bf1.yahoo.com ([98.139.221.43]:22335 "EHLO
        smtp105.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753333AbdARSvD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 13:51:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TIPC multicast messages are currently distributed via L2 broadcast
or IP multicast to all nodes in the cluster, irrespective of the
number of real destinations of the message.

In this series we introduce an option to transport messages via
replication ("replicast") across a selected number of unicast links,
instead of relying on the underlying media. This option is used when
true broadcast/multicast is not supported by the media, or when the
number of true destinations is much smaller than the cluster size.


Jon Maloy (4):
  tipc: add function for checking broadcast support in bearer
  tipc: add functionality to lookup multicast destination nodes
  tipc: introduce replicast as transport option for multicast
  tipc: make replicast a user selectable option

 include/uapi/linux/tipc.h |   6 +-
 net/tipc/bcast.c          | 200 +++++++++++++++++++++++++++++++++++++++-------
 net/tipc/bcast.h          |  33 +++++++-
 net/tipc/bearer.c         |  15 +++-
 net/tipc/bearer.h         |   8 +-
 net/tipc/link.c           |  12 ++-
 net/tipc/msg.c            |  17 ++++
 net/tipc/msg.h            |   9 +--
 net/tipc/name_table.c     |  38 +++++++--
 net/tipc/name_table.h     |   9 +++
 net/tipc/node.c           |  27 ++++---
 net/tipc/node.h           |   4 +-
 net/tipc/socket.c         |  61 ++++++++++----
 net/tipc/udp_media.c      |   8 +-
 14 files changed, 374 insertions(+), 73 deletions(-)

-- 
2.7.4
