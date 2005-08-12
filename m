From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: 12 Aug 2005 13:39:44 +0200
Message-ID: <p73u0hv2xkv.fsf@verdi.suse.de>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
	<20050811.154204.102613246.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050811.154204.102613246.davem@davemloft.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:

> From: Harald Welte <laforge@netfilter.org>
> Date: Thu, 11 Aug 2005 22:03:49 +0200
> 
> > +struct ipt_connbytes_info
> > +{
> > +	struct {
> > +		u_int64_t from;	/* count to be matched */
> > +		u_int64_t to;	/* count to be matched */
> > +	} count;
> > +	u_int8_t what;		/* ipt_connbytes_what */
> > +	u_int8_t direction;	/* ipt_connbytes_direction */
> > +};
> 
> Won't work in x86 --> x86_64 compat environments.

Thanks for catching it.

The aligned u64 trick probably will

#define aligned_u64 unsigned long long __attribute__((aligned(8)))

It just forces i386 to be aligned too.

Then use aligned_u64 instead of u64/__u64/u_int64_t in all user visible 
places. Similar for signed types.

-Andi
