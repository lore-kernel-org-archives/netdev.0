From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 0/8] tipc: convert name table read-write lock to RCU
Date: Tue, 2 Dec 2014 15:00:22 +0800
Message-ID: <1417503630-31352-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <richard.alpe@ericsson.com>,
	<tero.aho@coriant.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:35400 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843AbaLBHA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 02:00:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now TIPC name table is statically allocated and is protected with a
Read-Write lock. To enhance the performance of TIPC name table lookup,
we are going to involve RCU lock to protect the name table. As a
consequence, it becomes lockless to concurrently look up name table on
read side. However, before the conversion can be successfully made,
the following two things must be first done:

- change allocation way of name table from static to dynamic
- fix several incorrect locking policy issues

Ying Xue (8):
  tipc: remove size variable from publ_list struct
  tipc: make name table allocated dynamically
  tipc: ensure all name sequences are released when name table is
    stopped
  tipc: ensure all name sequences are properly protected with its lock
  tipc: any name table member must be protected under name table lock
  tipc: simplify relationship between name table lock and node lock
  tipc: remove unnecessary INIT_LIST_HEAD
  tipc: convert name table read-write lock to RCU

 include/linux/rculist.h |    9 +++
 net/tipc/name_distr.c   |   83 +++++++------------
 net/tipc/name_table.c   |  202 ++++++++++++++++++++++++-----------------------
 net/tipc/name_table.h   |   20 ++++-
 net/tipc/subscr.c       |    1 -
 5 files changed, 157 insertions(+), 158 deletions(-)

-- 
1.7.9.5
