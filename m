From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: 17 Jul 2003 14:16:26 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058440586.5781.59.camel@hades>
References: <Pine.LNX.4.44.0307170956440.1348-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0307170956440.1348-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2003-07-17 at 10:04, Pekka Savola wrote:
> >     ip route add 3ffe::.... via 193.233.7.65
> 
> That would be simpler but, we actually require:
> 
> ip route add 3ffe::... via ::193.233.7.65
> 
> and thus require a route for ::/96.  That's confusing: ::/96 has a very 
> specific purpose in RFCs, and we should not be overloading the 
> functionality, it's just plain confusing.

I agree with Pekka. Alexey, you yourself admitted that this hack was put
in, because you needed a way to represent an IPv4 address in IPv6
format. The IPv4-mapped format (::ffff:a.b.c.d) exists exactly for this
purpose. User space tools can accept it as a.b.c.d and convert to
IPv4-Mapped for the IPv6 API. There is no need to invent non-standard
practises.

It may be convenient to think that the IPv4 Internet is a virtual link
connecting all 6to4 routers and IPv4 compatible addresses could be seen
as the link-local addresses, but this is just an affectation that is not
backed by any IETF specification. Overloading the IPv4-compatible
address in this way is just confusing, because it creates the impression
that the stack will actually take steps to resolve the gateway address
to a next hop address that is on-link. (I'm not saying it should, but
you can see where the confusion arises).

	MikaL
