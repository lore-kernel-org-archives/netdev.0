From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net] tcp: fix tcp_mtu_probe() vs highest_sack
Date: Tue, 31 Oct 2017 09:51:34 -0400
Message-ID: <CADVnQyk69gXG9BSMtmfK2jxjPtSUnHZuTVCMUDXOZ4FsR-72UA@mail.gmail.com>
References: <20170921014620.GA20906@castle> <CAK6E8=eBZ6XhRg7ihoQ_2=4bTk1RSdxT2zJ_Z7-4X-HzNeaiQQ@mail.gmail.com>
 <CAK6E8=c3mNnjuWDaA8rjnCjn8mAih=ReQiZwGUgB5X2xrjaRiA@mail.gmail.com>
 <2325466.Xo6SG5M5hd@natalenko.name> <CAK6E8=eju-MgROynJXntRCQ4KtXZ+qrgQC02bGJ27rp1wMmUjg@mail.gmail.com>
 <20171026020724.bgobtktvcpkhco4h@ast-mbp> <CAK6E8=ddfOpvr9wqb+3bo+-pQm2XLXuLhGSQk6xk0Tb8-UvHeA@mail.gmail.com>
 <CANn89iKm6E6vJ6m81ULFZVoVO3B5-pshB0=wPdvYgbYS+Wg8eQ@mail.gmail.com> <1509430100.3828.12.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        Yuchung Cheng <ycheng@google.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Oleksandr Natalenko <oleksandr@natalenko.name>,
        Roman Gushchin <guro@fb.com>, netdev <netdev@vger.kernel.org>,
        Lawrence Brakmo <brakmo@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:52064 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752748AbdJaNv6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 09:51:58 -0400
Received: by mail-wr0-f195.google.com with SMTP id j15so16027266wre.8
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 06:51:57 -0700 (PDT)
In-Reply-To: <1509430100.3828.12.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 31, 2017 at 2:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Based on SNMP values provided by Roman, Yuchung made the observation
> that some crashes in tcp_sacktag_walk() might be caused by MTU probing.
>
> Looking at tcp_mtu_probe(), I found that when a new skb was placed
> in front of the write queue, we were not updating tcp highest sack.
>
> If one skb is freed because all its content was copied to the new skb
> (for MTU probing), then tp->highest_sack could point to a now freed skb.
>
> Bad things would then happen, including infinite loops.
>
> This patch renames tcp_highest_sack_combine() and uses it
> from tcp_mtu_probe() to fix the bug.
>
> Note that I also removed one test against tp->sacked_out,
> since we want to replace tp->highest_sack regardless of whatever
> condition, since keeping a stale pointer to freed skb is a recipe
> for disaster.
>
> Fixes: a47e5a988a57 ("[TCP]: Convert highest_sack to sk_buff to allow direct access")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Alexei Starovoitov <alexei.starovoitov@gmail.com>
> Reported-by: Roman Gushchin <guro@fb.com>
> Reported-by: Oleksandr Natalenko <oleksandr@natalenko.name>
> ---
>  include/net/tcp.h     |    6 +++---
>  net/ipv4/tcp_output.c |    3 ++-
>  2 files changed, 5 insertions(+), 4 deletions(-)

Acked-by: Neal Cardwell <ncardwell@google.com>

Nice catch, indeed. Thanks, Eric!

neal
