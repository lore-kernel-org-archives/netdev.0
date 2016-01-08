From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Thu, 7 Jan 2016 19:46:05 -0800
Message-ID: <CAKgT0UfqNgdRYhVRJtT24oBKK4SBqy+QOtWQdD4H09zo2sj32A@mail.gmail.com>
References: <568E9BF9.2050001@solarflare.com>
	<568E9C9B.3090408@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com, Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35349 "EHLO
	mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109AbcAHDqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 22:46:07 -0500
Received: by mail-io0-f194.google.com with SMTP id 77so5233982ioc.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 19:46:06 -0800 (PST)
In-Reply-To: <568E9C9B.3090408@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 7, 2016 at 9:12 AM, Edward Cree <ecree@solarflare.com> wrote:
> Signed-off-by: Edward Cree <ecree@solarflare.com>
> ---
>  drivers/net/vxlan.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index 6369a57..d4acbc9 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -1733,7 +1733,7 @@ static int vxlan6_xmit_skb(struct dst_entry *dst, struct sock *sk,
>                 goto err;
>         }
>
> -       skb = iptunnel_handle_offloads(skb, udp_sum, type);
> +       skb = iptunnel_handle_offloads(skb, false, type);
>         if (IS_ERR(skb)) {
>                 err = -EINVAL;
>                 goto err;
> @@ -1814,7 +1814,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
>         if (WARN_ON(!skb))
>                 return -ENOMEM;
>
> -       skb = iptunnel_handle_offloads(skb, udp_sum, type);
> +       skb = iptunnel_handle_offloads(skb, false, type);
>         if (IS_ERR(skb))
>                 return PTR_ERR(skb);
>
>

So I just tried testing your patches and as it turns out you are still
missing some bits.  In this patch for instance the calls to
udp_tunnel_xmit_skb and udp_tunnel6_xmit skb need to be updated so
that you pass false for the last parameter and allow the use of your
udp_set_csum modifications.

- Alex
