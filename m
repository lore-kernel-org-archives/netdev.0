From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: (5/5+1) Autoconfig link-local addr to IPv6 tunnels
Date: Wed, 3 Sep 2003 14:48:04 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309031444190.16329-100000@netcore.fi>
References: <Pine.LNX.4.44.0309031232010.5039-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>,
   <davem@redhat.com>, <usagi-core@linux-ipv6.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <Pine.LNX.4.44.0309031232010.5039-100000@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 3 Sep 2003, Ville Nuorvala wrote:
> On Wed, 3 Sep 2003, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:
> > In article <20030902043534.05fc6586.davem@redhat.com> (at Tue, 2 Sep 2003 04:35:34 -0700), "David S. Miller" <davem@redhat.com> says:
> >
> > > On Mon, 1 Sep 2003 17:24:42 +0300 (EEST)
> > > Ville Nuorvala <vnuorval@tcs.hut.fi> wrote:
> > >
> > > > Ok, this incremental patch to my previous addrconf.c patch generates a
> > > > link-local address to the IPv6 tunnel device. It first tries to inherit
> > > > the EUI64 identifier of some other device and if this fails, uses a
> > > > random interface id.
> > >
> > > Yoshfuji, do you mind if I apply his patch 5 and "5/5+1"?
> >
> > Well, I have a question and a comment.
> >
> >         if (ifp->idev->cnf.forwarding == 0 &&
> >             (dev->flags&IFF_LOOPBACK) == 0 &&
> > +           dev->type != ARPHRD_TUNNEL6 &&
> >             (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
> >                 struct in6_addr all_routers;
> >
> > Why?
> 
> The other end of the tunnel might not yet be set up to receive the packet,
> which causes an ICMP error message to be sent back to the sender.
> 
> Besides, RS and RA over a ipv6-in-ipv6 tunnel is a _bad_ idea. A default
> route through a tunnel without more advanced (policy/flow/srcaddr/? based)
> routing schemes can lead to local routing loops.

Who are you to say it's a bad idea?  Users may have a lot of ideas, which 
some may think are bad but are OK.

There is nothing wrong with RS/RA over an IPv6-over-IPv6 tunnel.  I'd 
probably be concerned myself if it wasn't possible.  _However_, that 
doesn't make sense unless you have a more specific route to the 
destination IPv6 tunnel endpoint.

At the moment, I don't know who'd like to get a default IPv6 route over an
IPv6 tunnel, though.. IPv6 VPN users?  MIPv6 users who restrict themselves 
to bidirectional tunneling through the home agent, maybe?

just my 2 cents.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
