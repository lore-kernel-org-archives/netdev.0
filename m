From: pravin <pravin.shelar@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] ip_gre: allow CSUM capable devices to
 handle packets
Date: Tue, 19 Feb 2013 10:28:19 -0800
Message-ID: <CANvJab2uOKaGG6SrJCjvhe39oPqQbLBuc44j_nkShz_NW8G98w@mail.gmail.com>
References: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:42365 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933152Ab3BSS2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 13:28:21 -0500
Received: by mail-wg0-f45.google.com with SMTP id dq12so5929383wgb.24
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 10:28:19 -0800 (PST)
In-Reply-To: <1361217053-16984-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 18, 2013 at 11:50 AM, Dmitry Kravkov <dmitry@broadcom.com> wrote:
> If device is not able to handle checksumming it will
> be handled in dev_xmit
>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> ---
> Changes from v1: fixed email address
>
>  net/ipv4/ip_gre.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
>
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index a56f118..cdc31ac 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -745,12 +745,9 @@ static struct sk_buff *handle_offloads(struct sk_buff *skb)
>                         goto error;
>                 skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
>                 return skb;
> -       } else if (skb->ip_summed == CHECKSUM_PARTIAL) {
> -               err = skb_checksum_help(skb);
> -               if (unlikely(err))
> -                       goto error;
>         }
> -       skb->ip_summed = CHECKSUM_NONE;
> +       if (skb->ip_summed != CHECKSUM_PARTIAL)
> +               skb->ip_summed = CHECKSUM_NONE;
>
>         return skb;
>
> --
> 1.7.7.2
>
>

This patch breaks GRE tunnel with GRE_CSUM. since GRE_CSUM need
complete IP packet to checksum entire GRE payload.

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
