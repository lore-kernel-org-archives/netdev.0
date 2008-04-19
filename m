From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] build failure in net/netfilter/nf_conntrack_sip.c, on
	latest -git
Date: Sat, 19 Apr 2008 12:41:52 +0200
Message-ID: <20080419104152.GB13599@elte.hu>
References: <20080419100034.GA9475@elte.hu> <20080419.030736.168169087.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080419.030736.168169087.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Sat, 19 Apr 2008 12:00:35 +0200
> 
> [ netfilter-devel and netdev added to CC: ]
> 
> > randconfig testing found a netfilter build failure in latest -git:
> > 
> >   net/netfilter/nf_conntrack_sip.c: In function 'set_expected_rtp_rtcp':
> >   net/netfilter/nf_conntrack_sip.c:786: error: 'struct nf_conntrack_expect' has no member named 'saved_ip'
> > 
> >   http://redhat.com/~mingo/misc/config-Sat_Apr_19_11_37_02_CEST_2008.bad
> > 
> > disabling CONFIG_NF_CONNTRACK_SIP works it around.
> 
> I think this will fix it.
> 
> Patrick, is this how we should do it?
> 
> diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
> index c1fc0f1..fd60b2b 100644
> --- a/net/netfilter/Kconfig
> +++ b/net/netfilter/Kconfig
> @@ -245,7 +245,7 @@ config NF_CONNTRACK_SANE
>  
>  config NF_CONNTRACK_SIP
>  	tristate "SIP protocol support"
> -	depends on NF_CONNTRACK
> +	depends on NF_CONNTRACK && NF_NAT
>  	default m if NETFILTER_ADVANCED=n
>  	help
>  	  SIP is an application-layer control protocol that can establish,

thanks David, this solves the build failure here.

Tested-by: Ingo Molnar <mingo@elte.hu>

	Ingo

