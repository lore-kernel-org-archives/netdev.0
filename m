From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: move "IPv6: sending pkt_too_big to self" to
 NETDEBUG
Date: Sat, 28 Jul 2012 10:29:20 -0700
Message-ID: <1343496560.2009.15.camel@joe2Laptop>
References: <1343487997-9047-1-git-send-email-pkern@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	ak@linux.intel.com
To: Philipp Kern <pkern@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343487997-9047-1-git-send-email-pkern@debian.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-07-28 at 17:06 +0200, Philipp Kern wrote:
> ip6_xmit checks if the outgoing packet is larger than the path MTU and
> emits ICMPv6 packet too big locally if this is the case. Logging this,
> even at KERN_DEBUG, confuses users. It is also not actually helpful for
> debugging, given that there is no reference to the connection that
> triggered this event.
[]
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
[]
> @@ -241,7 +241,7 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
>  			       dst->dev, dst_output);
>  	}
>  
> -	net_dbg_ratelimited("IPv6: sending pkt_too_big to self\n");
> +	LIMIT_NETDEBUG("IPv6: sending pkt_too_big to self\n");

LIMIT_NETDEBUG doesn't include a logging level.
Add a KERN_DEBUG prefix or another KERN_<LEVEL>.

Maybe it'd be better to add the context too.
