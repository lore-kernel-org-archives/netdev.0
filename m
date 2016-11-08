From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [net-next PATCH 3/3] qdisc: catch misconfig of attaching qdisc to
 tx_queue_len zero device
Date: Mon, 7 Nov 2016 22:14:37 -0800
Message-ID: <CAHo-Oozk1AqqR4+9HxLYSGQOQ8Ohs0NaOx=ZV+94JCH-ftxtMw@mail.gmail.com>
References: <20161103135534.28737.37657.stgit@firesoul> <20161103135611.28737.39840.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux NetDev <netdev@vger.kernel.org>, Phil Sutter <phil@nwl.cc>,
        Robert Olsson <robert@herjulf.se>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:34071 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752723AbcKHGOi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 01:14:38 -0500
Received: by mail-yw0-f196.google.com with SMTP id l124so6243020ywb.1
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2016 22:14:38 -0800 (PST)
In-Reply-To: <20161103135611.28737.39840.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just FYI:

I'm tangentially aware of internal Google code that:
- expects a bonding device running HTB with non-zero txqueuelen
- wants to remove HTB and get a noqueue interface (the normal default
for bonding)

The code currently removes HTB, which gets us to mq, sets txqueuelen
to 0, adds a pfifo, removes the pfifo, which gets us to noqueue.

After this patch this would ?possibly? break (adding pfifo, would
change txqueuelen, so when we remove it we wouldn't end up with
noqueue).

>From what I fuzzily recall, HTB with txquelelen == 0 drops traffic
hard, while pfifo continues to function, hence the ordering...

Obviously our code can be fixed, but I'm worried there's a more
generic backwards compatibility problem here.

(note: this is mostly about 3.11 and 4.3 and might no longer be
relevant with 4.10... maybe the new kernel's default qdisc selection
logic doesn't depend on txqueuelen and checks the flag instead???)
