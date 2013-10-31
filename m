From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next v2 0/3] tipc: message reassembly using fragment chain
Date: Thu, 31 Oct 2013 09:40:11 +0100
Message-ID: <1383208814-23476-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ying.xue@windriver.com>, Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<maloy@donjonn.com>, <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.ericsson.se ([193.180.251.45]:42660 "EHLO
	mailgw1.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063Ab3JaIlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 04:41:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

We introduce a new defragmentation algorithm that improves performance
and eliminates the risk of causing out-of-memory situations.

v2: -Rebased on Ying's indentation fix.
    -Node unlock call in msg_fragmenter case moved from patch #2 to #1.
     ('continue' with this lock held would cause spinlock recursion if only
      patch #1 is used)

Erik Hugne (3):
  tipc: don't reroute message fragments
  tipc: message reassembly using fragment chain
  tipc: reassembly failures should cause link reset

 net/tipc/bcast.c |   16 ++++--
 net/tipc/link.c  |  160 +++++++++++++++---------------------------------------
 net/tipc/link.h  |   20 +++++--
 net/tipc/msg.h   |   12 ----
 net/tipc/node.c  |    7 ++-
 net/tipc/node.h  |    6 +-
 6 files changed, 76 insertions(+), 145 deletions(-)

-- 
1.7.9.5
