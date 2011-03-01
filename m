From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [PATCH 0/4] rcu: don't assume the size of struct rcu_head
Date: Tue, 01 Mar 2011 16:03:15 +0800
Message-ID: <4D6CA843.3090103@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Christoph Lameter <cl@linux-foundation.org>,
        Pekka Enberg <penberg@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <owner-linux-mm@kvack.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org


We always keep the struct rcu_head very small, but we may change it in future
or under some CONFIGs.

There are some other systems may assume the size of struct rcu_head as 2 * sizeof(long).
These assumptions obstruct us to add debug information or priority information
to struct rcu_head. It is time to fix them.

It is glad that I just find 3 places which need to be fixed. These 4 patches
are just cleanup patches when the size of struct rcu_head == 2 * sizeof(long).
NO overhead added and NO behavior changed.
Even when the size of struct rcu_head becomes larger, only slub is changed a little.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
