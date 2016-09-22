From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Thu, 22 Sep 2016 07:46:23 -0700
Message-ID: <1474555583.23058.107.camel@edumazet-glaptop3.roam.corp.google.com>
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
         <20160921144800.GB13991@pox.localdomain>
         <CALx6S36ZCdh5iOp6CPfztVKOEkDFgUo1RyqWMJVxhakOYNx8iw@mail.gmail.com>
         <20160921215658.2c61ed5e@redhat.com> <20160922151403.24648381@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, Thomas Graf <tgraf@suug.ch>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35846 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757385AbcIVOq0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 10:46:26 -0400
Received: by mail-pa0-f46.google.com with SMTP id qn7so12574868pac.3
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 07:46:25 -0700 (PDT)
In-Reply-To: <20160922151403.24648381@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-22 at 15:14 +0200, Jesper Dangaard Brouer wrote:
> On Wed, 21 Sep 2016 21:56:58 +0200
> Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> 
> > > > I'm not opposed to running non-BPF code at XDP. I'm against adding
> > > > a linked list of hook consumers.  
> > 
> > I also worry about the performance impact of a linked list.  We should
> > simple benchmark it instead of discussing it! ;-)
> 
> (Note, there are some stability issue with this RFC patchset, when
> removing the xdp program, that I had to workaround/patch)
> 
> 
> I've started benchmarking this and I only see added cost of 2.89ns from
> these patches, at these crazy speeds it does correspond to -485Kpps.

I claim the methodology is too biased.

At full speed, all the extra code is hot in caches, and your core has
full access to memory bus anyway. Even branch predictor has fresh
information.

Now, in a mixed workload, where all cores compete to access L2/L3 and
RAM, things might be very different.

Testing icache/dcache pressure is not a matter of measuring how many
Kpps you add or remove on a hot path.

A latency test, when other cpus are busy reading/writing all over
memory, and your caches are cold, would be useful.
