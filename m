From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH net-next] net: add rbnode to struct sk_buff
Date: Mon, 3 Nov 2014 13:34:33 -0800
Message-ID: <CAHA+R7M0--G=znvqQwy5Qmnm5po9yApcn4LjSSv8+-5c1D7RwQ@mail.gmail.com>
References: <1415031593.14083.25.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yaogong Wang <wygivan@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f175.google.com ([209.85.217.175]:52873 "EHLO
	mail-lb0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbaKCVef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 16:34:35 -0500
Received: by mail-lb0-f175.google.com with SMTP id n15so2049297lbi.20
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 13:34:33 -0800 (PST)
In-Reply-To: <1415031593.14083.25.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 3, 2014 at 8:19 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>  struct sk_buff {
> -       /* These two members must be first. */
> -       struct sk_buff          *next;
> -       struct sk_buff          *prev;
> -
>         union {
> -               ktime_t         tstamp;
> -               struct skb_mstamp skb_mstamp;
> +               struct {
> +                       /* These two members must be first. */
> +                       struct sk_buff          *next;
> +                       struct sk_buff          *prev;
> +
> +                       union {
> +                               ktime_t         tstamp;
> +                               struct skb_mstamp skb_mstamp;
> +                       };
> +               };
> +               struct rb_node  rbnode; /* used in netem & tcp stack */
>         };

No objections, but this is hacky, rbnode is larger than ->next + ->prev,
this means ->tstamp is always overwritten. This is why netem saves it
to its CB. This isn't flexible.

Maybe both netem and TCP ooo queue should consider CB? Not sure
if TCP still has any space for more CB though.
