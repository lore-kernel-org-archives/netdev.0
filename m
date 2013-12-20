From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] vmxnet3: use initialized skb pointer to set hash
Date: Fri, 20 Dec 2013 12:30:33 -0800
Message-ID: <CA+mtBx8xHp9RYkynWczan85c0EEFvXMOH_4b5Mi_yV8-=Dw9-g@mail.gmail.com>
References: <1387541817-7877-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:43730 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201Ab3LTUad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 15:30:33 -0500
Received: by mail-ig0-f170.google.com with SMTP id k19so15939987igc.1
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 12:30:33 -0800 (PST)
In-Reply-To: <1387541817-7877-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Tom Herbert <therbert@google.com>

On Fri, Dec 20, 2013 at 4:16 AM, Michal Schmidt <mschmidt@redhat.com> wrote:
> The recent conversion to skb_set_hash() was incorrect. 'skb' is
> uninitialized at this point.
>
> Fixes: 0b6807034791 ('net: vmxnet3 calls skb_set_hash')
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> ---
>  drivers/net/vmxnet3/vmxnet3_drv.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
> index c0eab72..3be786f 100644
> --- a/drivers/net/vmxnet3/vmxnet3_drv.c
> +++ b/drivers/net/vmxnet3/vmxnet3_drv.c
> @@ -1235,7 +1235,8 @@ vmxnet3_rq_rx_complete(struct vmxnet3_rx_queue *rq,
>  #ifdef VMXNET3_RSS
>                         if (rcd->rssType != VMXNET3_RCD_RSS_TYPE_NONE &&
>                             (adapter->netdev->features & NETIF_F_RXHASH))
> -                               skb_set_hash(skb, le32_to_cpu(rcd->rssHash),
> +                               skb_set_hash(ctx->skb,
> +                                            le32_to_cpu(rcd->rssHash),
>                                              PKT_HASH_TYPE_L3);
>  #endif
>                         skb_put(ctx->skb, rcd->len);
> --
> 1.8.4.2
>
