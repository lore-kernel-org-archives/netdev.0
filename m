From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6
 tunnels
Date: Wed, 03 Sep 2003 19:22:26 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903.192226.122933464.yoshfuji@linux-ipv6.org>
References: <20030903.063705.89449634.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0309031232010.5039-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, pekkas@netcore.fi, usagi-core@linux-ipv6.org,
   netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: vnuorval@tcs.hut.fi
In-Reply-To: <Pine.LNX.4.44.0309031232010.5039-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0309031232010.5039-100000@rhea.tcs.hut.fi> (at Wed, 3 Sep 2003 13:17:56 +0300 (EEST)), Ville Nuorvala <vnuorval@tcs.hut.fi> says:

> Come to think of it a more elegant solution might be:
> 
>         if (ifp->idev->cnf.forwarding == 0 &&
>             (dev->flags&IFF_LOOPBACK) == 0 &&
> +           ifp->idev->cnf.rtr_solicits > 0 &&
>             (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
>                 struct in6_addr all_routers;
> 
> and set both idev->cnf.rtr_solicits = 0 and idev->cnf.accept_ra = 0 for
> ARPHRD_TUNNEL6 devices

Yes, something like that.


> > Comment: this strategy is the "default."
> > We can (or even should) do this stretegy whenever we failed to
> > ipv6_generate_eui64() in addrconf_dev_config().
> 
> Should I send a separate patch to enable the random interface ids in
> addrconf_dev_config()?

No, just move them to addrconf_dev_config().

--yoshfuji
