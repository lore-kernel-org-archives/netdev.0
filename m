From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: fix premature addition
 of node to lookup table
Date: Tue, 16 Feb 2016 15:58:06 -0500 (EST)
Message-ID: <20160216.155806.1011700239493236935.davem@davemloft.net>
References: <1455138898-3648-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1455138898-3648-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 10 Feb 2016 16:14:57 -0500

> In commit 5266698661401a ("tipc: let broadcast packet reception
> use new link receive function") we introduced a new per-node
> broadcast reception link instance. This link is created at the
> moment the node itself is created. Unfortunately, the allocation
> is done after the node instance has already been added to the node
> lookup hash table. This creates a potential race condition, where
> arriving broadcast packets are able to find and access the node
> before it has been fully initialized, and before the above mentioned
> link has been created. The result is occasional crashes in the function
> tipc_bcast_rcv(), which is trying to access the not-yet existing link.
> 
> We fix this by deferring the addition of the node instance until after
> it has been fully initialized in the function tipc_node_create().
> 
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied and queued up for -stable, thanks.

------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=272487151&iu=/4140
