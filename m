From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 03/19] netfilter: nf_conntrack_ipv6: improve
 fragmentation handling
Date: Thu, 30 Aug 2012 05:06:35 +0200
Message-ID: <20120830030635.GA17583@1984>
References: <1346190539-9963-1-git-send-email-kaber@trash.net>
 <1346190539-9963-4-git-send-email-kaber@trash.net>
 <Pine.LNX.4.64.1208291007520.32281@ask.diku.dk>
 <Pine.GSO.4.63.1208291424550.26100@stinky-local.trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	Netfilter Developers <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <Pine.GSO.4.63.1208291424550.26100@stinky-local.trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 29, 2012 at 02:27:00PM +0200, Patrick McHardy wrote:
> On Wed, 29 Aug 2012, Jesper Dangaard Brouer wrote:
> 
> >
> >Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> >
> >And some nitpicks below...
> >
> >>diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> >>index 5b2d63e..a4f6263 100644
> >>--- a/net/ipv6/ip6_output.c
> >>+++ b/net/ipv6/ip6_output.c
> >>@@ -493,7 +493,8 @@ int ip6_forward(struct sk_buff *skb)
> >>	if (mtu < IPV6_MIN_MTU)
> >>		mtu = IPV6_MIN_MTU;
> >>
> >>-	if (skb->len > mtu && !skb_is_gso(skb)) {
> >>+	if ((!skb->local_df && skb->len > mtu && !skb_is_gso(skb)) ||
> >
> >You use (!skb->local_df) to invalidate the use of skb->len,
> >instead of (!IP6CB(skb)->frag_max_size), (which is okay, because
> >you set local_df later).  Is there are reason this check is
> >better?
> 
> Just that it's consistent with ip6_output and the regular local_df
> handling. It saves one extra condition in ip6_output.
> 
> >>+	    (IP6CB(skb)->frag_max_size && IP6CB(skb)->frag_max_size > mtu)) {
> >
> >Eric Dumazet would probably nitpick and say, it can be reduced to:
> >(IP6CB(skb)->frag_max_size > mtu)
> >;-)
> 
> True. I'll fix that once Pablo has pulled in the patches.

If you don't want to wait, you can send me a follow up patch, I'll
apply it manually.
