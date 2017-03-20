From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to
 refcount_t
Date: Mon, 20 Mar 2017 09:34:44 -0700
Message-ID: <1490027684.16816.63.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170318164759.GA23837@gondor.apana.org.au>
         <20170318.182121.439615057765380575.davem@davemloft.net>
         <20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
         <20170320131629.GA26405@gondor.apana.org.au>
         <20170320132357.acygo3umw6fiwb4p@hirez.programming.kicks-ass.net>
         <20170320132713.GA26954@gondor.apana.org.au>
         <20170320134017.h3c2jrsnd4guuyu7@hirez.programming.kicks-ass.net>
         <1490021461.16816.52.camel@edumazet-glaptop3.roam.corp.google.com>
         <1490021946.16816.54.camel@edumazet-glaptop3.roam.corp.google.com>
         <1490026735.16816.58.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        David Miller <davem@davemloft.net>, elena.reshetova@intel.com,
        keescook@chromium.org, netdev@vger.kernel.org,
        bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, ishkamiel@gmail.com,
        dwindsor@gmail.com, akpm@linux-foundation.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490026735.16816.58.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-20 at 09:18 -0700, Eric Dumazet wrote:

> Interesting.
> 
> UDP ipv4 xmit path gets a ~25 % improvement on PPC with this patch.
> 
> ( 20 concurrent netperf -t UDP_STREAM  : 2.45 Mpps -> 3.07 Mpps )

Well, there _is_ a difference, but not 25 % (this was probably caused by
different queues on TX or RX between my reboots).

I added a sysctl hack to be able to dynamically change on a given
workload, and we hit other bottlenecks (mainly qdisc locks and driver tx
locks) anyway.
