From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH] ip6_tunnel: Correct tos value in collect_md mode
Date: Wed, 14 Jun 2017 10:54:31 +0800
Message-ID: <9E61EADF-769B-431A-81EA-ADBAAD32ABD3@cmss.chinamobile.com>
References: <1497408497-1473-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Peter Dawson <petedaws@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:54579 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754229AbdFNCyg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 22:54:36 -0400
In-Reply-To: <1497408497-1473-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 14 Jun 2017, at 10:48 AM, Haishuang Yan <yanhaishuang@cmss.chinamobile.com> wrote:
> 
> Same as ip_gre, geneve and vxlan, use key->tos as tos value.
> 
> CC: Peter Dawson <petedaws@gmail.com>
> Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on
> encapsulated packets”)
> Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> 
> ---
> Changes since v2:
>  * Add fixes information
>  * mask key->tos with RT_TOS() suggested by Daniel
> ---
> net/ipv6/ip6_tunnel.c | 4 ++--
> 1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index ef99d59..6400726 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -1249,7 +1249,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
> 		fl6.flowi6_proto = IPPROTO_IPIP;
> 		fl6.daddr = key->u.ipv6.dst;
> 		fl6.flowlabel = key->label;
> -		dsfield = ip6_tclass(key->label);
> +		dsfield =  RT_TOS(key->tos);
> 	} else {
> 		if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
> 			encap_limit = t->parms.encap_limit;
> @@ -1320,7 +1320,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
> 		fl6.flowi6_proto = IPPROTO_IPV6;
> 		fl6.daddr = key->u.ipv6.dst;
> 		fl6.flowlabel = key->label;
> -		dsfield = ip6_tclass(key->label);
> +		dsfield = RT_TOS(key->tos);
> 	} else {
> 		offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
> 		/* ip6_tnl_parse_tlv_enc_lim() might have reallocated skb->head */
> -- 
> 1.8.3.1
> 
> 

Sorry, I forgot to add subject prefix, please ignore this patch.
