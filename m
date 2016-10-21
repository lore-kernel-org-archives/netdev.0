From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sched: make default fifo qdiscs appear in the dump
Date: Fri, 21 Oct 2016 04:36:57 -0700
Message-ID: <1477049817.7065.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1610211024400.31629@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Phil Sutter <phil@nwl.cc>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1610211024400.31629@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-21 at 10:45 +0200, Jiri Kosina wrote:
> The original reason [1] for having hidden qdiscs (potential scalability 
> issues in qdisc_match_from_root() with single linked list in case of large 
> amount of qdiscs) has been invalidated by 59cc1f61f0 ("net: sched: convert 
> qdisc linked list to hashtable").
> 
> This allows us for bringing more clarity and determinism into the dump by 
> making default pfifo qdiscs visible.
> 
> [1] http://lkml.kernel.org/r/1460732328.10638.74.camel@edumazet-glaptop3.roam.corp.google.com
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---

Some of us are dealing with huge HTB hierarchies, so adding default fifo
in the dump will add more data pumped from the kernel.

BwE [1] for instance dumps qdisc/classes every 5 seconds.

I guess we'll need to not pull this patch in our kernels.

This reminds me of an HTB patch to avoid dumping rate estimates for HTB.

I will send it today.
 
[1]
http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/43838.pdf
