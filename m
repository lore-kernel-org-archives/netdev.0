From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 07/17] net: convert sock.sk_refcnt from atomic_t to
 refcount_t
Date: Mon, 20 Mar 2017 11:39:37 +0100
Message-ID: <20170320103937.lq7nfnutupr3gkn7@hirez.programming.kicks-ass.net>
References: <1489767196.28631.305.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170318164759.GA23837@gondor.apana.org.au>
 <20170318.182121.439615057765380575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, eric.dumazet@gmail.com,
        elena.reshetova@intel.com, keescook@chromium.org,
        netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, kaber@trash.net, stephen@networkplumber.org,
        ishkamiel@gmail.com, dwindsor@gmail.com, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170318.182121.439615057765380575.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 18, 2017 at 06:21:21PM -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sun, 19 Mar 2017 00:47:59 +0800
> 
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> On Fri, 2017-03-17 at 07:42 +0000, Reshetova, Elena wrote:
> >> 
> >>> Should we then first measure the actual numbers to understand what we
> >>> are talking here about? 
> >>> I would be glad to do it if you suggest what is the correct way to do
> >>> measurements here to actually reflect the real life use cases. 
> >> 
> >> How have these patches been tested in real life exactly ?
> >> 
> >> Can you quantify number of added cycles per TCP packet, where I expect
> >> we have maybe 20 atomic operations in all layers ...
> > 
> > I completely agree.  I think this thing needs to default to the
> > existing atomic_t behaviour.
> 
> I totally agree as well, the refcount_t facility as-is is unacceptable
> for networking.

Can we at least give a benchmark and have someone run numbers? We should
be able to quantify these things.
