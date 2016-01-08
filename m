From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next 3/5] net: vxlan: enable local checksum offload
Date: Thu, 7 Jan 2016 16:15:22 -0800
Message-ID: <CAKgT0UePUo+qN+gv3R_4Uge=q=GUd4-39BxgecXmYCXLohLt2w@mail.gmail.com>
References: <568E9BF9.2050001@solarflare.com>
	<568E9C9B.3090408@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com, Tom Herbert <tom@herbertland.com>
To: Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:34113 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753341AbcAHAPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 19:15:23 -0500
Received: by mail-io0-f177.google.com with SMTP id 1so223751971ion.1
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 16:15:22 -0800 (PST)
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

A few lines up from here there is a "udp_sum = false" that can be
dropped for the remote checksum stuff.

> -       skb = iptunnel_handle_offloads(skb, udp_sum, type);
> +       skb = iptunnel_handle_offloads(skb, false, type);
>         if (IS_ERR(skb)) {
>                 err = -EINVAL;
>                 goto err;
> @@ -1814,7 +1814,7 @@ static int vxlan_xmit_skb(struct rtable *rt, struct sock *sk, struct sk_buff *sk
>         if (WARN_ON(!skb))
>                 return -ENOMEM;
>

Same thing for this one.  If you aren't passing it there is no point
in updating it a few lines above here.

> -       skb = iptunnel_handle_offloads(skb, udp_sum, type);
> +       skb = iptunnel_handle_offloads(skb, false, type);
>         if (IS_ERR(skb))
>                 return PTR_ERR(skb);
>
