From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next RESEND 0/2] fix rculist sparse errors
Date: Wed, 10 Dec 2014 16:46:05 +0800
Message-ID: <1418201167-9591-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <eric.dumazet@gmail.com>,
	<jon.maloy@ericsson.com>, <erik.hugne@ericsson.com>,
	<netdev@vger.kernel.org>, <kbuild-all@01.org>,
	<linux-kernel@vger.kernel.org>
To: <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When hlist_for_each_entry_continue_rcu_bh() gets "next" pointer of
hlist_node structure through rcu_dereference_bh(), sparse warning
appears as the "next" pointer is not annotated as __rcu. So if
the "next" pointer is accessed with hlist_next_rcu() macro, the
__rcu annotation will be added to the pointer. As a consequence,
sparse warning is eliminated too.

The similar errors also appear in hlist_for_each_entry_continue_rcu()
and hlist_for_each_entry_from_rcu().

In this version, CC more people like Paul E. McKenney and lkml mail
list.

Ying Xue (2):
  tipc: fix RCU sparse error
  ipv6: fix sparse warning

 include/linux/rculist.h |   20 ++++++++++----------
 net/tipc/name_table.c   |    6 +++---
 2 files changed, 13 insertions(+), 13 deletions(-)

-- 
1.7.9.5
