From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 16:48:00 +0200
Message-ID: <20160921144800.GB13991@pox.localdomain>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
 <20160920230927.GG3291@pox.localdomain>
 <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
 <20160920234347.GH3291@pox.localdomain>
 <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
 <20160921115545.GA12789@pox.localdomain>
 <CALx6S35Xctd-aA8DF1_vypMDejiGXcud6=UO33dqgvO60W0DZQ@mail.gmail.com>
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
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35706 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933316AbcIUOsE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 10:48:04 -0400
Received: by mail-wm0-f52.google.com with SMTP id l132so272700515wmf.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 07:48:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35Xctd-aA8DF1_vypMDejiGXcud6=UO33dqgvO60W0DZQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/16 at 07:19am, Tom Herbert wrote:
> certain design that because of constraints on one kernel interface. As
> a kernel developer I want flexibility on how we design and implement
> things!

Perfectly valid argument. I reviewed your ILA changes and did not
object to them.


> I think there are two questions that this patch set poses for the
> community wrt XDP:
> 
> #1: Should we allow alternate code to run in XDP other than BPF?
> #2: If #1 is true what is the best way to implement that?
> 
> If the answer to #1 is "no" then the answer to #2 is irrelevant. So
> with this RFC I'm hoping we can come the agreement on questions #1.

I'm not opposed to running non-BPF code at XDP. I'm against adding
a linked list of hook consumers.

Would anyone require to run XDP-BPF in combination ILA? Or XDP-BPF
in combination with a potential XDP-nftables? We don't know yet I
guess.

Maybe exclusive access to the hook for one consumer as selected by
the user is good enough.

If that is not good enough: BPF (and potentially nftables in the
future) could provide means to perform a selection process where a
helper call can run another XDP prog or return a verdict to trigger
another XDP prog. Definitely more flexible and faster than a linear
list doing  if, else if, else if, else if, ...
