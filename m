From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tipc: move the delivery of
 named messages out of nametbl lock
Date: Mon, 28 Apr 2014 14:43:52 -0400 (EDT)
Message-ID: <20140428.144352.2034397869216392037.davem@davemloft.net>
References: <1398679210-13668-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398679210-13668-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Ying Xue <ying.xue@windriver.com>
Date: Mon, 28 Apr 2014 18:00:10 +0800

> Commit a89778d8baf19cd7e728d81121a294a06cedaad1 ("tipc: add support
> for link state subscriptions") introduced below possible deadlock
> scenario:
> 
>        CPU0                          CPU1
> T0:   tipc_publish()                 link_timeout()
> T1:   tipc_nametbl_publish()         [grab node lock]*
> T2:   [grab nametbl write lock]*     link_state_event()
> T3:   named_cluster_distribute()     link_activate()
> T4:   [grab node lock]*              tipc_node_link_up()
> T5:                                  tipc_nametbl_publish()
> T6:                                  [grab nametble write lock]*
> 
> The opposite order of holding nametbl write lock and node lock on
> above two different paths may result in a deadlock. If we move the
> the delivery of named messages via link out of name nametbl lock,
> the reverse order of holding locks will be eliminated, as a result,
> the deadlock will be killed as well.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>

Applied, thanks.

------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.  Get 
unparalleled scalability from the best Selenium testing platform available.
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
