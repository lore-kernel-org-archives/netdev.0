From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Modification to skb->queue_mapping affecting performance
Date: Tue, 13 Sep 2016 16:07:01 -0700
Message-ID: <1473808021.18970.246.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:32964 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932178AbcIMXHE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 19:07:04 -0400
Received: by mail-pf0-f181.google.com with SMTP id g202so111194pfb.0
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 16:07:03 -0700 (PDT)
In-Reply-To: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-13 at 15:59 -0700, Michael Ma wrote:
> Hi -
> 
> We currently use mqprio on ifb to work around the qdisc root lock
> contention on the receiver side. The problem that we found was that
> queue_mapping is already set when redirecting from ingress qdisc to
> ifb (based on RX selection, I guess?) so the TX queue selection is not
> based on priority.
> 
> Then we implemented a filter which can set skb->queue_mapping to 0 so
> that TX queue selection can be done as expected and flows with
> different priorities will go through different TX queues. However with
> the queue_mapping recomputed, we found the achievable bandwidth with
> small packets (512 bytes) dropped significantly if they're targeting
> different queues. From perf profile I don't see any bottleneck from
> CPU perspective.
> 
> Any thoughts on why modifying queue_mapping will have this kind of
> effect? Also is there any better way of achieving receiver side
> throttling using HTB while avoiding the qdisc root lock on ifb?

But, how many queues do you have on your NIC, and have you setup ifb to
have a same number of queues ?

There is no qdisc lock contention anymore AFAIK, since each cpu will use
a dedicate IFB queue and tasklet.
