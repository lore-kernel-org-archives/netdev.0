From: Mika Liljeberg <mika.liljeberg@welho.com>
Subject: Re: Fw: [PATCH] IPv6: Allow 6to4 routes with SIT
Date: 17 Jul 2003 17:35:36 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1058452536.5781.87.camel@hades>
References: <Pine.LNX.4.44.0307171648230.6323-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0307171648230.6323-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pekka,

Looks like I've talked myself around to Alexey's point of view. :-)

On Thu, 2003-07-17 at 16:55, Pekka Savola wrote:
> Note that the spec refers to the generation of your *own* fe80::x address, 
> in the case that e.g. the implementations like to have link-local 
> addresses on interfaces.  One doesn't say that when you're contacting 6to4 
> relays, you should use a link-local address formed like above to 
> communicagte the IP address.

Yes, but section 3.7 of rfc2893 talks about the use of that link-layer
address with routing protocols. I take this to include "as next hop
address".
 
> I disagree a bit on cleanliness.  The problem with the above is that when
> you see the next-hop "fe80::bada:bee4", you can't have any idea whether it
> really means "tunnel to (dec)bada:bee4" or "a router known as
> fe80::bada:bee4".  It depends on the interface.  The context of 6to4 is
> lost.

I would say that is a feature. The next hop address *always* identifies
the next hop router, and it's a link-local unicast as it is supposed to
be. In the case of 6to4, the next hop router just happens to be a 6to4
relay located on the virtual link provided by the SIT interface. The
tunneling is purely a property of the SIT interface, the routing code
doesn't have to care. Theoretically, you could even create solicited
node multicast addresses the same way and run ND over the tunnel (not
that it's needed).

	MikaL
