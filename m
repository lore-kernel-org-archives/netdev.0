From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 6to4 on site-local networks.
Date: Wed, 10 Sep 2003 21:52:19 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309102147310.3223-100000@netcore.fi>
References: <1063219081.7869.205.camel@imladris.demon.co.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1063219081.7869.205.camel@imladris.demon.co.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 10 Sep 2003, David Woodhouse wrote:
> I'm looking at the possible ways of setting up a IPv6 site-internal
> network, given the prior existence of IPv4 tunnels on RFC1918 addresses
> between various physical sites.
> 
> The idea which looks sanest to me is to use the 6to4 automatic
> tunnelling trick. Instead of 2002::/16, however, we use fec0::/16. Since
> our internal IPv4 addresses are in the 172.16/12 range, we end up with
> fec0:ac10::/28 for the internal site-scope addresses.
> 
> This requires a hack to sit.c -- just a single s/0x2002/0xfec0/ in fact.
> I'd like to make that configurable somehow. Any ideas on how best to do
> it?
> 
> With this in place, individual routers can still run radvd and route to
> native IPv6 on their own fec0:ac1x:xxyy::/48 subnets -- just as we do in
> the real world with 6to4 on 2002:xxxx:yyyy::/48. 

Please don't do this, this is an ambomination.  Moreover, some time ago 
the IETF decided to Deprecate Site-local addresses completely, because of 
their problems.

I'm not 100% clear of your scenario, but I'd suggest two possibilities for 
you:

 - build the IPv6 infrastructure without automatic tunneling, or
 - if you want to do what you describe anyway, look at ISATAP (the code 
exists in USAGI), or the spec at www.isatap.org.  It should be able to 
accomplish what you seem to be aiming at.

ISATAP uses a prefix you decide, e.g. global ones derived from 6to4, 
site-locals if you really insist, or whatever -- it just embeds the IPv4 
tunnel endpoint addresses in the last 32 bits.

Note that ISATAP has not been sanctioned at the moment.  There are some
significant issues open in it, mostly relating to its security.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
