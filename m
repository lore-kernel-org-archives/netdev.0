From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net] ipv6: remove incorrect WARN_ON() in fib6_del()
Date: Mon, 25 Sep 2017 19:23:58 -0700
Message-ID: <CANn89iJWo8U=csnZNh+QHh7Sf8+Gaig56-HU9BbZbGeeFs5g3w@mail.gmail.com>
References: <20170925173522.99892-1-tracywwnj@gmail.com> <20170926005618.z4ymlry7jl47nkjm@kafai-mbp.dhcp.thefacebook.com>
 <CAEA6p_CvtmNaYcgSSyFNEbip1ckKwLjJH3PJTOqym0hCt-x2uw@mail.gmail.com> <20170926020720.gnvfz6xch4frf2dy@kafai-mbp>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Wei Wang <weiwan@google.com>, David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:54558 "EHLO
        mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965067AbdIZCYA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 22:24:00 -0400
Received: by mail-yw0-f175.google.com with SMTP id w9so6120493ywi.11
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 19:24:00 -0700 (PDT)
In-Reply-To: <20170926020720.gnvfz6xch4frf2dy@kafai-mbp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 7:07 PM, Martin KaFai Lau <kafai@fb.com> wrote:

> I am probably still missing something.
>
> Considering the del operation should be under the writer lock,
> if rt->rt6i_node should be NULL (for rt that has already been
> removed from fib6), why this WARN_ON() is triggered?
>
> An example may help.
>

Look at the stack trace, you'll find the answers...

ip6_link_failure() -> ip6_del_rt()

Note that rt might have been deleted from the _tree_ already.
