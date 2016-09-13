From: Michael Ma <make0818@gmail.com>
Subject: Modification to skb->queue_mapping affecting performance
Date: Tue, 13 Sep 2016 15:59:12 -0700
Message-ID: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:35129 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754521AbcIMW7P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 18:59:15 -0400
Received: by mail-it0-f45.google.com with SMTP id r192so19017284ita.0
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 15:59:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi -

We currently use mqprio on ifb to work around the qdisc root lock
contention on the receiver side. The problem that we found was that
queue_mapping is already set when redirecting from ingress qdisc to
ifb (based on RX selection, I guess?) so the TX queue selection is not
based on priority.

Then we implemented a filter which can set skb->queue_mapping to 0 so
that TX queue selection can be done as expected and flows with
different priorities will go through different TX queues. However with
the queue_mapping recomputed, we found the achievable bandwidth with
small packets (512 bytes) dropped significantly if they're targeting
different queues. From perf profile I don't see any bottleneck from
CPU perspective.

Any thoughts on why modifying queue_mapping will have this kind of
effect? Also is there any better way of achieving receiver side
throttling using HTB while avoiding the qdisc root lock on ifb?

Thanks,
Michael
