From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: Anycast usage, final diagnosis? (was: IPv6: Fix broken anycast
	usage)
Date: 17 Jul 2003 11:38:53 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058431132.5781.32.camel@hades>
References: <200307170223.GAA13064@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet <kuznet@dub.inr.ac.ru>, davem@redhat.com, jmorris@redhat.com,
   pekkas@netcore.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307170223.GAA13064@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexey,

On Thu, 2003-07-17 at 05:23, kuznet@ms2.inr.ac.ru wrote:
> diff -Nru a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> --- a/net/ipv6/ndisc.c	Thu Jul 17 06:13:09 2003
> +++ b/net/ipv6/ndisc.c	Thu Jul 17 06:13:09 2003
> @@ -785,8 +785,7 @@
>  			ipv6_addr_all_nodes(&maddr);
>  			ndisc_send_na(dev, NULL, &maddr, &ifp->addr, 
>  				      ifp->idev->cnf.forwarding, 0, 
> -				      ipv6_addr_type(&ifp->addr)&IPV6_ADDR_ANYCAST ? 0 : 1, 
> -				      1);
> +				      1, 1);
>  			in6_ifa_put(ifp);
>  			return;
>  		}
> @@ -809,8 +808,7 @@
>  			if (neigh || !dev->hard_header) {
>  				ndisc_send_na(dev, neigh, saddr, &ifp->addr, 
>  					      ifp->idev->cnf.forwarding, 1, 
> -					      ipv6_addr_type(&ifp->addr)&IPV6_ADDR_ANYCAST ? 0 : 1, 
> -					      1);
> +					      1, 1);
>  				if (neigh)
>  					neigh_release(neigh);
>  			}

I'm not sure you can just remove these. It seems possible (?) to have
the anycast address configured on one of the interfaces as a unicast at
the same time. I.e., one of the anycast members could own the address.

For what it's worth, I think you have the right semantics.

	MikaL
