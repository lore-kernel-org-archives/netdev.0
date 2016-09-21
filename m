From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 08:08:34 -0700
Message-ID: <CALx6S36ZCdh5iOp6CPfztVKOEkDFgUo1RyqWMJVxhakOYNx8iw@mail.gmail.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com> <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
 <20160920230927.GG3291@pox.localdomain> <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
 <20160920234347.GH3291@pox.localdomain> <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
 <20160921115545.GA12789@pox.localdomain> <CALx6S35Xctd-aA8DF1_vypMDejiGXcud6=UO33dqgvO60W0DZQ@mail.gmail.com>
 <20160921144800.GB13991@pox.localdomain>
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
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36040 "EHLO
        mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756660AbcIUPIg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 11:08:36 -0400
Received: by mail-qk0-f171.google.com with SMTP id z190so48348554qkc.3
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 08:08:35 -0700 (PDT)
In-Reply-To: <20160921144800.GB13991@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 7:48 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/21/16 at 07:19am, Tom Herbert wrote:
>> certain design that because of constraints on one kernel interface. As
>> a kernel developer I want flexibility on how we design and implement
>> things!
>
> Perfectly valid argument. I reviewed your ILA changes and did not
> object to them.
>
>
>> I think there are two questions that this patch set poses for the
>> community wrt XDP:
>>
>> #1: Should we allow alternate code to run in XDP other than BPF?
>> #2: If #1 is true what is the best way to implement that?
>>
>> If the answer to #1 is "no" then the answer to #2 is irrelevant. So
>> with this RFC I'm hoping we can come the agreement on questions #1.
>
> I'm not opposed to running non-BPF code at XDP. I'm against adding
> a linked list of hook consumers.
>
> Would anyone require to run XDP-BPF in combination ILA? Or XDP-BPF
> in combination with a potential XDP-nftables? We don't know yet I
> guess.
>
Right. Admittedly, I feel like we owe a bit of reciprocity to
nftables. For ILA we are using the NF_INET_PRE_ROUTING hook with our
own code (looks like ipvlan set nfhooks as well). This works really
well and saves the value of early demux in ILA. Had we not had the
ability to use nfhooks in this fashion it's likely we would have had
to create another hook (we did try putting translation in nftables
rules but that was too inefficient for ILA).

> Maybe exclusive access to the hook for one consumer as selected by
> the user is good enough.
>
> If that is not good enough: BPF (and potentially nftables in the
> future) could provide means to perform a selection process where a
> helper call can run another XDP prog or return a verdict to trigger
> another XDP prog. Definitely more flexible and faster than a linear
> list doing  if, else if, else if, else if, ...

It seems reasonable that the the output of one program may be an
indication of another program. We've already talked about something
like that in regards to splitting BPF programs into device independent
program and device dependent program.

Tom
