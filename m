From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH RFC tip/core/rcu 14/15] netfilter: Remove now-redundant
 smp_read_barrier_depends()
Date: Tue, 10 Oct 2017 10:43:34 +0200
Message-ID: <20171010084334.nbyhryiwyrl6km4u@hirez.programming.kicks-ass.net>
References: <20171010001951.GA6476@linux.vnet.ibm.com>
 <1507594969-8347-14-git-send-email-paulmck@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, mingo@kernel.org,
        torvalds@linux-foundation.org, mark.rutland@arm.com,
        dhowells@redhat.com, linux-arch@vger.kernel.org,
        will.deacon@arm.com, Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1507594969-8347-14-git-send-email-paulmck@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 05:22:48PM -0700, Paul E. McKenney wrote:
> READ_ONCE() now implies smp_read_barrier_depends(), which means that
> the instances in arpt_do_table(), ipt_do_table(), and ip6t_do_table()
> are now redundant.  This commit removes them and adjusts the comments.

Similar to the previous patch, the lack of READ_ONCE() in the original
code is a pre-existing bug. It would allow the compiler to tear the load
and observe a composite of two difference pointer values, or reload the
private pointer and result in table_base and jumpstacl being part of
different objects.

It would be good to point out this actually fixes a bug in the code.
