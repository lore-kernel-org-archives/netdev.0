From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/4] IPv6: keep route for tentative address
Date: Mon, 12 Apr 2010 14:17:49 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4FCE12C@rrsmsx501.amr.corp.intel.com>
References: <20100412154130.397252857@vyatta.com>
 <20100412154255.641453741@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54615 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752876Ab0DLURy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 16:17:54 -0400
In-Reply-To: <20100412154255.641453741@vyatta.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Recent changes preserve IPv6 address when link goes down (good).
> But would cause address to point to dead dst entry (bad).
> The simplest fix is to just not delete route if address is
> being held for later use.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/net/ipv6/addrconf.c	2010-04-11 12:19:37.938082190 -0700
> +++ b/net/ipv6/addrconf.c	2010-04-11 12:25:05.349309074 -0700
> @@ -4046,7 +4046,8 @@ static void __ipv6_ifa_notify(int event,
>  			addrconf_leave_anycast(ifp);
>  		addrconf_leave_solict(ifp->idev, &ifp->addr);
>  		dst_hold(&ifp->rt->u.dst);
> -		if (ip6_del_rt(ifp->rt))
> +
> +		if (ifp->dead && ip6_del_rt(ifp->rt))
>  			dst_free(&ifp->rt->u.dst);
>  		break;
>  	}

Stephen,

With these series of patches (1-4) applied I am no longer seeing the
hangs and warnings associated with ipv6. I ran few rounds of
tests with resetting the interface and loading/unloading modules.

Thanks a lot for looking into this!
Emil