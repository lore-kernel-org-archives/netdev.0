From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: fix socket timer
	deadlock
Date: Fri, 17 Jun 2016 21:55:30 -0700 (PDT)
Message-ID: <20160617.215530.401735252835970579.davem@davemloft.net>
References: <1466159757-12095-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1466159757-12095-1-git-send-email-jon.maloy@ericsson.com>
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
Date: Fri, 17 Jun 2016 06:35:57 -0400

> We sometimes observe a 'deadly embrace' type deadlock occurring
> between mutually connected sockets on the same node. This happens
> when the one-hour peer supervision timers happen to expire
> simultaneously in both sockets.
> 
> The scenario is as follows:
 ...
> Further analysis reveals that there are three different locations in the
> socket code where tipc_sk_respond() is called within the context of the
> socket lock, with ensuing risk of similar deadlocks.
> 
> We now solve this by passing a buffer queue along with all upcalls where
> sk_lock.slock may potentially be held. Response or rejected message
> buffers are accumulated into this queue instead of being sent out
> directly, and only sent once we know we are safely outside the slock
> context.
> 
> Reported-by: GUNA <gbalasun@gmail.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.

------------------------------------------------------------------------------
What NetFlow Analyzer can do for you? Monitors network bandwidth and traffic
patterns at an interface-level. Reveals which users, apps, and protocols are 
consuming the most bandwidth. Provides multi-vendor support for NetFlow, 
J-Flow, sFlow and other flows. Make informed decisions using capacity planning
reports. http://sdm.link/zohomanageengine
