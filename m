From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: [PATCH 0/2] netfilter: code refine for using new interface 'list_for_each_entry_continue_rcu'
Date: Thu, 23 Aug 2012 13:59:49 +0800
Message-ID: <5035C6D5.6020608@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	pablo@netfilter.org
To: LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	coreteam@netfilter.org, netfilter@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wang <wangyun@linux.vnet.ibm.com>

Since 'list_for_each_continue_rcu' has been replaced with the new interface
'list_for_each_entry_continue_rcu' by commit 6705e86, we can no longer saving
code by passing 'list_head' to nf_iterate() and nf_queue() any more.

This patch set will pass 'nf_hook_ops' instead of 'list_head' to nf_iterate()
and nf_queue() as the parameter and saving some code.

Tested:
	add rule to iptables and check result by ping.
	nfqnl_test which is a test utility of libnetfilter_queue.

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
---
 b/net/netfilter/core.c         |   24 ++++++++++--------------
 b/net/netfilter/nf_internals.h |    2 +-
 b/net/netfilter/nf_queue.c     |    6 +++---
 net/netfilter/core.c           |    4 ++--
 net/netfilter/nf_internals.h   |    2 +-
 net/netfilter/nf_queue.c       |    8 ++++----
 6 files changed, 21 insertions(+), 25 deletions(-)

