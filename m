From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH v4 net-next 16/16] tcp_bbr: add BBR congestion control
Date: Tue, 20 Sep 2016 16:56:28 -0700
Message-ID: <CANn89iK=+FxFf7T27xymDmCTr-dwsjvCvwsaTYnM4GjTBn_cXA@mail.gmail.com>
References: <1474342763-16715-1-git-send-email-ncardwell@google.com>
 <1474342763-16715-17-git-send-email-ncardwell@google.com> <20160920163906.7c6d69fe@xeon-e3>
 <CADVnQymgWrzxLSE8r9pE_fOcXLbg+QTMco7grZnmPH2EVre=pw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        David Miller <davem@davemloft.net>,
        Netdev <netdev@vger.kernel.org>, Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:36572 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751729AbcITX4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 19:56:33 -0400
Received: by mail-yw0-f179.google.com with SMTP id t67so27112209ywg.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:56:32 -0700 (PDT)
In-Reply-To: <CADVnQymgWrzxLSE8r9pE_fOcXLbg+QTMco7grZnmPH2EVre=pw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 4:42 PM, Neal Cardwell <ncardwell@google.com> wrote:
>
> On Tue, Sep 20, 2016 at 7:39 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> >
> >> NOTE: BBR *must* be used with the fq qdisc ("man tc-fq") with pacing
> >> enabled, since pacing is integral to the BBR design and
> >> implementation. BBR without pacing would not function properly, and
> >> may incur unnecessary high packet loss rates.
> >
> > Does it work with fq_codel?
>
> Good question. Since fq_codel does not (currently) implement pacing,
> it would not be sufficient to get the required behavior.
>
> neal


fq_codel is stochastic, so it wont work very well on hosts with
1,000,000 flows or more...

fq_codel is aimed for routers, while sch_fq targets hosts,
implementing pacing at a minimal cost (one high resolution timer per
qdisc)
