From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 1/2] tcp: measure rwnd-limited time
Date: Thu, 8 Sep 2016 08:31:46 -0700
Message-ID: <CAK6E8=dhkD89=buv15VwaYewgh2FHByHAGBAVK-5t2ikjs_nKA@mail.gmail.com>
References: <1473211961-107223-1-git-send-email-francisyyan@gmail.com> <20160907.172742.1031784635164954011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: francisyyan@gmail.com, netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:37397 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750909AbcIHPc1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 11:32:27 -0400
Received: by mail-it0-f47.google.com with SMTP id e124so86838206ith.0
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 08:32:27 -0700 (PDT)
In-Reply-To: <20160907.172742.1031784635164954011.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 7, 2016 at 5:27 PM, David Miller <davem@davemloft.net> wrote:
>
> From: "Francis Y. Yan" <francisyyan@gmail.com>
> Date: Tue,  6 Sep 2016 18:32:40 -0700
>
> > diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> > index 7be9b12..f5b588e 100644
> > --- a/include/linux/tcp.h
> > +++ b/include/linux/tcp.h
> > @@ -176,6 +176,7 @@ struct tcp_sock {
> >                                * were acked.
> >                                */
> >       struct u64_stats_sync syncp; /* protects 64bit vars (cf tcp_get_info()) */
> > +     seqcount_t seqcnt;      /* proctects rwnd-limited-related vars, etc. */
> >
> >       u32     snd_una;        /* First byte we want an ack for        */
> >       u32     snd_sml;        /* Last byte of the most recently transmitted small packet */
> > @@ -204,6 +205,8 @@ struct tcp_sock {
> >
> >       u32     window_clamp;   /* Maximal window to advertise          */
> >       u32     rcv_ssthresh;   /* Current window clamp                 */
> > +     struct skb_mstamp rwnd_limited_ts; /* Last timestamp limited by rwnd */
> > +     u64     rwnd_limited;   /* Total time (us) limited by rwnd */
> >
> >       /* Information of the most recently (s)acked skb */
> >       struct tcp_rack {
>
> I understand completely the usefulness of this change, but wow that is a lot of
> new TCP socket space taken up just to export some time values in tcp_info for
> debugging and statistics.
Thanks for raising the concern. The space requirement and timing
resolution should indeed be justified better on the motivation and the
dev plan. We would resubmit a v2 with a cover letter detailing those.
