From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp/dccp: drop SYN packets if accept queue is full
Date: Wed, 26 Oct 2016 12:42:43 -0700
Message-ID: <CAK6E8=cuTtOJfMH5sXM3LFKeq_30cqbZ6W8PoS1VXWBFs+FJmg@mail.gmail.com>
References: <1477499277.7065.193.camel@edumazet-glaptop3.roam.corp.google.com> <CADVnQy=f==Ffk_=xPN7hOHyu5sHqhgi3rUw89rTYn1fxF7HdqQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f169.google.com ([209.85.161.169]:35231 "EHLO
        mail-yw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755085AbcJZTnZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2016 15:43:25 -0400
Received: by mail-yw0-f169.google.com with SMTP id h14so18145300ywa.2
        for <netdev@vger.kernel.org>; Wed, 26 Oct 2016 12:43:25 -0700 (PDT)
In-Reply-To: <CADVnQy=f==Ffk_=xPN7hOHyu5sHqhgi3rUw89rTYn1fxF7HdqQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 26, 2016 at 11:39 AM, Neal Cardwell <ncardwell@google.com> wrote:
>
> On Wed, Oct 26, 2016 at 12:27 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > Per listen(fd, backlog) rules, there is really no point accepting a SYN,
> > sending a SYNACK, and dropping the following ACK packet if accept queue
> > is full, because application is not draining accept queue fast enough.
> >
> > This behavior is fooling TCP clients that believe they established a
> > flow, while there is nothing at server side. They might then send about
> > 10 MSS (if using IW10) that will be dropped anyway while server is under
> > stress.
> >
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
>
> Acked-by: Neal Cardwell <ncardwell@google.com>
Acked-by: Yuchung Cheng <ycheng@google.com>

It's too bad the git has no history of the extra young sockets check.
it seemed to be some kind bandaid fix before syn-cookie was invented?

>
> Great. Thanks, Eric!
>
> neal
