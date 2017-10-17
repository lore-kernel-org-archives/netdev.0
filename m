From: David Ahern <dsahern@gmail.com>
Subject: Re: WARNING in tcp_update_reordering
Date: Mon, 16 Oct 2017 19:00:39 -0600
Message-ID: <7a626cf6-e1c4-ea17-c790-a6901383b1b1@gmail.com>
References: <5cd139e4-5a50-ba99-d54a-cfe06ccee3e9@gmail.com>
 <CAK6E8=ejn5GoscPBh5PdhQTzcU1wZ66=8ZS806Tox_S9CvnZaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Andrei Vagin <avagin@gmail.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:47058 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752981AbdJQBAl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 21:00:41 -0400
Received: by mail-pf0-f195.google.com with SMTP id p87so98035pfj.3
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 18:00:41 -0700 (PDT)
In-Reply-To: <CAK6E8=ejn5GoscPBh5PdhQTzcU1wZ66=8ZS806Tox_S9CvnZaA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ cc Andrei who reported a similar trace ]

On 10/16/17 6:50 PM, Yuchung Cheng wrote:
> On Mon, Oct 16, 2017 at 3:38 PM, David Ahern <dsahern@gmail.com> wrote:
>> I need to throw this one over the fence. I triggered the trace below
>> testing changes to the tcp tracepoint. It is not readily reproducible
>> and does not appear to be correlated to the perf session.
> We're seeing this internally at Google a lot as well. The culprit is
> because TCP tries to measure/track reordering in precise packet
> distance (tp->reordering). That's difficult but also fairly useless to
> get right because that highly depends on the instantaneous
> traffic load and L2/pathing behavior. In other words the previous
> reordering degree has little bearing for my next reordering based on
> our analysis. The
> warning itself has minor to no impact on TCP performance or
> reliability.
> 
> I am testing a patch to replace that approach (and remove the
> warning). Should be ready soon.
> 

Thanks for the update.
