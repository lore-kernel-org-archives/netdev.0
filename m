From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net] udp: consistently apply ufo or fragmentation
Date: Mon, 14 Aug 2017 10:53:10 -0400
Message-ID: <CAF=yD-LXNPpHvXTVxmVDNoyrPsd=yJp1rianKMcVrkKUaUVBiw@mail.gmail.com>
References: <a9b32d53-5b3c-9596-7309-e56e3945a110@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Konovalov <andreyknvl@google.com>
To: Vasily Averin <vvs@virtuozzo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:35305 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752834AbdHNOxv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 10:53:51 -0400
Received: by mail-oi0-f50.google.com with SMTP id e124so86297504oig.2
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 07:53:51 -0700 (PDT)
In-Reply-To: <a9b32d53-5b3c-9596-7309-e56e3945a110@virtuozzo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ip*_ufo_append_data() is called now for each skb_is_gso() packet.
> Before the patch it was called for UDP packets only.
>
> Could you please clarify, is it correct?

__ip_append_data is called for udp, raw, icmp and ping sockets.
Of these, only udp packets have a path to get skb_is_gso() set:
when __ip_append_data has been called before on this packet
(using MSG_MORE) and the path entered ip_ufo_append_data
in that call through the other conditions in the branch, which
include sk->sk_type == SOCK_DGRAM.

This function is not reached from other segmentable protocols
like tcp, which call ip_queue_xmit in the ip layer. The exceptions
are sending in ip_send_unicast_reply, but those will not have gso.
