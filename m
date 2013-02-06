From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6/ip6_gre: fix error case handling in
 ip6gre_tunnel_xmit()
Date: Wed, 06 Feb 2013 05:29:55 -0800
Message-ID: <1360157395.28557.30.camel@edumazet-glaptop>
References: <1360157042-16473-1-git-send-email-tt.rantala@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Dmitry Kozlov <xeb@mail.ru>
To: Tommi Rantala <tt.rantala@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:62347 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755486Ab3BFN37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 08:29:59 -0500
Received: by mail-pa0-f47.google.com with SMTP id bj3so827112pad.34
        for <netdev@vger.kernel.org>; Wed, 06 Feb 2013 05:29:57 -0800 (PST)
In-Reply-To: <1360157042-16473-1-git-send-email-tt.rantala@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 15:24 +0200, Tommi Rantala wrote:
> ip6gre_tunnel_xmit() is leaking the skb when we hit this error branch,
> and the -1 return value from this function is bogus. Use the error
> handling we already have in place in ip6gre_tunnel_xmit() for this error
> case to fix this.
> 
> Signed-off-by: Tommi Rantala <tt.rantala@gmail.com>
> ---
>  net/ipv6/ip6_gre.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
> index c727e47..131dd09 100644
> --- a/net/ipv6/ip6_gre.c
> +++ b/net/ipv6/ip6_gre.c
> @@ -960,7 +960,7 @@ static netdev_tx_t ip6gre_tunnel_xmit(struct sk_buff *skb,
>  	int ret;
>  
>  	if (!ip6_tnl_xmit_ctl(t))
> -		return -1;
> +		goto tx_err;
>  
>  	switch (skb->protocol) {
>  	case htons(ETH_P_IP):

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks Tommi
