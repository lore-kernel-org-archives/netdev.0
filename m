From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] tcp-tso: fix faulty logic in tcp_tso_should_defer
Date: Thu, 4 Aug 2016 12:09:08 +0800
Message-ID: <CABa6K_FBoZAjesG7BkK_xdDvmOnkiZsq6HvABorx3bE15v6egQ@mail.gmail.com>
References: <75F60345-2612-4EF8-A7C3-8F0E1E6215B3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: edumazet@google.com, Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Liang Ge <lungothrin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34314 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750699AbcHDEJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 00:09:35 -0400
Received: by mail-it0-f67.google.com with SMTP id u186so17993150ita.1
        for <netdev@vger.kernel.org>; Wed, 03 Aug 2016 21:09:29 -0700 (PDT)
In-Reply-To: <75F60345-2612-4EF8-A7C3-8F0E1E6215B3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 4, 2016 at 12:01 PM, Liang Ge <lungothrin@gmail.com> wrote:
>
> code does not match comment
>
>         head = tcp_write_queue_head(sk);
>         skb_mstamp_get(&now);
>         age = skb_mstamp_us_delta(&now, &head->skb_mstamp);
>         /* If next ACK is likely to come too late (half srtt), do not defer */
>         if (age < (tp->srtt_us >> 4))
>                 goto send_now;
>
> This bug will cause TSO packets being transmitted too early, and force
> software to tear them apart.
>
> When ack clocking is likely to broke, this check will try to push out
> some EXTRA probe the first chance possible. Some transmission has
> already happened due to Eric's work.
>
> This patch fix the check.
> ---

Reviewed-by: Changli Gao <xiaosuo@gmail.com>



-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
