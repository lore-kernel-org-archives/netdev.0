From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] ip_tunnel: enclose a code block in macro IS_ENABLED(CONFIG_IPV6)
Date: Sun, 22 May 2016 18:06:38 -0700
Message-ID: <CAKgT0Ucz5bSXEF2nPjUpveu9CXvT9i+NfMD3zSs1=d_OjeCEbw@mail.gmail.com>
References: <1463957631-11760-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:34791 "EHLO
	mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752711AbcEWBGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 21:06:39 -0400
In-Reply-To: <1463957631-11760-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, May 22, 2016 at 3:53 PM, Haishuang Yan
<yanhaishuang@cmss.chinamobile.com> wrote:
> For ipv6 case, enclose the code block in macro IS_ENABLED(CONFIG_IPV6).
>
> Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
> ---
>  net/ipv4/ip_tunnel.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> index a69ed94..5f3c8de 100644
> --- a/net/ipv4/ip_tunnel.c
> +++ b/net/ipv4/ip_tunnel.c
> @@ -665,10 +665,13 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
>                 if (skb->protocol == htons(ETH_P_IP)) {
>                         tos = inner_iph->tos;
>                         connected = false;
> -               } else if (skb->protocol == htons(ETH_P_IPV6)) {
> +               }
> +#if IS_ENABLED(CONFIG_IPV6)
> +               else if (skb->protocol == htons(ETH_P_IPV6)) {
>                         tos = ipv6_get_dsfield((const struct ipv6hdr *)inner_iph);
>                         connected = false;
>                 }
> +#endif
>         }
>
>         init_tunnel_flow(&fl4, protocol, dst, tnl_params->saddr,
>

You could just place the "#if IS_ENABLED" block before the "} else if
(..) {" piece and the "#endif" before the closing brace and this
becomes much easier to look at.

Also is there any specific reason for needing to wrap this code?  It
isn't clear from your patch description, and from what I can tell the
code that you are wrapping should be defined in all cases since it is
defined in header files anyway.

- Alex
