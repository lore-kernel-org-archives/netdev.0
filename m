From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: add proper TS val into RST packets
Date: Wed, 23 Sep 2015 13:36:21 -0700
Message-ID: <CAK6E8=eJfmZV_O14JqucQD4LD+OCybhB1D+PV2giz-Jmpph3qA@mail.gmail.com>
References: <1443039593.29850.133.camel@edumazet-glaptop2.roam.corp.google.com>
 <CADVnQynZ97Ben7TOSiNOxsfamQEkuw4VH4xxzj4=hpN_rgySJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f48.google.com ([209.85.213.48]:34983 "EHLO
	mail-vk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195AbbIWUhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 16:37:02 -0400
Received: by vkao3 with SMTP id o3so35525513vka.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 13:37:01 -0700 (PDT)
In-Reply-To: <CADVnQynZ97Ben7TOSiNOxsfamQEkuw4VH4xxzj4=hpN_rgySJw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 1:30 PM, Neal Cardwell <ncardwell@google.com> wrote:
>
> On Wed, Sep 23, 2015 at 4:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > RST packets sent on behalf of TCP connections with TS option (RFC 7323
> > TCP timestamps) have incorrect TS val (set to 0), but correct TS ecr.
> >
> > A > B: Flags [S], seq 0, win 65535, options [mss 1000,nop,nop,TS val 100 ecr 0], length 0
> > B > A: Flags [S.], seq 2444755794, ack 1, win 28960, options [mss 1460,nop,nop,TS val 7264344 ecr 100], length 0
> > A > B: Flags [.], ack 1, win 65535, options [nop,nop,TS val 110 ecr 7264344], length 0
> >
> > B > A: Flags [R.], seq 1, ack 1, win 28960, options [nop,nop,TS val 0 ecr 110], length 0
> >
> > We need to call skb_mstamp_get() to get proper TS val,
> > derived from skb->skb_mstamp
> >
> > Note that RFC 1323 was advocating to not send TS option in RST segment,
> > but RFC 7323 recommends the opposite :
> >
> >   Once TSopt has been successfully negotiated, that is both <SYN> and
> >   <SYN,ACK> contain TSopt, the TSopt MUST be sent in every non-<RST>
> >   segment for the duration of the connection, and SHOULD be sent in an
> >   <RST> segment (see Section 5.2 for details)
Nice comment. I think it's worth adding why we choose not to follow
RFC7323 sec 5.2 recommendation on setting TSval to 0?


>
> >
> > Fixes: 7faee5c0d514 ("tcp: remove TCP_SKB_CB(skb)->when")
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
>
> Acked-by: Neal Cardwell <ncardwell@google.com>
>
> Thanks, Eric!
>
> neal
