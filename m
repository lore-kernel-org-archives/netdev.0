From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip_route_me_harder -> xfrm_lookup
Date: Mon, 08 Mar 2004 15:46:37 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <404C874D.4000907@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040308110331.GA20719@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Herbert,

Herbert Xu wrote:
> Hi:
> 
> I've received a number of reports that the any packets that are modified
> by the PREROUTING mangle table will not be protected by IPsec.
> 
> The reason is that ip_route_me_harder which is called upon the exit
> of the mangle table does not set the proto field.  This means that
> xfrm_lookup is never called.
> 
> The following patch sets the proto field so that the packet can be
> protected by IPsec.

I have been working on a set of patches for IPsec+Netfilter, the
latest set has been posted to netfilter-devel last week. They will
go in patch-o-matic for testing soon, but I will post them
to netdev later today, so we won't waste time testing patches
before Dave is fine with them.

Regards,
Patrick

> 
> Cheers,
> 
> 
> ------------------------------------------------------------------------
> 
> Index: kernel-2.5/net/core/netfilter.c
> ===================================================================
> RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/core/netfilter.c,v
> retrieving revision 1.1.1.10
> diff -u -r1.1.1.10 netfilter.c
> --- kernel-2.5/net/core/netfilter.c	8 Oct 2003 19:24:04 -0000	1.1.1.10
> +++ kernel-2.5/net/core/netfilter.c	8 Mar 2004 10:52:39 -0000
> @@ -639,6 +639,7 @@
>  #ifdef CONFIG_IP_ROUTE_FWMARK
>  		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
>  #endif
> +		fl.proto = iph->protocol;
>  		if (ip_route_output_key(&rt, &fl) != 0)
>  			return -1;
>  
