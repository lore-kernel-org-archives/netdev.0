From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v1] tipc: fix random link resets
 while adding a second bearer
Date: Thu, 01 Sep 2016 10:13:28 -0700 (PDT)
Message-ID: <20160901.101328.782876070935686176.davem@davemloft.net>
References: <1472739736-29391-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1472739736-29391-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Thu, 1 Sep 2016 16:22:16 +0200

> In a dual bearer configuration, if the second tipc link becomes
> active while the first link still has pending nametable "bulk"
> updates, it randomly leads to reset of the second link.
> 
> When a link is established, the function named_distribute(),
> fills the skb based on node mtu (allows room for TUNNEL_PROTOCOL)
> with NAME_DISTRIBUTOR message for each PUBLICATION.
> However, the function named_distribute() allocates the buffer by
> increasing the node mtu by INT_H_SIZE (to insert NAME_DISTRIBUTOR).
> This consumes the space allocated for TUNNEL_PROTOCOL.
> 
> When establishing the second link, the link shall tunnel all the
> messages in the first link queue including the "bulk" update.
> As size of the NAME_DISTRIBUTOR messages while tunnelling, exceeds
> the link mtu the transmission fails (-EMSGSIZE).
> 
> Thus, the synch point based on the message count of the tunnel
> packets is never reached leading to link timeout.
> 
> In this commit, we adjust the size of name distributor message so that
> they can be tunnelled.
> 
> Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
> Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>

Applied.

------------------------------------------------------------------------------
