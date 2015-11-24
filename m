From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tipc: fix error handling of expanding
	buffer headroom
Date: Mon, 23 Nov 2015 23:35:47 -0500 (EST)
Message-ID: <20151123.233547.446739112661995737.davem@davemloft.net>
References: <1448177919-8646-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, stephen@networkplumber.org,
	tipc-discussion@lists.sourceforge.net, scan-admin@coverity.com,
	netdev@vger.kernel.org
To: ying.xue@windriver.com
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1448177919-8646-1-git-send-email-ying.xue@windriver.com>
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
Date: Sun, 22 Nov 2015 15:38:39 +0800

> @@ -158,8 +158,11 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
>  	struct udp_media_addr *src = (struct udp_media_addr *)&b->addr.value;
>  	struct rtable *rt;
>  
> -	if (skb_headroom(skb) < UDP_MIN_HEADROOM)
> -		pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
> +	if (skb_headroom(skb) < UDP_MIN_HEADROOM) {
> +		err = pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
> +		if (!err)
> +			goto tx_error;
> +	}

pskb_expand_head() returns negative error codes, therefore zero means
success and therefore this "!err" check is reversed.

------------------------------------------------------------------------------
Go from Idea to Many App Stores Faster with Intel(R) XDK
Give your users amazing mobile app experiences with Intel(R) XDK.
Use one codebase in this all-in-one HTML5 development environment.
Design, debug & build mobile apps & 2D/3D high-impact games for multiple OSs.
http://pubads.g.doubleclick.net/gampad/clk?id=254741551&iu=/4140
