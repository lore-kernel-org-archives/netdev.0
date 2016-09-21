From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 18:26:29 +0100
Message-ID: <20160921182629.7da23564@jkicinski-Precision-T1700>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
        <1474408824-418864-2-git-send-email-tom@herbertland.com>
        <20160920224416.GF3291@pox.localdomain>
        <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
        <20160920230927.GG3291@pox.localdomain>
        <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
        <20160920234347.GH3291@pox.localdomain>
        <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
        <20160921115545.GA12789@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:22652 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757999AbcIUR0j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 13:26:39 -0400
In-Reply-To: <20160921115545.GA12789@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 21 Sep 2016 13:55:45 +0200, Thomas Graf wrote:
> > I am looking at using this for ILA router. The problem I am hitting is
> > that not all packets that we need to translate go through the XDP
> > path. Some would go through the kernel path, some through XDP path but  
> 
> When you say kernel path, what do you mean specifically? One aspect of
> XDP I love is that XDP can act as an acceleration option for existing
> BPF programs attached to cls_bpf. Support for direct packet read and
> write at clsact level have made it straight forward to write programs
> which are compatible or at minimum share a lot of common code. They
> can share data structures, lookup functionality, etc.

My very humble dream was that XDP would be transparently offloaded from
cls_bpf if program was simple enough.  That ship has most likely sailed
because XDP has different abort behaviour.  When possible though, trying
to offload higher-level hooks when the rules don't require access to
full skb would be really cool.
