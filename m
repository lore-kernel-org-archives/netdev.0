From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Thu, 11 Dec 2003 02:34:51 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312110219210.1519-100000@u.domain.uli>
References: <20031210160946.4110c611.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: niv@us.ibm.com, <ak@suse.de>, <ruddk@us.ibm.com>, <kuznet@ms2.inr.ac.ru>,
        <netdev@oss.sgi.com>, <chester.f.johnson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031210160946.4110c611.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 10 Dec 2003, David S. Miller wrote:

> On Thu, 11 Dec 2003 02:06:09 +0200 (EET)
> Julian Anastasov <ja@ssi.bg> wrote:
>
> > But the common average chain length for full table is 16 and the
> > different TOS values are usually 1 or 2 per path. We do not talk
> > about intentional DoS.
>
> Your system has not configured it's rthash table size properly, see
> recent discussions Robert has been making here.  You should have
> rthash sized somewhere near the number of entries a full system
> will have.
>
> But regardless, let us say that your system has complexity O(16)
> lookups as you mention, your proposal changes this to O(16+8).

	It is ~16 :)

	ip_rt_max_size = (rt_hash_mask + 1) * 16;

	This is what happens on full table, of course. OK,
some simple numbers for an ideal table:

- full table with 1024 chains, 16384 (max_size) entries equally
distributed in these 1024 chains, 16 per chain.

- there are 2048 paths with same saddr->daddr, each has 8 TOS values

2 cases depending on whether TOS is a hash key (path=saddr->daddr):

1. TOS is a hash key:

	- in each chain we have 16 paths, 1 TOS value per path
	- all 8 TOS values for a path are in 8 different chains

2. TOS is not a hash key:

	2 paths per chain (2 paths x 8 TOS values => 16 entries)

if all saddr->daddr->tos streams have same packet rate I think
the CPU time to lookup them will be same.
This is because 8 (number of TOS values) < 16 (chain length).

	And I hope the users always can tune the proposed TOS
settings if they see DoS and if they do not need TOS as a rt key.

Regards

--
Julian Anastasov <ja@ssi.bg>
