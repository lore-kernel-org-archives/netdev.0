From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] purge tipc_net_lock
Date: Tue, 22 Apr 2014 21:18:53 -0400 (EDT)
Message-ID: <20140422.211853.1970482489817745604.davem@davemloft.net>
References: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
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
Date: Mon, 21 Apr 2014 10:55:41 +0800

> Now tipc routing hierarchy comprises the structures 'node', 'link'and
> 'bearer'. The whole hierarchy is protected by a big read/write lock,
> tipc_net_lock, to ensure that nothing is added or removed while code
> is accessing any of these structures. Obviously the locking policy
> makes node, link and bearer components closely bound together so that
> their relationship becomes unnecessarily complex. In the worst case,
> such locking policy not only has a negative influence on performance,
> but also it's prone to lead to deadlock occasionally.
> 
> In order o decouple the complex relationship between bearer and node
> as well as link, the locking policy is adjusted as follows:
> 
> - Bearer level
>   RTNL lock is used on update side, and RCU is used on read side.
>   Meanwhile, all bearer instances including broadcast bearer are
>   saved into bearer_list array.
> 
> - Node and link level
>   All node instances are saved into two tipc_node_list and node_htable
>   lists. The two lists are protected by node_list_lock on write side,
>   and they are guarded with RCU lock on read side. All members in node
>   structure including link instances are protected by node spin lock.
> 
> - The relationship between bearer and node
>   When link accesses bearer, it first needs to find the bearer with
>   its bearer identity from the bearer_list array. When bearer accesses
>   node, it can iterate the node_htable hash list with the node address
>   to find the corresponding node.
> 
> In the new locking policy, every component has its private locking
> solution and the relationship between bearer and node is very simple,
> that is, they can find each other with node address or bearer identity
> from node_htable hash list or bearer_list array.

Series applied, thank you.

------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
