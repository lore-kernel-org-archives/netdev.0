From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Thu, 11 Dec 2003 02:06:09 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312110135440.1519-100000@u.domain.uli>
References: <20031210152039.055e887a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: niv@us.ibm.com, <ak@suse.de>, <ruddk@us.ibm.com>, <kuznet@ms2.inr.ac.ru>,
        <netdev@oss.sgi.com>, <chester.f.johnson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031210152039.055e887a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 10 Dec 2003, David S. Miller wrote:

> > is to see only one TOS value used. That is why I propose
> > to eliminate the TOS as hash key and to walk one row. At first
> > look, the risk of DoS is same, thanks to the random value.
>
> This is not my understanding at all.
>
> Consider the case where we generate routing cache entries for
> all 8 TOS values.  Currently we'll likely get a O(1) lookup
> for any one of those entries.

	IMO, the main question is whether all chains are with
~equal length, this depends on how good is the hash function. And
we hope it is good. Because these entries are always linked
somewhere and if they do not slowdown one chain they surely slowdown
other chains. The total walk time is always same if all entries
are searched. This is more and more true if the average chain
length is longer than the number of TOS values used. Of course,
if the table is empty and the average chain length is 1-4
using TOS as hash key will be faster for 8 TOS values.
But the common average chain length for full table is 16 and the
different TOS values are usually 1 or 2 per path. We do not talk
about intentional DoS.

> Your proposal guarentees that all such entries will land to the
> same hash chain, since TOS is not an input for the hash any longer.
> Therefore the lookup in my example case will be O(8).

	Yes, it will look very slow on empty table and when we do
not ignore the TOS values.

> And instead of just eating the complexity at ICMP PMTU handling
> time, we eat the complexity at every routing cache lookup.

	For solving the PMTUD problems, I still do not know how
we can avoid walking 8 chains if the TOS is a hash key. This is
a real DoS because 8 is too longer compared with the common case of
walking 1 chain with 1-2 TOS values. BTW, there are 1-2 entries
for OIF too.

Regards

--
Julian Anastasov <ja@ssi.bg>
