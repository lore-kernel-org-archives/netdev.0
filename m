From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] tcp: Check daddr_cache before use in tracepoint
Date: Tue, 17 Oct 2017 10:05:02 -0700
Message-ID: <CAM_iQpW=K0UkdB__WPvNPviz_syn-DKWum=Z9cam_EV4eqaTFQ@mail.gmail.com>
References: <1508189387-27931-1-git-send-email-dsahern@gmail.com>
 <1508211908.31614.90.camel@edumazet-glaptop3.roam.corp.google.com> <f0320a62-708b-6b7c-bf58-23b9e8df6cdc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:52756 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934225AbdJQRFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 13:05:23 -0400
Received: by mail-pg0-f53.google.com with SMTP id a192so1899393pge.9
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 10:05:23 -0700 (PDT)
In-Reply-To: <f0320a62-708b-6b7c-bf58-23b9e8df6cdc@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 8:32 AM, David Ahern <dsahern@gmail.com> wrote:
> On 10/16/17 9:45 PM, Eric Dumazet wrote:
>> IPV6 TCP uses sk->sk_v6_daddr and sk->->sk_v6_rcv_saddr
>
> I moved v2 to those.
>
>> So I would rather remove the need to fetch np = inet6_sk(sk) in the
>> first place, and look at sk->sk_family instead.
>
> I'll spin a v3 with that change.

Note, with CONFIG_IPV6=n, inet6_sk() is just NULL and compiler
could eliminate the if(NULL) branch, I doubt compiler could do same
for sk->sk_family.

Oh, BTW, I thought it is okay to use sk_v6_daddr in if (NULL)
case (aka CONFIG_IPV6=n), but a quick test shows compiler still
complains... so probably need #if IS_ENABLED(CONFIG_IPV6).
