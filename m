From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: eliminate risk of
 stalled link synchronization
Date: Wed, 14 Oct 2015 06:07:54 -0700 (PDT)
Message-ID: <20151014.060754.1822982454340542739.davem@davemloft.net>
References: <1444754511-14119-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1444754511-14119-1-git-send-email-jon.maloy@ericsson.com>
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
Date: Tue, 13 Oct 2015 12:41:51 -0400

> In commit 6e498158a827 ("tipc: move link synch and failover to link aggregation level")
> we introduced a new mechanism for performing link failover and
> synchronization. We have now detected a bug in this mechanism.
> 
> During link synchronization we use the arrival of any packet on
> the tunnel link to trig a check for whether it has reached the
> synchronization point or not. This has turned out to be too
> permissive, since it may cause an arriving non-last SYNCH packet to
> end the synch state, just to see the next SYNCH packet initiate a
> new synch state with a new, higher synch point. This is not fatal,
> but should be avoided, because it may significantly extend the
> synchronization period, while at the same time we are not allowed
> to send NACKs if packets are lost. In the worst case, a low-traffic
> user may see its traffic stall until a LINK_PROTOCOL state message
> trigs the link to leave synchronization state.
> 
> At the same time, LINK_PROTOCOL packets which happen to have a (non-
> valid) sequence number lower than the tunnel link's rcv_nxt value will
> be consistently dropped, and will never be able to resolve the situation
> described above.
> 
> We fix this by exempting LINK_PROTOCOL packets from the sequence number
> check, as they should be. We also reduce (but don't completely
> eliminate) the risk of entering multiple synchronization states by only
> allowing the (logically) first SYNCH packet to initiate a synchronization
> state. This works independently of actual packet arrival order.
> 
> Fixes: commit 6e498158a827 ("tipc: move link synch and failover to link aggregation level")
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
> Acked-by: Ying Xue <ying.xue@windriver.com>

Applied, thanks.

------------------------------------------------------------------------------
