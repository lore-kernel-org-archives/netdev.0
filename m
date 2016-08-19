From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net: sched: avoid duplicates in qdisc dump
Date: Thu, 18 Aug 2016 18:39:31 -0700
Message-ID: <CAM_iQpW9QOADkzDDEGYjTNnW21uwHX5xFx1iX=Wio5=i34kDbQ@mail.gmail.com>
References: <alpine.LNX.2.00.1608162339050.22028@cbobk.fhfr.pm> <alpine.LNX.2.00.1608162350330.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Simon Horman <simon.horman@netronome.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>, LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1608162350330.22028@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 16, 2016 at 2:53 PM, Jiri Kosina <jikos@kernel.org> wrote:
> From: Jiri Kosina <jkosina@suse.cz>
>
> tc_dump_qdisc() performs dumping of the per-device qdiscs in two phases;
> first, the "standard" dev->qdisc is being dumped. Second, if there is/are
> ingress queue(s), they are being dumped as well.
>
> After conversion of netdevice's qdisc linked-list into hashtable, these
> two sets are not in two disjunctive sets/lists any more, but are both
> "reachable" directly from netdevice's hashtable. As a consequence, the
> "full-depth" dump of the ingress qdiscs results in immediately hitting the
> netdevice hashtable again, and duplicating the dump that has already been
> performed for dev->qdisc.
> What in fact needs to be dumped in case of ingress queue is "just" the
> top-level ingress qdisc, as everything else has been dumped already.

Doesn't this mean we can now just remove the ingress case from
tc_dump_qdisc() and simply iterate the whole hash table?
