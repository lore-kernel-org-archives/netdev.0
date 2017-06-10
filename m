From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: tipc: Fix a sleep-in-atomic bug
 in tipc_msg_reverse
Date: Sat, 10 Jun 2017 18:21:41 -0400 (EDT)
Message-ID: <20170610.182141.2167495708271774980.davem@davemloft.net>
References: <1497085415-630-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: baijiaju1990@163.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1497085415-630-1-git-send-email-baijiaju1990@163.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jia-Ju Bai <baijiaju1990@163.com>
Date: Sat, 10 Jun 2017 17:03:35 +0800

> The kernel may sleep under a rcu read lock in tipc_msg_reverse, and the
> function call path is:
> tipc_l2_rcv_msg (acquire the lock by rcu_read_lock)
>   tipc_rcv
>     tipc_sk_rcv
>       tipc_msg_reverse
>         pskb_expand_head(GFP_KERNEL) --> may sleep
> tipc_node_broadcast
>   tipc_node_xmit_skb
>     tipc_node_xmit
>       tipc_sk_rcv
>         tipc_msg_reverse
>           pskb_expand_head(GFP_KERNEL) --> may sleep
> 
> To fix it, "GFP_KERNEL" is replaced with "GFP_ATOMIC".
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>

Applied and queued up for -stable.

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
