From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Tue, 20 Sep 2016 16:59:53 -0700
Message-ID: <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com> <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
 <20160920230927.GG3291@pox.localdomain> <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
 <20160920234347.GH3291@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34223 "EHLO
        mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752163AbcITX7z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 19:59:55 -0400
Received: by mail-qk0-f182.google.com with SMTP id n185so31381041qke.1
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 16:59:55 -0700 (PDT)
In-Reply-To: <20160920234347.GH3291@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 20, 2016 at 4:43 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/20/16 at 04:18pm, Tom Herbert wrote:
>> This allows other use cases than BPF inserting code into the data
>> path. This gives XDP potential more utility and more users so that we
>> can motivate more driver implementations. For instance, I thinks it's
>> totally reasonable if the nftables guys want to insert some of their
>> rules to perform early DDOS drop to get the same performance that we
>> see in XDP.
>
> Reasonable point with nftables but are any of these users on the table
> already and ready to consume non-skbs? It would be a pity to add this
> complexity and cost if it is never used.
>
Well, need to measure to ascertain the cost. As for complexity, this
actually reduces complexity needed for XDP in the drivers which is a
good thing because that's where most of the support and development
pain will be.

I am looking at using this for ILA router. The problem I am hitting is
that not all packets that we need to translate go through the XDP
path. Some would go through the kernel path, some through XDP path but
that would mean I need parallel lookup tables to be maintained for the
two paths which won't scale. ILA translation is so trivial and not
really something that we need to be user programmable, the fast path
is really for accelerating an existing kernel capability. If I can
reuse the kernel code already written and the existing kernel data
structures to make a fast path in XDP there is a lot of value in that
for me.

> I don't see how we can ensure performance if we have multiple
> subsystems register for the hook each adding their own parsers which
> need to be passed through sequentially. Maybe I'm missing something.

We can optimize for allowing only one hook, or maybe limit to only
allowing one hook to be set. In any case this obviously requires a lot
of performance evaluation, I am hoping to feedback on the design
first. My question about using a linear list for this was real, do you
know a better method off hand to implement a call list?

Thanks,
Tom
