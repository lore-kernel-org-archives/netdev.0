From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Change txhash on some non-RTO retransmits
Date: Wed, 12 Oct 2016 17:22:24 +0200
Message-ID: <1476285744.5650.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20161011001841.1118150-1-brakmo@fb.com>
         <CAK6E8=eoK88K0APyO04LtefaaDg6qRtHgHcKgMjiDvdmNCkNng@mail.gmail.com>
         <D42294A7.1FB0A%brakmo@fb.com>
         <CAK6E8=c8yHaEsfqRW9O1z7Dj21iU96QqY6nkSCtUpTbKOOc8wQ@mail.gmail.com>
         <CAK6E8=cuuTY0u0xqSKmoVzAuCOMdCm2UhyFxAgpa=51bvh_u-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lawrence Brakmo <brakmo@fb.com>, netdev <netdev@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        Neal Cardwell <ncardwell@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33918 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754043AbcJLPWa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 11:22:30 -0400
Received: by mail-pf0-f195.google.com with SMTP id 128so2952405pfz.1
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 08:22:30 -0700 (PDT)
In-Reply-To: <CAK6E8=cuuTY0u0xqSKmoVzAuCOMdCm2UhyFxAgpa=51bvh_u-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-10-11 at 20:56 -0700, Yuchung Cheng wrote:

> I thought more about this patch on my way home and have more
> questions: why do we exclude RTO retransmission specifically? also
> when we rehash, we'll introduce reordering either in recovery or after
> recovery, as some TCP CC like bbr would continue sending regardlessly,
> so starting in tcp_ack() with tp->txhash_want does not really prevent
> causing more reordering.

Note that changing txhash during a non rto retransmit is going to break
pacing on a bonding setup, since the change in txhash will likely select
a different slave, where MQ+FQ are the qdisc in place.
