From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: avoid fragmenting peculiar skbs in SACK
Date: Wed, 10 May 2017 21:33:52 -0400
Message-ID: <CADVnQynyA-pWE8cWPiiLP_=1tviBNeec97b3HBv_GOMxHZwA_Q@mail.gmail.com>
References: <20170511000127.4249-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f49.google.com ([209.85.218.49]:35816 "EHLO
        mail-oi0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbdEKBeY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 21:34:24 -0400
Received: by mail-oi0-f49.google.com with SMTP id l18so14389867oig.2
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 18:34:24 -0700 (PDT)
In-Reply-To: <20170511000127.4249-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 10, 2017 at 8:01 PM, Yuchung Cheng <ycheng@google.com> wrote:
>
> This patch fixes a bug in splitting an SKB during SACK
> processing. Specifically if an skb contains multiple
> packets and is only partially sacked in the higher sequences,
> tcp_match_sack_to_skb() splits the skb and marks the second fragment
> as SACKed.
>
> The current code further attempts rounding up the first fragment
> to MSS boundaries. But it misses a boundary condition when the
> rounded-up fragment size (pkt_len) is exactly skb size.  Spliting
> such an skb is pointless and causses a kernel warning and aborts
> the SACK processing. This patch universally checks such over-split
> before calling tcp_fragment to prevent these unnecessary warnings.
>
> Fixes: adb92db857ee ("tcp: Make SACK code to split only at mss boundaries")
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>

neal
