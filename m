From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net] tcp: disallow cwnd undo when switching congestion control
Date: Wed, 31 May 2017 12:47:32 -0700
Message-ID: <CAK6E8=ePQTnh=kY1_HxEA6SCEAm2f48vmyk2UiqVBC2YZhE-wQ@mail.gmail.com>
References: <20170531182127.161289-1-ycheng@google.com> <20170531114732.1cfc4d79@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:34138 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750898AbdEaTsY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 15:48:24 -0400
Received: by mail-io0-f180.google.com with SMTP id k91so22484478ioi.1
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 12:48:19 -0700 (PDT)
In-Reply-To: <20170531114732.1cfc4d79@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 31, 2017 at 11:47 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
>
> On Wed, 31 May 2017 11:21:27 -0700
> Yuchung Cheng <ycheng@google.com> wrote:
>
> > When the sender switches its congestion control during loss
> > recovery, if the recovery is spurious then it may incorrectly
> > revert cwnd and ssthresh to the older values set by a previous
> > congestion control. Consider a congestion control (like BBR)
> > that does not use ssthresh and keeps it infinite: the connection
> > may incorrectly revert cwnd to an infinite value when switching
> > from BBR to another congestion control.
> >
> > This patch fixes it by disallowing such cwnd undo operation
> > upon switching congestion control.  Note that undo_marker
> > is not reset s.t. the packets that were incorrectly marked
> > lost would be corrected. We only avoid undoing the cwnd in
> > tcp_undo_cwnd_reduction().
> >
> > Signed-off-by: Yuchung Cheng <ycheng@google.com>
> > Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> > Signed-off-by: Neal Cardwell <ncardwell@google.com>
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
>
> That looks correct. Are there other values of congestion state
> that should be reset?
>
Nothing in particular comes up. We found this bug by internally
checking insane cwnd values on Google hosts. We might find more :-)
