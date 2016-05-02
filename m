From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net PATCH 1/2] net: Disable segmentation if checksumming is not supported
Date: Mon, 2 May 2016 09:33:27 -0700
Message-ID: <CALx6S36=dHesn65aWWiiC=rRjmOW3mZa3ymk0oq5JBncg6SEnA@mail.gmail.com>
References: <20160502161621.11701.9271.stgit@ahduyck-xeon-server>
	<20160502162510.11701.82922.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Duyck <alexander.duyck@gmail.com>
To: Alexander Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:32825 "EHLO
	mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbcEBQdd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:33:33 -0400
Received: by mail-io0-f177.google.com with SMTP id f89so172744531ioi.0
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:33:32 -0700 (PDT)
In-Reply-To: <20160502162510.11701.82922.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 2, 2016 at 9:25 AM, Alexander Duyck <aduyck@mirantis.com> wrote:
> In the case of the mlx4 and mlx5 driver they do not support IPv6 checksum
> offload for tunnels.  With this being the case we should disable GSO in
> addition to the checksum offload features when we find that a device cannot
> perform a checksum on a given packet type.
>
I'm not sure I understand this. If device can't support checksum
offload for tunnels doesn't that mean we have to do the checksum on
host regardless of whether GSO is being done?

Tom

> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
> ---
>  net/core/dev.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 77a71cd68535..5c925ac50b95 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2802,7 +2802,7 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
>
>         if (skb->ip_summed != CHECKSUM_NONE &&
>             !can_checksum_protocol(features, type)) {
> -               features &= ~NETIF_F_CSUM_MASK;
> +               features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
>         } else if (illegal_highdma(skb->dev, skb)) {
>                 features &= ~NETIF_F_SG;
>         }
>
