From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next 0/3] tcp: improving RACK cpu performance
Date: Fri, 6 Oct 2017 09:34:48 -0700
Message-ID: <CAK6E8=fBi05MuH_r9XrsmavUqQrtgvWbUv-7MXFyBYg1udsrXw@mail.gmail.com>
References: <20171004200000.39257-1-ycheng@google.com> <20171005.212612.1580802624897584218.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:46983 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751489AbdJFQfb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 12:35:31 -0400
Received: by mail-wr0-f170.google.com with SMTP id z1so4608977wre.3
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 09:35:30 -0700 (PDT)
In-Reply-To: <20171005.212612.1580802624897584218.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 5, 2017 at 9:26 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Yuchung Cheng <ycheng@google.com>
> Date: Wed,  4 Oct 2017 12:59:57 -0700
>
> > This patch set improves the CPU consumption of the RACK TCP loss
> > recovery algorithm, in particular for high-speed networks. Currently,
> > for every ACK in recovery RACK can potentially iterate over all sent
> > packets in the write queue. On large BDP networks with non-trivial
> > losses the RACK write queue walk CPU usage becomes unreasonably high.
> >
> > This patch introduces a new queue in TCP that keeps only skbs sent and
> > not yet (s)acked or marked lost, in time order instead of sequence
> > order.  With that, RACK can examine this time-sorted list and only
> > check packets that were sent recently, within the reordering window,
> > per ACK. This is the fastest way without any write queue walks. The
> > number of skbs examined per ACK is reduced by orders of magnitude.
>
> That's a pretty risky way to implement the second SKB list.... but
Agreed. I really appreciate you accepting this change. We tried a few
alternatives but this is the most clean and fastest approach. BBR can
reach 8-10Gbps on 300ms RTT link so both RACK and SACK need to scale
in the era of hundreds MB BDP :-)

> you avoided making sk_buff larger so what can I say :-)
>
> Series applied, thank.
