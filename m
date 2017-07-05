From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH RFC 11/12] net: Remove all references to SKB_GSO_UDP.
Date: Wed, 5 Jul 2017 13:21:02 -0400
Message-ID: <CAF=yD-+nZMDnAgHkT=hDONA1mtB3r4F2nct0aVuUtA8tXp9RLw@mail.gmail.com>
References: <20170705.160632.1021185732937441107.davem@davemloft.net> <CAF=yD-LnGPF=jBWLFRppqAjMwvgm34xUeRKsh+rLjX2ZOuun8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35511 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752122AbdGERVn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 13:21:43 -0400
Received: by mail-oi0-f68.google.com with SMTP id l130so28526673oib.2
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 10:21:43 -0700 (PDT)
In-Reply-To: <CAF=yD-LnGPF=jBWLFRppqAjMwvgm34xUeRKsh+rLjX2ZOuun8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 5, 2017 at 12:06 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>> diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
>> index 5209b5e..32fb046 100644
>> --- a/include/linux/virtio_net.h
>> +++ b/include/linux/virtio_net.h
>> @@ -18,9 +18,6 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
>>                 case VIRTIO_NET_HDR_GSO_TCPV6:
>>                         gso_type = SKB_GSO_TCPV6;
>>                         break;
>> -               case VIRTIO_NET_HDR_GSO_UDP:
>> -                       gso_type = SKB_GSO_UDP;
>> -                       break;
>
> Virtio devices negotiate feature support before using this, but
> tuntap and pf_packet may be passing these packets unconditionally.
> Perhaps we should fragment those on the spot with skb_segment.

Tun has ioctl TUNSETIFF to probe for features and it can be argued
that packet sockets should query device features with ethtool before
relying on them. So perhaps we don't need to fix this up, after all.
