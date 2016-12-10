From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] netfilter: nft_counter: rework atomic dump and
 reset
Date: Sat, 10 Dec 2016 07:40:08 -0800
Message-ID: <1481384408.4930.210.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1481378741-19871-1-git-send-email-pablo@netfilter.org>
         <20161210141655.GA19963@salvia> <20161210142501.GA25221@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, arnd@arndb.de,
        netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36374 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751096AbcLJPkK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2016 10:40:10 -0500
In-Reply-To: <20161210142501.GA25221@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-12-10 at 15:25 +0100, Pablo Neira Ayuso wrote:
> On Sat, Dec 10, 2016 at 03:16:55PM +0100, Pablo Neira Ayuso wrote:
=
>  
> -       nft_counter_fetch(priv, &total, reset);
> +       nft_counter_fetch(priv, &total);
> +       if (reset)
> +               nft_counter_reset(priv, &total);
>  
>         if (nla_put_be64(skb, NFTA_COUNTER_BYTES,
> cpu_to_be64(total.bytes),
>                          NFTA_COUNTER_PAD) ||

Night be nitpicking, but you might reset the stats only if the
nla_put_be64() succeeded.

But regardless of this detail, patch looks good and is very close to the
one I cooked and was about to send this morning.

Thanks Pablo !
