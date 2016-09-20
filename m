From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 01:43:47 +0200
Message-ID: <20160920234347.GH3291@pox.localdomain>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
 <20160920230927.GG3291@pox.localdomain>
 <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35455 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751729AbcITXnu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 19:43:50 -0400
Received: by mail-wm0-f41.google.com with SMTP id l132so237106289wmf.0
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:43:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/16 at 04:18pm, Tom Herbert wrote:
> This allows other use cases than BPF inserting code into the data
> path. This gives XDP potential more utility and more users so that we
> can motivate more driver implementations. For instance, I thinks it's
> totally reasonable if the nftables guys want to insert some of their
> rules to perform early DDOS drop to get the same performance that we
> see in XDP.

Reasonable point with nftables but are any of these users on the table
already and ready to consume non-skbs? It would be a pity to add this
complexity and cost if it is never used.

I don't see how we can ensure performance if we have multiple
subsystems register for the hook each adding their own parsers which
need to be passed through sequentially. Maybe I'm missing something.
