From: "David S. Miller" <davem@redhat.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 15:20:39 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031210152039.055e887a.davem@redhat.com>
References: <20031210145149.2bd89e9b.davem@redhat.com>
	<Pine.LNX.4.44.0312110103280.1519-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, ak@suse.de, ruddk@us.ibm.com, kuznet@ms2.inr.ac.ru,
        netdev@oss.sgi.com, chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312110103280.1519-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 11 Dec 2003 01:15:06 +0200 (EET)
Julian Anastasov <ja@ssi.bg> wrote:

> It seems, there are no many users of OIF!=0 but if TOS is
> used as routing key we can see up to 8 entries with different
> TOS for same SADDR,DADDR. Of course, it looks difficult to
> walk 8 rows just to check all TOS variants, the common case
> is to see only one TOS value used. That is why I propose
> to eliminate the TOS as hash key and to walk one row. At first
> look, the risk of DoS is same, thanks to the random value.

This is not my understanding at all.

Consider the case where we generate routing cache entries for
all 8 TOS values.  Currently we'll likely get a O(1) lookup
for any one of those entries.

Your proposal guarentees that all such entries will land to the
same hash chain, since TOS is not an input for the hash any longer.
Therefore the lookup in my example case will be O(8).

And instead of just eating the complexity at ICMP PMTU handling
time, we eat the complexity at every routing cache lookup.

I really don't think we can consider this.
