From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] skbuff: only inherit relevant tx_flags
Date: Thu, 08 Jun 2017 09:20:32 -0700
Message-ID: <1496938832.736.76.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170608153503.74199-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, soheil@google.com,
        Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33398 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751701AbdFHQUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 12:20:49 -0400
Received: by mail-pf0-f196.google.com with SMTP id f27so5684577pfe.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 09:20:49 -0700 (PDT)
In-Reply-To: <20170608153503.74199-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-06-08 at 11:35 -0400, Willem de Bruijn wrote:
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


Acked-by: Eric Dumazet <edumazet@google.com>
