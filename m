From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/3] tcp: enable xmit timer fix by having TLP use
 time when RTO should fire
Date: Tue, 01 Aug 2017 13:40:15 -0700
Message-ID: <1501620015.25002.5.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170801025814.31206-1-ncardwell@google.com>
         <20170801025814.31206-3-ncardwell@google.com>
         <1501572126.1876.31.camel@edumazet-glaptop3.roam.corp.google.com>
         <CADVnQy=A27-P7bystCPhu_Tk6cwLOL4Kqz2FSSg55nzNc3cixA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:37031 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752302AbdHAUkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 16:40:19 -0400
Received: by mail-wr0-f193.google.com with SMTP id 12so2262411wrb.4
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 13:40:19 -0700 (PDT)
In-Reply-To: <CADVnQy=A27-P7bystCPhu_Tk6cwLOL4Kqz2FSSg55nzNc3cixA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-01 at 10:35 -0400, Neal Cardwell wrote:
> On Tue, Aug 1, 2017 at 3:22 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Mon, 2017-07-31 at 22:58 -0400, Neal Cardwell wrote:
> >> @@ -2418,13 +2418,9 @@ bool tcp_schedule_loss_probe(struct sock *sk)
> >>       timeout = max_t(u32, timeout, msecs_to_jiffies(10));
> >>
> >>       /* If RTO is shorter, just schedule TLP in its place. */
> >
> > I have hard time to read this comment.
> >
> > We are here trying to arm a timer based on TLP.
> >
> > If RTO is shorter, we'll arm the timer based on RTO instead of TLP.
> >
> > Is "If RTO is shorter, just schedule TLP in its place." really correct ?
> >
> > I suggest we reword the comment or simply get rid of it now the code is
> > more obvious.
> 
> OK, how about:
> 
>   /* If the RTO formula yields an earlier time, then use that time. */
> 

Sounds better :)

> We can also add a reference to the RACK/TLP Internet Draft at the top
> of tcp_schedule_loss_probe().
> 
> Whatever wording we decide on, I am happy to send a patch for net-next
> once this fix is merged into net-next.

Sure.
