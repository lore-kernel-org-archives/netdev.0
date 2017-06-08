From: Soheil Hassas Yeganeh <soheil@google.com>
Subject: Re: [PATCH net-next] skbuff: only inherit relevant tx_flags
Date: Thu, 8 Jun 2017 11:59:40 -0400
Message-ID: <CACSApvY3taHwTV4RdPEnj4d8FU6FSt8kxqZiY=tB+pbxZRCCAA@mail.gmail.com>
References: <20170608153503.74199-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:34488 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751583AbdFHQAZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 12:00:25 -0400
Received: by mail-io0-f181.google.com with SMTP id i7so22096874ioe.1
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 09:00:25 -0700 (PDT)
In-Reply-To: <20170608153503.74199-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 11:35 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>
> From: Willem de Bruijn <willemb@google.com>
>
> When inheriting tx_flags from one skbuff to another, always apply a
> mask to avoid overwriting unrelated other bits in the field.
>
> The two SKBTX_SHARED_FRAG cases clears all other bits. In practice,
> tx_flags are zero at this point now. But this is fragile. Timestamp
> flags are set, for instance, if in tcp_gso_segment, after this clear
> in skb_segment.
>
> The SKBTX_ANY_TSTAMP mask in __skb_tstamp_tx ensures that new
> skbs do not accidentally inherit flags such as SKBTX_SHARED_FRAG.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Acked-by: Soheil Hassas Yeganeh <soheil@google.com>
