From: David Miller <davem@davemloft.net>
Subject: Re: [net 1/1] tipc: Unclone message at secondary
 destination lookup
Date: Sun, 08 Oct 2017 21:13:53 -0700 (PDT)
Message-ID: <20171008.211353.2143312569524629593.davem@davemloft.net>
References: <1507381640-29340-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ying.xue@windriver.com, netdev@vger.kernel.org,
 tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1507381640-29340-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/tipc-discussion>,
 <mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
 <mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Sat, 7 Oct 2017 15:07:20 +0200

> When a bundling message is received, the function tipc_link_input()
> calls function tipc_msg_extract() to unbundle all inner messages of
> the bundling message before adding them to input queue.
> 
> The function tipc_msg_extract() just clones all inner skb for all
> inner messagges from the bundling skb. This means that the skb
> headroom of an inner message overlaps with the data part of the
> preceding message in the bundle.
> 
> If the message in question is a name addressed message, it may be
> subject to a secondary destination lookup, and eventually be sent out
> on one of the interfaces again. But, since what is perceived as headroom
> by the device driver in reality is the last bytes of the preceding
> message in the bundle, the latter will be overwritten by the MAC
> addresses of the L2 header. If the preceding message has not yet been
> consumed by the user, it will evenually be delivered with corrupted
> contents.
> 
> This commit fixes this by uncloning all messages passing through the
> function tipc_msg_lookup_dest(), hence ensuring that the headroom
> is always valid when the message is passed on.
> 
> Signed-off-by: Tung Nguyen <tung.q.nguyen@dektech.com.au>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied.

------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
