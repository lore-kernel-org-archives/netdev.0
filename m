From: jamal <hadi@cyberus.ca>
Subject: Re: tunneling in linux (was: Re: [PATCH][RFC] etherip:
	Ethernet-in-IPv4 tunneling)
Date: 16 Jan 2005 15:02:26 -0500
Message-ID: <1105905745.1097.858.camel@jzny.localdomain>
References: <20050112222437.GC14280@xi.wantstofly.org>
	 <Pine.LNX.4.61.0501130944270.19573@netcore.fi>
	 <20050113092351.GA23170@xi.wantstofly.org>
	 <1105897020.1091.736.camel@jzny.localdomain>
	 <20050116185553.GA21739@xi.wantstofly.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Pekka Savola <pekkas@netcore.fi>, shemminger@osdl.org,
        shollenbeck@verisign.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20050116185553.GA21739@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2005-01-16 at 13:55, Lennert Buytenhek wrote:
[..]
> Another argument against etherip would be that OpenBSD apparently
> mis-implemented etherip by putting the etherip version nibble in the
> second nibble of the etherip header instead of the first, which would
> probably prevent the linux and OpenBSD versions from interoperating,
> negating the advantage of using etherip in the first place.

Should be pretty easy for them to fix, no?

> All I personally care about is that when I install a random linux distro
> two years from now, that ethernet-over-IP tunneling will simply work, using
> whatever protocol -- I don't care about which.
> 
> Any opinions?
> 

My opinion is it doesnt harm to have it in. BTW, in one of your emails i
noticed you cced the authors of that RFC - did they respond? Whats their
deployment experiences?

> 
> If we do end up using GRE for ethernet tunneling, there's some work that
> needs to be done.  For one, ip_gre in its current form would need a certain
> amount of hacking for tunneling ethernet frames instead of IPv4/IPv6 as
> it does now.  We might as rename it to plain 'gre' and move it out of
> net/ipv4/ to net/core/ or something while we're at it.
> 
> The way we currently use (f.e. in iproute2) for finding out whether a
> given netdevice is a tunnel or not is by looking at ARPHRD_*, but this
> scheme breaks down for ethernet tunnels,

the dev->type is intended precisely for that. So if this needs a new
type then you should introduce a new ARPHRD type for it and set it at
device creation time.

>  since there is no other way of
> distinguishing them from regular ethernet devices.  We could issue
> SIOCGETTUNNEL and see if that succeeds, but that unfortunately aliases
> with SIOCDEVPRIVATE which aliases to BOND_ENSLAVE_OLD, SIOCGMSTATS,
> EQL_ENSLAVE, FRAD_GET_CONF, SIOCDEVPLIP, SIOCGPPPSTATS and a million
> others, so you never know if the netdevice really interpreted it as
> SIOCGETTUNNEL or no.

Introducing the new type should help. Also the iflink is typically set
to the mother netdevice. So that should go a long way to give you
details.
Ia m not sure about this ioctl stuff - but shouldnt there be a backway
via netlink for all these details.

> Other things that suck about tunneling?
> - If we're going to overhaul the way tunneling works, we should try to
>   remove the need for the gre0 interface as well.

Why is this first instance needed? Its not like theres a bus that is
scanned at boot time and we need to create at that discovery time.

> - Tunneling over IPv6 should be implemented.

sit? or v6-v6?

> - How to share more code between sit/ipip/gre?

Lots of shareable stuff there.

BTW, have you looked at any of the L2VPN stuff? browse the ietf web
page. Some interesting stuff there.

cheers,
jamal
