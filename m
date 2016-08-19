From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 2/2] net: sched: avoid duplicates in qdisc dump
Date: Fri, 19 Aug 2016 23:48:14 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608192343480.22028@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1608162339050.22028@cbobk.fhfr.pm> <alpine.LNX.2.00.1608162350330.22028@cbobk.fhfr.pm> <CAM_iQpW9QOADkzDDEGYjTNnW21uwHX5xFx1iX=Wio5=i34kDbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Simon Horman <simon.horman@netronome.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Phil Sutter <phil@nwl.cc>, LKML <linux-kernel@vger.kernel.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpW9QOADkzDDEGYjTNnW21uwHX5xFx1iX=Wio5=i34kDbQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Aug 2016, Cong Wang wrote:

> Doesn't this mean we can now just remove the ingress case from 
> tc_dump_qdisc() and simply iterate the whole hash table?

That'd be indeed a nice cleanup, but for that we'll have to make sure that 
the top-level ingress entry makes it to the hashtable as well; that's not 
the case currently, and hence the special-casing (but I agree that it's in 
principle just a remnant of the old design and of a rather 1:1 
list->hashtable conversion, and there is no good reason for keeping it 
this way any more).

So patch that'd add ingress qdisc to the hashtable whenever it 
materializes should be enough to get rid of the "we have to walk two 
linked lists" heritage and the ingress special-casing for dumps.

Will look into it next week unless someone is faster.

Thanks,

-- 
Jiri Kosina
SUSE Labs
