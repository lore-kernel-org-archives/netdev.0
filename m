From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: [PATCH 0/3] raid, kmemleak, netfilter: replace list_for_each_continue_rcu
 with new interface
Date: Fri, 17 Aug 2012 12:33:22 +0800
Message-ID: <502DC992.4040304@linux.vnet.ibm.com>
References: <502CB91E.4050304@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: neilb@suse.de, catalin.marinas@arm.com, David Miller <davem@davemloft.net>,
        kaber@trash.net, pablo@netfilter.org,
        "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>
To: LKML <linux-kernel@vger.kernel.org>, linux-raid@vger.kernel.org,
        linux-mm@kvack.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        netfilter@vger.kernel.org, coreteam@netfilter.org,
        netfilter-devel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <502CB91E.4050304@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: Michael Wang <wangyun@linux.vnet.ibm.com>

This patch set will replace the list_for_each_continue_rcu with the new
interface list_for_each_entry_continue_rcu, so we could remove the old
one later.

Changed:
	raid:		in "next_active_rdev"
	kmemleak:	in "kmemleak_seq_next"
	netfilter:	in "nf_iterate"	

Tested:
	raid:
		mdadm command with an internal bitmap.
	kmemleak:
		enable kmemleak and check the info it captured.
	netfilter:
		add rule to iptables and check result by ping.
		nfqnl_test which is a test utility of libnetfilter_queue.

	All testing are using printk to make sure the code we want test
	was invoked.

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
---
 drivers/md/bitmap.c  |    9 +++------
 mm/kmemleak.c        |    6 ++----
 net/netfilter/core.c |   11 +++++++----
 3 files changed, 12 insertions(+), 14 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
