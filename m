From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH 2/2] ip6_tunnel: fix ip6 tunnel lookup in collect_md mode
Date: Fri, 16 Jun 2017 00:36:44 +0800
Message-ID: <AA106C31-8154-43E9-AEA7-7D2D7E451C67@cmss.chinamobile.com>
References: <1497543999-32699-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1497543999-32699-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.or
To: "David S. Miller" <davem@davemloft.net>,
        Paolo Abeni <pabeni@redhat.com>,
        Alexei Starovoitov <ast@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:54597 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751829AbdFOQgv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 12:36:51 -0400
In-Reply-To: <1497543999-32699-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> On 16 Jun 2017, at 12:26 AM, Haishuang Yan <yanhaishuang@cmss.chinamobile.com> wrote:
> 
> In collect_md mode, if the tun dev is down, it still can call
> __ip6_tnl_rcv to receive on packets, and the rx statistics increase
> improperly.
> 
> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
> Cc: Alexei Starovoitov <ast@fb.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
> net/ipv6/ip6_tunnel.c | 2 +-
> 1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 6400726..25961c7 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -171,7 +171,7 @@ static struct net_device_stats *ip6_get_stats(struct net_device *dev)
> 	}
> 
> 	t = rcu_dereference(ip6n->collect_md_tun);
> -	if (t)
> +	if (t && (t->dev->flags & IFF_UP))
> 		return t;
> 
> 	t = rcu_dereference(ip6n->tnls_wc[0]);
> -- 
> 1.8.3.1
> 
> 
Please skip the patches, I wrote a wrong email address '_'! 
