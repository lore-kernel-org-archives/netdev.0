From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 1/2] ip_tunnel: fix setting ttl and tos value in
 collect_md mode
Date: Fri, 8 Sep 2017 18:54:33 -0700
Message-ID: <f564f706-19c1-38cf-a59e-d40a946dab28@fb.com>
References: <1504764515-13536-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504764515-13536-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/6/17 11:08 PM, Haishuang Yan wrote:
> ttl and tos variables are declared and assigned, but are not used in
> iptunnel_xmit() function.
>
> Fixes: cfc7381b3002 ("ip_tunnel: add collect_md mode to IPIP tunnel")
> Cc: Alexei Starovoitov <ast@fb.com>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  net/ipv4/ip_tunnel.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index 129d1a3..e1856bf 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -618,8 +618,8 @@ void ip_md_tunnel_xmit(struct sk_buff *skb, struct net_device *dev, u8 proto)
>  		ip_rt_put(rt);
>  		goto tx_dropped;
>  	}
> -	iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, proto, key->tos,
> -		      key->ttl, df, !net_eq(tunnel->net, dev_net(dev)));
> +	iptunnel_xmit(NULL, rt, skb, fl4.saddr, fl4.daddr, proto, tos, ttl,
> +		      df, !net_eq(tunnel->net, dev_net(dev)));

indeed. good catch. thanks
Acked-by: Alexei Starovoitov <ast@kernel.org>
