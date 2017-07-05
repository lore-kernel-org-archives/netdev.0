From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 11/12] net: Remove all references to SKB_GSO_UDP.
Date: Wed, 5 Jul 2017 12:06:44 -0400
Message-ID: <CAF=yD-LnGPF=jBWLFRppqAjMwvgm34xUeRKsh+rLjX2ZOuun8g@mail.gmail.com>
References: <20170705.160632.1021185732937441107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34797 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751444AbdGEQHZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 12:07:25 -0400
Received: by mail-oi0-f66.google.com with SMTP id d77so28171594oig.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 09:07:25 -0700 (PDT)
In-Reply-To: <20170705.160632.1021185732937441107.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
> index 5209b5e..32fb046 100644
> --- a/include/linux/virtio_net.h
> +++ b/include/linux/virtio_net.h
> @@ -18,9 +18,6 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
>                 case VIRTIO_NET_HDR_GSO_TCPV6:
>                         gso_type = SKB_GSO_TCPV6;
>                         break;
> -               case VIRTIO_NET_HDR_GSO_UDP:
> -                       gso_type = SKB_GSO_UDP;
> -                       break;

Virtio devices negotiate feature support before using this, but
tuntap and pf_packet may be passing these packets unconditionally.
Perhaps we should fragment those on the spot with skb_segment.

> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -21,7 +21,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
>         __be16 new_protocol, bool is_ipv6)

In this file, can now remove all of udp4_ufo_fragment, and
udp6_ufo_fragment in net/ipv6.
