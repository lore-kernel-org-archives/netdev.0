From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: PMTU issues due to TOS field manipulation (for DSCP)
Date: Wed, 10 Dec 2003 14:36:33 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD79FF1.8000505@us.ibm.com>
References: <Pine.LNX.4.44.0312102301550.1285-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <ak@suse.de>, "Kevin W. Rudd" <ruddk@us.ibm.com>,
        davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
        chester.f.johnson@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0312102301550.1285-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Julian Anastasov wrote:

> 	I see three cases:
> 
> 1. we do not route by TOS => we want to ignore TOS everywhere, if
> possible, sysctl var variant for IPTOS_RT_MASK=0
> 
> 2. we route by TOS (IPTOS_RT_MASK!=0) but we like the idea to
> ignore TOS for PMTUD and ICMP redirects.

> 3. the current behavior, PMTUD does not work if TOS is changed,
> the routing cache keeps many entries with different TOS

> 	The question is how many proc entries are needed for these
> cases. It seems, we can cover all cases with one proc entry: to
> make IPTOS_RT_MASK a sysctl var. But there is still difference
> between cases 1 and 2, may be the var will have more than 2 values?

	1. we route by TOS
		- yes (no PMTUD/ICMP conflict)  MASK = $mask
		- no (PMTUD/ICMP conflict)	MASK = 0
	2. we do not route by TOS at all	MASK = 0

Unless the kernel is checking on the fly, you do not need to
distinguish between 1b and 2, correct? (i.e.Since we are just expecting
the user to set the sysctl variable). 1a is your case 3,
current behaviour.

thanks,
Nivedita

'
