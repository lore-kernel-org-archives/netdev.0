From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH net-next 3/8] tcp: use one bit in TCP_SKB_CB to mark ACK timestamps
Date: Wed, 30 Mar 2016 23:36:00 -0400
Message-ID: <CAF=yD-JAz+jFdkHnRZq5Y+KnvW9SkevF2j--iQ0A4sfD=5_MPw@mail.gmail.com>
References: <1459377448-2239-1-git-send-email-soheil.kdev@gmail.com> <1459377448-2239-4-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Martin KaFai Lau <kafai@fb.com>,
	Soheil Hassas Yeganeh <soheil@google.com>
To: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:35126 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760AbcCaDgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 23:36:41 -0400
Received: by mail-lf0-f68.google.com with SMTP id c62so6844074lfc.2
        for <netdev@vger.kernel.org>; Wed, 30 Mar 2016 20:36:40 -0700 (PDT)
In-Reply-To: <1459377448-2239-4-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 30, 2016 at 6:37 PM, Soheil Hassas Yeganeh
<soheil.kdev@gmail.com> wrote:
> From: Soheil Hassas Yeganeh <soheil@google.com>
>
> Currently, to avoid a cache line miss for accessing skb_shinfo,
> tcp_ack_tstamp skips socket that do not have
> SOF_TIMESTAMPING_TX_ACK bit set in sk_tsflags. This is
> implemented based on an implicit assumption that the
> SOF_TIMESTAMPING_TX_ACK is set via socket options for the
> duration that ACK timestamps are needed.
>
> To implement per-write timestamps, this check should be
> removed and replaced with a per-packet alternative that
> quickly skips packets missing ACK timestamps marks without
> a cache-line miss.
>
> To enable per-packet marking without a cache line miss, use
> one bit in TCP_SKB_CB to mark a whether a SKB might need a
> ack tx timestamp or not. Further checks in tcp_ack_tstamp are not
> modified and work as before.
>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Willem de Bruijn <willemb@google.com>
