From: =?utf-8?B?5Lil5rW35Y+M?= <yanhaishuang@cmss.chinamobile.com>
Subject: Re: [PATCH] ip6_tunnel: fix potential issue in __ip6_tnl_rcv
Date: Tue, 13 Jun 2017 17:51:06 +0800
Message-ID: <3FF0F242-3647-47DF-B412-10A5A840AE71@cmss.chinamobile.com>
References: <1497344195-19900-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
 <1497344195-19900-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0 (Mac OS X Mail 10.3 \(3273\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@fb.com>
To: "David S. Miller" <davem@davemloft.net>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        zhangshengju <zhangshengju@cmss.chinamobile.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497344195-19900-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> On 13 Jun 2017, at 4:56 PM, Haishuang Yan <yanhaishuang@cmss.chinamobile.com> wrote:
> 
> When __ip6_tnl_rcv fails, the tun_dst won't be freed, so call
> dst_release to free it in error code path.
> 
> CC: Alexei Starovoitov <ast@fb.com>
> Fixes: 8d79266bc48c ("ip6_tunnel: add collect_md mode to IPv6 tunnels")
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> Tested-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> 
> ---
> v4:
>  - Add tester information
> v3:
>  - Free tun_dst from error code path
> v2:
>  - Add the the missing Fixes information
> ---
> net/ipv6/ip6_tunnel.c | 2 ++
> 1 file changed, 2 insertions(+)
> 
> diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
> index 9b37f97..ef99d59 100644
> --- a/net/ipv6/ip6_tunnel.c
> +++ b/net/ipv6/ip6_tunnel.c
> @@ -859,6 +859,8 @@ static int __ip6_tnl_rcv(struct ip6_tnl *tunnel, struct sk_buff *skb,
> 	return 0;
> 
> drop:
> +	if (tun_dst)
> +		dst_release((struct dst_entry *)tun_dst);
> 	kfree_skb(skb);
> 	return 0;
> }
> -- 
> 1.8.3.1
> 
> 

Hi David, Please ignore the patches, I forgot to add subject prefix, sorry.
