From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Thu, 11 Dec 2003 01:15:06 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312110103280.1519-100000@u.domain.uli>
References: <20031210145149.2bd89e9b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Nivedita Singhvi <niv@us.ibm.com>, <ak@suse.de>, <ruddk@us.ibm.com>,
        <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
        <chester.f.johnson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031210145149.2bd89e9b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 10 Dec 2003, David S. Miller wrote:

> Here is my take on this, as far as Linux is concerned.
>
> I agree with the three behaviors proposed by Julian.
> However I have some slight trouble with the ignore-TOS-for-
> PMTU idea, implementation wise.
>
> Walking the routing hash table for each possible TOS value
> is going to be computationally expensive, and is inviting
> computational complexity DDoS attacks by bombing the machine
> with PMTU ICMP messages.

	What about not using TOS as hash key, then we will
see all entries for same SADDR->DADDR but with different TOS
values in same table row. I hope it will not hurt the
jenkins hash too much but it is evident that we put all
these entries with different TOS and OIF on same table row.
It seems, there are no many users of OIF!=0 but if TOS is
used as routing key we can see up to 8 entries with different
TOS for same SADDR,DADDR. Of course, it looks difficult to
walk 8 rows just to check all TOS variants, the common case
is to see only one TOS value used. That is why I propose
to eliminate the TOS as hash key and to walk one row. At first
look, the risk of DoS is same, thanks to the random value.

Regards

--
Julian Anastasov <ja@ssi.bg>
