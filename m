From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 23:18:05 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312102301550.1285-100000@u.domain.uli>
References: <3FD7832B.3010709@us.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@suse.de>, "Kevin W. Rudd" <ruddk@us.ibm.com>,
        <davem@redhat.com>, <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
        <chester.f.johnson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <3FD7832B.3010709@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 10 Dec 2003, Nivedita Singhvi wrote:

> Julian Anastasov wrote:
>
> > 	It can be an option: pmtu_promisc or whatever (default 0).
> > We should avoid using TOS as hash key and if the var is 1 we should
> > ignore matching the tos keys in ip_rt_frag_needed and ip_rt_redirect.
> > By this way, all cache entries between saddr and daddr will be updated, no
> > matter the TOS or even OIF keys. Comments?
>
> This is what I was going to suggest too, but one of the drawbacks
> would be needing the user to recompile the distro kernel just
> for this..could we keep any fix to this dynamically tunable?

	Yes, I mean sysctl var in /proc. For now, there are two
needs:

1. update PMTU info ignoring TOS and OIF

2. Reduce the number of hash entries by ignoring the TOS, may be
depending on CONFIG_IP_ROUTE_TOS, it would be preferred to be
sysctl var but the real benefits depend on the TOS usage.

	I see three cases:

1. we do not route by TOS => we want to ignore TOS everywhere, if
possible, sysctl var variant for IPTOS_RT_MASK=0

2. we route by TOS (IPTOS_RT_MASK!=0) but we like the idea to
ignore TOS for PMTUD and ICMP redirects.

3. the current behavior, PMTUD does not work if TOS is changed,
the routing cache keeps many entries with different TOS

	The question is how many proc entries are needed for these
cases. It seems, we can cover all cases with one proc entry: to
make IPTOS_RT_MASK a sysctl var. But there is still difference
between cases 1 and 2, may be the var will have more than 2 values?

> thanks,
> Nivedita

Regards

--
Julian Anastasov <ja@ssi.bg>
