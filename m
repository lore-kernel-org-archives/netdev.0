From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [RFC PATCH v6 net-next 2/4] tcp: refactor struct tcp_skb_cb
Date: Thu, 27 Aug 2015 14:53:17 -0700
Message-ID: <CAK6E8=ePkegbejBxNPMhQyEnRbiEPLM3-UoA50rMCyY_yfFwhg@mail.gmail.com>
References: <1440545634-3901299-1-git-send-email-brakmo@fb.com> <1440545634-3901299-3-git-send-email-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Lawrence Brakmo <brakmo@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:34543 "EHLO
	mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbbH0Vx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 17:53:57 -0400
Received: by vkhf67 with SMTP id f67so1358848vkh.1
        for <netdev@vger.kernel.org>; Thu, 27 Aug 2015 14:53:57 -0700 (PDT)
In-Reply-To: <1440545634-3901299-3-git-send-email-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 25, 2015 at 4:33 PM, Lawrence Brakmo <brakmo@fb.com> wrote:
>
> Refactor tcp_skb_cb to create two overlaping areas to store
> state for incoming or outgoing skbs based on comments by
> Neal Cardwell to tcp_nv patch:
>
>    AFAICT this patch would not require an increase in the size of
>    sk_buff cb[] if it were to take advantage of the fact that the
>    tcp_skb_cb header.h4 and header.h6 fields are only used in the packet
>    reception code path, and this in_flight field is only used on the
>    transmit side.
>
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

> ---
>  include/net/tcp.h | 11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)
>
> diff --git a/include/net/tcp.h b/include/net/tcp.h
> index 0121529..a086a98 100644
> --- a/include/net/tcp.h
> +++ b/include/net/tcp.h
> @@ -755,11 +755,16 @@ struct tcp_skb_cb {
>         /* 1 byte hole */
>         __u32           ack_seq;        /* Sequence number ACK'd        */
>         union {
> -               struct inet_skb_parm    h4;
> +               struct {
> +                       /* There is space for up to 20 bytes */
> +               } tx;   /* only used for outgoing skbs */
> +               union {
> +                       struct inet_skb_parm    h4;
>  #if IS_ENABLED(CONFIG_IPV6)
> -               struct inet6_skb_parm   h6;
> +                       struct inet6_skb_parm   h6;
>  #endif
> -       } header;       /* For incoming frames          */
> +               } header;       /* For incoming skbs */
> +       };
>  };
>
>  #define TCP_SKB_CB(__skb)      ((struct tcp_skb_cb *)&((__skb)->cb[0]))
> --
> 1.8.1
>
