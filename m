From: Julian Anastasov <ja@ssi.bg>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 22:20:56 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312102210060.7034-100000@l>
References: <20031210203433.3747b7fd.ak@suse.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Kevin W. Rudd" <ruddk@us.ibm.com>, <davem@redhat.com>,
        <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>,
        <chester.f.johnson@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031210203433.3747b7fd.ak@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 10 Dec 2003, Andi Kleen wrote:

> I don't think the network users will be very happy if you require changing all
> end hosts this way. How about the following hack? For DF=1 packets
> the ipid field is useless. When you rewrite the TOS to DSCP save
> the old TOS in the ipid field.  When you see an ICMP fragment required
> message with the right DSCP on the router restore the old TOS from the ipid
> field.

	It can be an option: pmtu_promisc or whatever (default 0).
We should avoid using TOS as hash key and if the var is 1 we should
ignore matching the tos keys in ip_rt_frag_needed and ip_rt_redirect.
By this way, all cache entries between saddr and daddr will be updated, no 
matter the TOS or even OIF keys. Comments?

Regards

--
Julian Anastasov <ja@ssi.bg>
