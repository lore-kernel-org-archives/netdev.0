From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: Thu, 17 Jul 2003 16:55:14 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307171648230.6323-100000@netcore.fi>
References: <1058442897.5780.69.camel@hades>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: kuznet@ms2.inr.ac.ru, <davem@redhat.com>, <jmorris@redhat.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Mika Liljeberg <mika.liljeberg@welho.com>
In-Reply-To: <1058442897.5780.69.camel@hades>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 17 Jul 2003, Mika Liljeberg wrote:
> On Thu, 2003-07-17 at 14:16, Mika Liljeberg wrote:
> > On Thu, 2003-07-17 at 10:04, Pekka Savola wrote:
> > > >     ip route add 3ffe::.... via 193.233.7.65
> > > 
> > > That would be simpler but, we actually require:
> > > 
> > > ip route add 3ffe::... via ::193.233.7.65
> > > 
> > > and thus require a route for ::/96.  That's confusing: ::/96 has a very 
> > > specific purpose in RFCs, and we should not be overloading the 
> > > functionality, it's just plain confusing.
> > 
> > I agree with Pekka. Alexey, you yourself admitted that this hack was put
> > in, because you needed a way to represent an IPv4 address in IPv6
> > format. The IPv4-mapped format (::ffff:a.b.c.d) exists exactly for this
> > purpose. User space tools can accept it as a.b.c.d and convert to
> > IPv4-Mapped for the IPv6 API. There is no need to invent non-standard
> > practises.
> 
> Ok, I have to correct myself a bit here. Looking at the 6to4 RFC it
> actually does recommend the fe80::v4addr format, already mentioned, in
> case a link-local address is needed.

Note that the spec refers to the generation of your *own* fe80::x address, 
in the case that e.g. the implementations like to have link-local 
addresses on interfaces.  One doesn't say that when you're contacting 6to4 
relays, you should use a link-local address formed like above to 
communicagte the IP address.
 
> So we would have:
> 
> ip route add 3ffe:... via fe80::bada:bee4 dev sitX
> 
> Clean, although not as convenient for the user.

I disagree a bit on cleanliness.  The problem with the above is that when
you see the next-hop "fe80::bada:bee4", you can't have any idea whether it
really means "tunnel to (dec)bada:bee4" or "a router known as
fe80::bada:bee4".  It depends on the interface.  The context of 6to4 is
lost.

For that reason, IMO 2002:v4:addr is the clearest, and "via v4addr" seems
like the next best one (IMHO).

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
