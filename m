From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH|RFC] IPv6: have a proxy discard link-local traffic
Date: Sat, 17 Jan 2004 09:06:54 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401170906160.9907-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, <davem@redhat.com>, <usagi-core@linux-ipv6.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

(Re-sending as netdev was non-operational yesterday.)

On Fri, 16 Jan 2004, Ville Nuorvala wrote:
> > It's still at the starting phase -- now would be an excellent time to
> > bring this up.
> 
> OK, I guess I'll send a question to the ipv6 list.

Please do -- I've already raised too many issues in that spec :-)

> Let's assume the proxy handles (both link-local and global) NUD
> probes correctly. What will it do with the rest of the unicast packets?
> 
> Packets to a global address may be routed to the proxied node if the
> router has a route to it, but what should it do to link-local packets? The
> desired behavior isn't described in RFC2461, but the MIPv6 draft has a
> proposal.

Right.
 
> No, *assuming* we have a proxy capable of capturing NUD probes, my patch
> will send an Address Unreachable message in response to all link-local
> unicast traffic *except* ND, since it is already handled separately.
> Since ND works normally, my patch doesn't limit link-local proxying. It
> just warns the sender that any link-local traffic it is trying to send
> can't be delivered to the destination.

OK.
 
> > It can give back ICMP error messages, if necessary.  I don't know
> > which path a Thaler proxy would use though.
> 
> It can't really use ip6_forward() anyway, since the funtion decreases the
> hop limit of the packet and drops all traffic from a link-local source
> address etc, etc.
> 
> Since the Thaler proxy clearly needs some other forwarding function than
> ip6_forward(), my proposed patch doesn't affect its behavior in any way.

Ok, if your modification is in ip6_forward() (I didn't check), I guess 
it would OK, with a sufficient comment to bring up that a future 
implementation might treat link-local proxying differently.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
