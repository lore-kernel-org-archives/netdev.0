From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Tue, 15 Jul 2003 09:14:07 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307150906340.7445-100000@netcore.fi>
References: <200307142349.DAA06134@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307142349.DAA06134@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Jul 2003 kuznet@ms2.inr.ac.ru wrote:
> > Alexey, please add some sanity to this discussion.
> 
> It is about anycast addresses, I maybe not competent here.
> I have no idea what is purpose of all-routers anycast.
> 
> However, my modest opinion is here:
> 
> IN NO WAY ANYCAST ADDRESSES MAY BE USED AS NEXTHOP ADDRESSES.
> NEXTHOP ADDRESS IS THE ADDRESS WHICH IS EXPECTED TO BE SOURCE OF REDIRECT
> MESSAGES ET AL. ANYCAST ADDRESSES ARE INVALID AS SOURCE, HENCE...

Modestly, I disagree.

You just can't get away from the requirement of having be able to
"resolve" next-hops.  I.e., the requirement that the users/protocols will
give you non-final nexthop information which you have to "resolve" to get
the final nexthop (e.g. a global address -> a link-local address 
obtained using Neighbor Discovery).

You want to avoid that: simple IPv4 routers can, but IPv6 in particular,
as it implements different scopes which are used extensively especially
with Neighbor Discovery, can't really live without it.

I'm not sure about the level of complexity resolvable next-hops cause, but 
it shouldn't be huge.  The tricky part where proprietary vendors often 
break are the cases when the "global nexthop" changes but the mapping to 
the resolved nexthop is not updated.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
