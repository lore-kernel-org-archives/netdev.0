From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next 01/10] tcp: add tp->tcp_mstamp field
Date: Tue, 25 Apr 2017 14:33:30 -0700
Message-ID: <CANn89iJz3ib9Se8beQpRpQ=ZmdG+QyD0GRz9bFu6SYvKBRgQwA@mail.gmail.com>
References: <20170425171541.3417-1-edumazet@google.com> <20170425171541.3417-2-edumazet@google.com>
 <CAK6E8=fhzzLKiUnB73upZdUUUSZ4t6HABmM17YGyEj93jLBkMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.161.180]:33145 "EHLO
        mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1432001AbdDYVdb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 17:33:31 -0400
Received: by mail-yw0-f180.google.com with SMTP id 203so99382330ywe.0
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 14:33:31 -0700 (PDT)
In-Reply-To: <CAK6E8=fhzzLKiUnB73upZdUUUSZ4t6HABmM17YGyEj93jLBkMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 25, 2017 at 2:27 PM, Yuchung Cheng <ycheng@google.com> wrote:

>> +       struct skb_mstamp tcp_mstamp; /* most recent packet received/sent */

> Eric: would this new stamp cover outgoing packet as well in the
> future? in the patch series seem to cover only the incoming packets.

This is the plan yes : tp->lsndtime will also be replaced for a better
TSO autodefer.

When it happens, tp->tcp_mstamp will be updated once per write episode.

And we'll remove a lot of skb_mstamp_get(&skb->skb_mstamp) calls all
over the places.
