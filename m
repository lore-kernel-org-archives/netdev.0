From: Jon Maloy <jon.maloy@ericsson.com>
Subject: Re: [PATCH] net: tipc: Fix a sleep-in-atomic bug
 in tipc_msg_reverse
Date: Sat, 10 Jun 2017 13:18:03 +0000
Message-ID: <DB5PR0701MB1958DBCDED9E71F400BBE7969ACF0@DB5PR0701MB1958.eurprd07.prod.outlook.com>
References: <1497085415-630-1-git-send-email-baijiaju1990@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jia-Ju Bai <baijiaju1990@163.com>, Ying Xue <ying.xue@windriver.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1497085415-630-1-git-send-email-baijiaju1990@163.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Acked.

///jon


> -----Original Message-----
> From: Jia-Ju Bai [mailto:baijiaju1990@163.com]
> Sent: Saturday, June 10, 2017 05:04
> To: Jon Maloy <jon.maloy@ericsson.com>; Ying Xue
> <ying.xue@windriver.com>; davem@davemloft.net
> Cc: netdev@vger.kernel.org; tipc-discussion@lists.sourceforge.net; linux-
> kernel@vger.kernel.org; Jia-Ju Bai <baijiaju1990@163.com>
> Subject: [PATCH] net: tipc: Fix a sleep-in-atomic bug in tipc_msg_reverse
> 
> The kernel may sleep under a rcu read lock in tipc_msg_reverse, and the
> function call path is:
> tipc_l2_rcv_msg (acquire the lock by rcu_read_lock)
>   tipc_rcv
>     tipc_sk_rcv
>       tipc_msg_reverse
>         pskb_expand_head(GFP_KERNEL) --> may sleep tipc_node_broadcast
>   tipc_node_xmit_skb
>     tipc_node_xmit
>       tipc_sk_rcv
>         tipc_msg_reverse
>           pskb_expand_head(GFP_KERNEL) --> may sleep
> 
> To fix it, "GFP_KERNEL" is replaced with "GFP_ATOMIC".
> 
> Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
> ---
>  net/tipc/msg.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/tipc/msg.c b/net/tipc/msg.c index 312ef7d..ab30876 100644
> --- a/net/tipc/msg.c
> +++ b/net/tipc/msg.c
> @@ -508,7 +508,7 @@ bool tipc_msg_reverse(u32 own_node,  struct
> sk_buff **skb, int err)
>  	}
> 
>  	if (skb_cloned(_skb) &&
> -	    pskb_expand_head(_skb, BUF_HEADROOM, BUF_TAILROOM,
> GFP_KERNEL))
> +	    pskb_expand_head(_skb, BUF_HEADROOM, BUF_TAILROOM,
> GFP_ATOMIC))
>  		goto exit;
> 
>  	/* Now reverse the concerned fields */
> --
> 1.7.9.5
> 


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
