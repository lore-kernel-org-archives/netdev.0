From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6
 tunnels
Date: Wed, 03 Sep 2003 06:37:05 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030903.063705.89449634.yoshfuji@linux-ipv6.org>
References: <20030901035134.2585aa79.davem@redhat.com>
	<Pine.LNX.4.44.0309011709370.29198-200000@rhea.tcs.hut.fi>
	<20030902043534.05fc6586.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vnuorval@tcs.hut.fi, pekkas@netcore.fi, usagi-core@linux-ipv6.org,
   netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030902043534.05fc6586.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030902043534.05fc6586.davem@redhat.com> (at Tue, 2 Sep 2003 04:35:34 -0700), "David S. Miller" <davem@redhat.com> says:

> On Mon, 1 Sep 2003 17:24:42 +0300 (EEST)
> Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:
> 
> > Ok, this incremental patch to my previous addrconf.c patch generates a
> > link-local address to the IPv6 tunnel device. It first tries to inherit
> > the EUI64 identifier of some other device and if this fails, uses a
> > random interface id.
> 
> Yoshfuji, do you mind if I apply his patch 5 and "5/5+1"?

Well, I have a question and a comment.

        if (ifp->idev->cnf.forwarding == 0 &&
            (dev->flags&IFF_LOOPBACK) == 0 &&
+           dev->type != ARPHRD_TUNNEL6 &&
            (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
                struct in6_addr all_routers;

Why?

Comment: this strategy is the "default."  
We can (or even should) do this stretegy whenever we failed to 
ipv6_generate_eui64() in addrconf_dev_config().

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
